require_relative "graph"
require "logger"

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
  attr_accessor :logger
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

  def initialize(logger: nil)
    @graph = Graph.new
    @logger = logger || Logger.new(STDERR)
    setup_logger
  end

  def process(line)
    begin
      cmd, pkg, deps = parse_line(line)
    rescue LineParseError => err
      logger.error(err.message)
      return ParseResponse::ERROR
    end
    action_for_cmd(cmd, pkg, deps) ? ParseResponse::OK : ParseResponse::FAIL
  end

  private

  def setup_logger
    logger.level = Logger::INFO
    logger.formatter = proc { |severity, datetime, _progname, msg|
      "#{datetime} [#{severity}]: #{msg}\n"
    }
  end

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
    raise LineParseError, "Unable to parse: #{line.chomp}" unless match
    cmd, pkg, dep = match.captures
    [cmd, pkg, dep.split(",")]
  end
end
