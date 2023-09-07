# Tectonic CI support: custom `cross` program

This section of the repository creates a Docker container that hosts a
customized build of the [cross](https://github.com/cross-rs/cross) command.


## Installation

To install the custom `cross` program, run:

```
docker run --rm -v $(pwd):/work:rw,Z tectonictypesetting/ttcross:latest
```

This will copy a file named `cross` into the current directory (or whatever you
mount to `/work` within the Docker container). The file is an x86-64 Linux
executable with minimal dependencies.

This is basically a silly way to distribute a pre-built binary, and it could be
superseded with any of a variety of other mechanisms. But it's what we have
right now.


## Development

The files in this directory can be used to build the
`tectonictypesetting/ttcross` Docker image referenced above. Run:

```
docker build -t tectonictypesetting/ttcross:latest .
```

This framework is currently based on a very old version of the `cross` program,
and its build infrastructure could use a refresh. Fortunately (sort of), the
existing program suffices for Tectonic’s CI.


## Modifications

We patch `cross` to run the build containers with the `--privileged` option,
which is necessary to enable the chroot magic that happens inside the builders.
Because of this we have to enter the container as root and have it switch to the
correct (host) UID.

We also patch it to mount the `/project` directory as read-write, since the
Tectonic test suite wants to create a few files there. The test suite should
be fixed to emit these into `/target`, but I'm being lazy.
