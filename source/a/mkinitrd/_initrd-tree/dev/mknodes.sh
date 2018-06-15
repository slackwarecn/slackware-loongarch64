# Run this script in the root of the skeleton tree
# to re-create the required device nodes
mkdir -p dev
mknod -m 644 dev/systty c 4 0
mkdir -p dev
mknod -m 644 dev/tty1 c 4 1
mkdir -p dev
mknod -m 644 dev/ram b 1 1
mkdir -p dev
mknod -m 644 dev/tty2 c 4 1
mkdir -p dev
mknod -m 644 dev/tty3 c 4 1
mkdir -p dev
mknod -m 644 dev/null c 1 3
mkdir -p dev
mknod -m 644 dev/tty4 c 4 1
mkdir -p dev
mknod -m 644 dev/console c 5 1
