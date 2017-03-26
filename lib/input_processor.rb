require_relative "graph"

module ParseResponse
  ERROR = "ERROR".freeze
  OK = "OK".freeze
  FAIL = "FAIL".freeze
end

module CmdType
  INDEX = "INDEX".freeze
  REMOVE = "REMOVE".freeze
  QUERY = "QUERY".freeze
end

class LineParseError < StandardError
end

class InputProcessor
  # /[[:graph:]]/ - Non-blank character
  #                 (excludes spaces, control characters, and similar)
  #                 https://ruby-doc.org/core-2.1.1/Regexp.html
  LINE_REGEX = /
    ^(#{CmdType::INDEX}|#{CmdType::REMOVE}|#{CmdType::QUERY}) # valid cmd
    \|
    ([[:graph:]]+?) # package to index
    \|
    ([[:graph:]]*)$ # comma separated list of deps
  /x

  def initialize
    @graph = Graph.new
  end

  def process(line)
    begin
      cmd, pkg, deps = parse_line(line)
    rescue LineParseError
      return ParseResponse::ERROR
    end
    action_for_cmd(cmd, pkg, deps) ? ParseResponse::OK : ParseResponse::FAIL
  end

  private

  def action_for_cmd(cmd, pkg, deps)
    case cmd
    when CmdType::INDEX
      @graph.index_pkg(pkg, deps)
    when CmdType::REMOVE
      @graph.remove_pkg(pkg)
    when CmdType::QUERY
      @graph.query_pkg(pkg)
    end
  end

  def parse_line(line)
    match = line.match(LINE_REGEX)
    raise LineParseError, "Unable to parse: #{line}" unless match
    cmd, pkg, dep = match.captures
    [cmd, pkg, dep.split(",")]
  end
end
