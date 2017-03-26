#!/usr/bin/ruby

require "socket"
require "thread"
require_relative "../lib/input_processor"

PORT = 8080

processor = InputProcessor.new
logger = processor.logger
mutex = Mutex.new
logger.info("Starting server, listening on port #{PORT}")
Socket.tcp_server_loop(PORT) do |socket, _|
  Thread.new do
    logger.debug("New connection TID: #{Thread.current.object_id}")
    loop do
      line = socket.gets
      mutex.synchronize do
        logger.debug("Processing line #{line.chomp}")
        socket.print processor.process(line) + "\n"
      end
    end
  end
end
