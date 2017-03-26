require_relative "graph"

module ParseResponse
  ERROR = "ERROR"
  OK = "OK"
  FAIL = "FAIL"
end

module CmdType
  INDEX = "INDEX"
  REMOVE = "REMOVE"
  QUERY = "QUERY"
end

class LineParseError < StandardError
end

class InputProcessor
 
  LINE_REGEX = /^(#{CmdType::INDEX}|#{CmdType::REMOVE}|#{CmdType::QUERY})\|(.+)\|(.*)/

  def initialize
    @graph = Graph.new
  end

  def process(line)
    begin
      cmd, pkg, deps = parse_line(line.chomp)
    rescue LineParseError
      return ParseResponse::ERROR
    end
    case cmd
    when CmdType::INDEX
      return (@graph.index_pkg(pkg, deps) ? ParseResponse::OK : ParseResponse::FAIL)
    when CmdType::REMOVE
      return (@graph.remove_pkg(pkg) ? ParseResponse::OK : ParseResponse::FAIL)
    when CmdType::QUERY
      return (@graph.query_pkg(pkg) ? ParseResponse::OK : ParseResponse::FAIL)
    end
  end

  private

  def parse_line(line)
    match = line.match(LINE_REGEX)
    raise LineParseError.new("Unable to parse: #{line}") unless match
    cmd, pkg, dep = match.captures
    return cmd, pkg, dep.split(",")
  end
end
