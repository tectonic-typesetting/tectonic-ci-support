# Statically-linked Tectonic cross-compilation environment

This directory contains Docker recipes that create containers that can be used
to cross-compile Tectonic for a variety of environments, with an emphasis on
statically-linked outputs.


## Workflow

To cross-compile a version of [tectonic] in this framework, the overall workflow
is as follows. These instructions assume that your host environment is an x86-64
Linux system; the same workflow should work on other systems, but you will need
to compile more of the tooling yourself:

[tectonic]: https://github.com/tectonic-typesetting/tectonic/

1. In this directory, build a cross-builder image for your target of interest,
   using a command such as:
   ```
   ./build.x86_64-unknown-linux-musl.sh
   ```
   This will generate a Docker image named
   `tectonictypesetting/crossbuild:x86_64-unknown-linux-musl` (or something
   analogous if you specify a different target; all appearances of the target
   name below will likewise track your choice).
1. Obtain a copy of the [tectonic] source code.
1. Within the Tectonic source tree, unpack the [custom Tectonic `cross` program][1]:
   ```
   docker run --rm -v $(pwd):/work:rw,Z tectonictypesetting/ttcross:latest
   ```
1. It is often necessary to delete your entire `target` tree before a new cross
   build. If you don't, you may see an error like:
   ```
   .../build-script-build: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.29' not found
   ```
   This is because the containerized cross build is not smart enough to
   differentiate between build scripts built for your true host OS, and the host
   OS of the cross Docker container.
1. Use that program to execute the cross build:
   ```
   ./cross build --target=x86_64-unknown-linux-musl --release
   ```
1. The final output will be found at
   `target/x86_64-unknown-linux-musl/release/tectonic`.
1. The aspiration is that `./cross test ...` will work, although this is often
   dicey in cross-compilation scenarios. In order to run any cross-compiled binaries,
   you may need to have QEmu handlers registered with your kernel, which can be
   achieved conveniently with:
   ```
   docker run --rm --privileged multiarch/qemu-user-static:register --reset --credential yes
   ```

[1]: ../custom-cross/README.md


## Adding New Targets

If you want to add a new cross-compilation target, the easiest way to start is
by duplicating one of the existing `build.*.sh` scripts. *Hopefully* all you
will need to do is update various parameters.

If your new target is based on an Alpine chroot, you will probably also need to
update `03_alpine_populate.sh` to add a new key fingerprint so that the Alpine
install will accept the necessary support packages.

You also need to add the target to `.azure-pipelines/variables.yml` to integrate
the new architecture into the CI/CD pipeline.

You will also need to add a new entry to the `Cross.toml` file in the toplevel
[tectonic] source directory, adding a record identifying the Docker build
container to be used for the new target.

Once you've done the above, the only true test is to attempt a cross build and
test of Tectonic, and see how far you get. Unfortunately, it is quite common for
it to be necessary to add some truly disgusting hacks to the build framework to
get things to work. Good luck!


## Running the Images Directly

You can't simply `docker run` the `crossbuild` images because they expect to be
launched in the `cross` program's very specialized Docker environment. The
following command line can emulate it just enough to give you a shell:

```
docker run \
  --privileged \
  -e HOST_UID=$(id -u) \
  -e HOST_GID=$(id -g) \
  -v $(pwd):/xargo \
  -v $(pwd):/cargo \
  -v $(pwd):/rust \
  -v $(pwd):/target \
  --rm -it \
  tectonictypesetting/crossbuild:$ARCH bash
```

To set up an environment that can run an actual build, many more settings are
needed. The most reasonable way to determine them is to run a program like `ps
xawww` while a `./cross build` is running.


## Static Build Implementation

A substantial chunk of Tectonic's cross-compilation support is aimed at
providing static builds of the `tectonic` executable. What does
cross-compilation have to do with building static binaries, you might ask?

The key is that Tectonic needs “procedural macro” (AKA “proc macro”) crates to
compile. Procedural macros are implemented as dynamic modules loaded into the
Rust compiler executable. If you are building on a fully static target, you ...
just can't do that.

The solution is to approach the build as a cross-compilation. In a cross build,
the Rust compiler executable is running on the "build" architecture, but
compiling the output program to run on the "target" architecture. Even if the
target architecture is static, we can have procedural macros if the *build*
architecture is dynamic.

Cross-compilation is gnarly for Tectonic because we depend on several system
libraries, like Harfbuzz and Freetype. If we're going to cross-compile, we
need static versions of these libraries available on the build machine *in the
target architecture* — which is usually difficult to set up. In particular,
our build machine will need some C/C++ cross-compilation toolchain, and our
target libraries need to be guaranteed to be compatible with that toolchain.
Copying binaries willy-nilly off the interent *might* work but is probably
asking for trouble.

How can we conveniently get cross-compiled versions of our dependencies?

It would be nice to leverage Alpine Linux — it has up-to-date, pre-built,
static binaries of all of the libraries that Tectonic depends upon. You can’t
just install the Alpine toolchain and libraries in an Ubunutu container, but
you *can* install [Alpine in a chroot]. Inside the chroot, the Alpine
toolchain is accessible.

So our Docker container sets up the Alpine tools, then creates some wrappers
so that *outside* of the chroot we can pretend that the tools are normal
programs. The wrappers strip off `/alpine` prefixes and then run things inside
the chroot.

[Alpine in a chroot]: https://wiki.alpinelinux.org/wiki/Installing_Alpine_Linux_in_a_chroot

Once we actually get cross-compiling, it turns out that statically linking
Rust with C++ is a bit of a pain. After some voodoo hacks I got it working,
specifically by using a [linker wrapper script] suggested by GitHub user
`@dl00`.

[linker wrapper script]: https://github.com/rust-lang/rust/issues/36710#issuecomment-364623950


## The `mini-aports` Tree

The Alpine-based setups in this directory rely on a subtree named `mini-aports`,
which contains a tiny slice of the Alpine Linux [aports] repository. Every so
often, this subtree should be synced up with Alpine development.

[aports]: https://github.com/alpinelinux/aports/

This vendoring process involves a special branch named `vendor-aports`. This
branch derives from a very early iteration of this repository. Its only
purpose is to be a repository for *pristine* files copied out of the aports
tree, using a workflow along the lines of:

```
# this repo
git checkout vendor-aports
rm -rf cross-images/mini-aports/main/*

# aports repo
cd ~/temp
git clone https://github.com/alpinelinux/aports
# ... takes a long time
cd aports
git checkout 3.16-stable
cp scripts/bootstrap.sh /path/to/ci-support/cross-images/mini-aports/scripts/
cd main
cp -r binutils build-base fortify-headers gcc libc-dev linux-headers musl /path/to/ci-support/cross-images/mini-aports/main/

# back to this repo
cd /path/to/ci-support
git add cross-images/mini-aports
git commit # document source commit, date, etc.

git checkout my-work-branch
git merge vendor-aports
# rebuild Docker containers
```

This framework sets things up so that *if needed*, we can apply patches to the
aports tree and track them via the Git merge process. So far this has not proved
to be necessary.

If/when the aports update is demonstrated to be necessary and correct, the
`vendor-aports` branch on GitHub should be updated.
