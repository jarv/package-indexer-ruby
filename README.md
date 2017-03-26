# Package Indexer

## Installation

Package Indexer has no gem dependencies and can be run locally using the system
ruby (tested against version >2.2).

To run the server:
```
./bin/server.rb
```

Tested against the DO provided test harness:
```
./do-package-tree_darwin

...
2017/03/26 16:40:53 TESTRUN - FINISHED (took 4313ms 4.313098846s)
2017/03/26 16:40:53 ================
2017/03/26 16:40:53 All tests passed!
2017/03/26 16:40:53 ================
2017/03/26 16:40:53 TESTRUN finished! (took 4313ms)

```

## Troubleshooting

Run with `PKG_INDEX_DEBUG=1` in the local or Docker environment for debug logging.

## Testing

Using rbenv and bundler:
```
rbenv install
gem install bundler
bundle install
```

### Unit tests

```
rspec --format documentation
```

### Syntax

```
rubocop
```

## Run in a Docker container

Package Indexer has a Dockerfile that uses the Ubuntu 16.04
image from the container registry.

```
docker build -t package-indexer .
docker run -p 8080:8080 package-indexer
```

## Design considerations

* Because package names are hashable types Ruby's hashmap was chosen as a data-structure for holding the package graph in memory. This allows for fast O(1) lookups for packages and their dependencies.
* A separate index was created using a second hash map to track dependencies. This was done to increase performance so that when packages are removed it only requires an O(1) hash lookup to see if a given package has any remaining packages that depend on it.
* Although not explicitly stated in the problem description, indexing a package with duplicate dependencies (packages with the same name) is treated as an error.
* Unicode is supported for package names but the package name validation will only allow Unicode general categories.

## Problem Description
(copied from INSTRUCTIONS.md)

*Packages* are executables or libraries that can be installed in a system, often via a package manager such as apt, RPM, or Homebrew. Many packages use libraries that are also made available as packages themselves, so usually a package will require you to install its dependencies before you can install it on your system.

The system you are going to write keeps track of package dependencies. Clients will connect to your server and inform which packages should be indexed, and which dependencies they might have on other packages. We want to keep our index consistent, so your server must not index any package until all of its dependencies have been indexed first. The server should also not remove a package if any other packages depend on it.

The server will open a TCP socket on port 8080. It must accept connections from multiple clients at the same time, all trying to add and remove items to the index concurrently. Clients are independent of each other, and it is expected that they will send repeated or contradicting messages. New clients can connect and disconnect at any moment, and sometimes clients can behave badly and try to send broken messages.

Messages from clients follow this pattern:

```
<command>|<package>|<dependencies>\n
```

Where:
* `<command>` is mandatory, and is either `INDEX`, `REMOVE`, or `QUERY`
* `<package>` is mandatory, the name of the package referred to by the command, e.g. `mysql`, `openssl`, `pkg-config`, `postgresql`, etc.
* `<dependencies>` is optional, and if present it will be a comma-delimited list of packages that need to be present before `<package>` is installed. e.g. `cmake,sphinx-doc,xz`
* The message always ends with the character `\n`

Here are some sample messages:
```
INDEX|cloog|gmp,isl,pkg-config\n
INDEX|ceylon|\n
REMOVE|cloog|\n
QUERY|cloog|\n
```

For each message sent, the client will wait for a response code from the server. Possible response codes are `OK\n`, `FAIL\n`, or `ERROR\n`. After receiving the response code, the client can send more messages.

The response code returned should be as follows:
* For `INDEX` commands, the server returns `OK\n` if the package can be indexed. It returns `FAIL\n` if the package cannot be indexed because some of its dependencies aren't indexed yet and need to be installed first. If a package already exists, then its list of dependencies is updated to the one provided with the latest command.
* For `REMOVE` commands, the server returns `OK\n` if the package could be removed from the index. It returns `FAIL\n` if the package could not be removed from the index because some other indexed package depends on it. It returns `OK\n` if the package wasn't indexed.
* For `QUERY` commands, the server returns `OK\n` if the package is indexed. It returns `FAIL\n` if the package isn't indexed.
* If the server doesn't recognize the command or if there's any problem with the message sent by the client it should return `ERROR\n`.
