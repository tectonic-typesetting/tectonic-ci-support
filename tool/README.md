# ttcitool

This is a utility that helps with Tectonic continuous integration and
deployment processes. It has a `git`-like multitool interface, with
the following commands:

- `upload-gh-artifact` — upload an artifact to a GitHub release, creating it
  if necessary. Unlike various tools built in to various CI systems, this
  won't mess with the release if it already exists, which is important for our
  workflow.
