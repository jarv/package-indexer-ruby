class Graph
  attr_accessor :graph
  def initialize
    @graph = {}
    @dep_index = Hash.new(0)
  end

  def query_pkg(pkg)
    has_pkg?(pkg) 
  end

  def index_pkg(pkg, deps = [])
    return true if has_pkg?(pkg)
    deps.each do |d|
      return false unless has_pkg?(d)
    end
    deps.each { |d| @dep_index[d] += 1 }
    graph[pkg] = deps
    true
  end

  def remove_pkg(pkg)
    return true unless has_pkg?(pkg)
    return false if dep_exists?(pkg)
    graph[pkg].each{ |d| @dep_index[d] -= 1 }
    graph.delete(pkg)
    true
  end

  private 

  def dep_exists?(pkg)
    @dep_index.key?(pkg) && (@dep_index[pkg] > 0)
  end

  def has_pkg?(pkg)
    graph.key?(pkg)
  end
end
