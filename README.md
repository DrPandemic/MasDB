# MasDB
MasDB is a distributed database.

## Build
You need to have `elixir` and `erlang` installed on your system. Run `mix deps.get` to get all dependencies.

## Run
Before being able to run a node, you need to have `epmd` running. You can start it as a daemon with `epmd -daemon`.

There's some environment variables that can be changed to setup a MasDB node.
```
  SAVE_FILE    Set the save path. Default to `./data.db`.
  NODE_NAME    Set this erlang's node's name. It will be mixed with the hostname arg to generate a fully qualified name.
                If not specified, a name will be generated.
  HOSTNAME     Set the hostname. If not specified, `127.0.0.1` will be used.
  NODE_TO_JOIN Set the node that this node need to contact to join a cluster. eg. `name@hostname`
```

A simple way to configure a node is to create a `.env` file and run `source .env` before launching the code.

`.env1`
```sh
export SAVE_FILE=./data/foo.db
export NODE_NAME=foo
export HOSTNAME=127.0.0.1
```

`.env2`
```sh
export SAVE_FILE=./data/bar.db
export NODE_NAME=bar
export HOSTNAME=127.0.0.1
export NODE_TO_JOIN=foo@127.0.0.1
```

It's also possible to modify environment variables while launching the node.
```sh
$ NODE_NAME=bar iex -S mix
```

## Release
Running `mix release` should produce a release using distillery.
