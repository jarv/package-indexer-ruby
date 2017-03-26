#!/usr/bin/ruby


require "socket"
require "thread"
require_relative "../lib/input_processor"

PORT = 8080

processor = InputProcessor.new
mutex = Mutex.new
Socket.tcp_server_loop(PORT) do |socket, _|
  Thread.new do
		while line = socket.gets
			mutex.synchronize do
				socket.print processor.process(line) + "\n"
			end
		end
  end
end
