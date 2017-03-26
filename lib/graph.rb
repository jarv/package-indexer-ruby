class Graph
  def initialize
    # the package graph is hash map, containing 
    # a mapping of packages to the list of 
    # their dependencies
    @graph = {}
    # the package dep_index is a counter used
    # to keep track of the total number of
    # dependencies for every package across
    # the entire graph for fast lookups.
    @dep_index = Hash.new(0)
  end

  def query_pkg(pkg)
    has_pkg?(pkg) 
  end

  def index_pkg(pkg, deps = [])
    deps.each do |d|
      return false unless has_pkg?(d)
    end
    remove_deps_from_index(@graph[pkg]) if has_pkg?(pkg)
    add_deps_to_index(deps)
    @graph[pkg] = deps
    true
  end

  def remove_pkg(pkg)
    return true unless has_pkg?(pkg)
    return false if dep_exists?(pkg)
    remove_deps_from_index(@graph[pkg])
    @graph.delete(pkg)
    true
  end

  private 

  def remove_deps_from_index(deps)
    deps.each{ |d| @dep_index[d] -= 1 }
  end

  def add_deps_to_index(deps)
    deps.each { |d| @dep_index[d] += 1 }
  end

  def dep_exists?(pkg)
    @dep_index.key?(pkg) && (@dep_index[pkg] > 0)
  end

  def has_pkg?(pkg)
    @graph.key?(pkg)
  end
end
