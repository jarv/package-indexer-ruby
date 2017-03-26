FROM ubuntu:16.04
RUN apt-get update && apt-get install -y ruby
ADD bin /opt/package-indexer/bin
ADD lib /opt/package-indexer/lib
# ENTRYPOINT /opt/package-indexer/bin/server.rb
