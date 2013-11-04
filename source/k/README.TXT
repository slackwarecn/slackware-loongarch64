Since I should document this somewhere, here's the procedure
for building the Slackware kernel package.  I do not patch the official
kernel sources, but it's not exactly a virgin either.

=============================================================
Version specific notes (if any):
=============================================================

For a 2.6.x kernel (much easier):

   Untar Linus' source in /usr/src.
   Make all files owned by root:root with reasonable perms.
   Install a suitable .config, or use make menuconfig, etc.

   An example would be to use one of the config files here:
   # cat config-generic-3.10.17 > /usr/src/linux-3.10.17/.config

   Then run the build programs:

   make oldconfig
   make bzImage
   make clean
   make prepare
   rm .version

That's it!  You now have a clean Slackware-configured Linux source
tree.

The kernel in Slackware supports SMP.  With as common as
multicore CPUs and SMP boards have become, this seemed like the
obvious choice.  The kernels are probably better for single CPU
machines, too, if they will run them.

At this point if you are running huge.s or generic.s, you should have
no problems building kernel modules.

Have fun! :-)

Pat

