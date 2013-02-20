This script generates PKGBUILDs for installing riak on archlinux based on some parameters.

This was made so that multiple riak nodes can be installed on a single system, without needing to manually change their data directory locations and configs.

Usage
=====

The generate.sh script generates a PKGBUILD and other files required and puts it in a directory named build.

If no arguments are passed, it tries to read the config from release.conf in this directory.

If clean is passed as 1st argument, then the build directory is removed.

If some other argument is passed, say `sample`, then a file named `sample.conf` is searched for in a directory named release.conf.d, and the config is taken from there.

