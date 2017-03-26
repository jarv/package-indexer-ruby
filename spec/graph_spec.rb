require "graph.rb"

describe Graph do
  let(:graph) { Graph.new }

  context "query a package" do
    before(:each) do
      graph.index_pkg("nginx")
      graph.index_pkg("perl")
      graph.index_pkg("apache", ["perl"])
    end

    it "should query a package that exists" do
      expect(graph.query_pkg("nginx")).to be_truthy
    end

    it "should query a package that doesn't exist" do
      expect(graph.query_pkg("ruby")).to be_falsey
    end
  end

  context "index a package" do
    before(:each) do
      graph.index_pkg("nginx")
      graph.index_pkg("perl")
      graph.index_pkg("bash")
      graph.index_pkg("apache", ["perl"])
    end

    it "should index a package that already exist" do
      expect(graph.query_pkg("nginx")).to be_truthy
      expect(graph.index_pkg("nginx")).to be_truthy
      expect(graph.query_pkg("nginx")).to be_truthy
    end

    it "should not index a package that has duplicate dependenciest" do
      expect(graph.index_pkg("python", ["bash"])).to be_truthy
      expect(graph.index_pkg("python3", %w(bash bash))).to be_falsey
    end

    it "should index a package that already exist and update dependencies" do
      # pkg perl still has dependencies
      expect(graph.remove_pkg("perl")).to be_falsey
      # remove the perl dependency by updating apache's deps
      expect(graph.index_pkg("apache", ["bash"])).to be_truthy
      # pkg perl can now be removed from the graph
      expect(graph.remove_pkg("perl")).to be_truthy
    end

    it "should index a package that doesn't exist" do
      expect(graph.query_pkg("ruby")).to be_falsey
      expect(graph.index_pkg("ruby")).to be_truthy
      expect(graph.query_pkg("ruby")).to be_truthy
    end

    it "should not index a package that has deps that don't exist in the graph" do
      expect(graph.query_pkg("ruby")).to be_falsey
      expect(graph.index_pkg("ruby", %w(pkg1 pkg2))).to be_falsey
      expect(graph.query_pkg("ruby")).to be_falsey
    end
  end

  context "remove a package" do
    before(:each) do
      graph.index_pkg("nginx")
      graph.index_pkg("perl")
      graph.index_pkg("apache", ["perl"])
      graph.index_pkg("perl", ["bash"])
    end

    it "should return true for packages that don't exist" do
      expect(graph.query_pkg("ruby")).to be_falsey
      expect(graph.remove_pkg("ruby")).to be_truthy
      expect(graph.query_pkg("ruby")).to be_falsey
    end

    it "should return true for packages that exist with no remaining deps" do
      expect(graph.query_pkg("nginx")).to be_truthy
      expect(graph.remove_pkg("nginx")).to be_truthy
      expect(graph.query_pkg("nginx")).to be_falsey
    end

    it "should return false for packages that exist with remaining deps" do
      expect(graph.query_pkg("perl")).to be_truthy
      expect(graph.remove_pkg("perl")).to be_falsey
    end
  end
end
