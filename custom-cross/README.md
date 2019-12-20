# Tectonic CI support: custom `cross` build

This section of the repository creates a Docker container that hosts a
customized build of the
[rust-embedded cross](https://github.com/rust-embedded/cross) command. We
patch it to run the build containers with the `--privileged` option, which is
necessary to enable the chroot magic that happens inside the builders. Because
of this we have to enter the container as root and have it switch to the
correct (host) UID.

We also patch it to mount the `/project` directory as read-write, since the
Tectonic test suite wants to create a few files there. The test suite should
be fixed to emit these into `/target`, but I'm being lazy.

The `cross` command has to run on the host machine, but fortunately it has no
unusual library dependencies. So, running the container just copies the binary
out to the host machine, which can then run it. This is a bit silly, but gets
the job done for our main CI applications.
