#!/bin/bash

if [ "$3" == "" ] ; then
    echo "A build directory must be specified!"
    exit 1
fi

# create a group with a proper id, in case it doesn't exist
if ! cat /etc/group | grep ":$2:" > /dev/null 2>&1 ; then
    groupadd -g $2 builder
fi

# Add uid, gid for builder, in case it doesn't exist
if ! cat /etc/passwd | grep ":$1:" > /dev/null 2>&1 ; then
    useradd -m -u $1 -g $2 -s /bin/bash builder
fi

# Use bash as the default shell
ln -sf /bin/bash /bin/sh

# Zap the password for builder
[ -e /etc/shadow ] && sed -i 's%^builder:.:%builder::%' /etc/shadow
[ -e /etc/passwd ] && sed -i 's%^builder:x:%builder::%' /etc/passwd

echo -e "\n# Builder privilege specification\nbuilder ALL=NOPASSWD: ALL" >> /etc/sudoers

[ -c "$(tty)" ] && chmod a+rw $(tty)

cp -rp /opt/uml/docker/home /
chown -R builder: /home/builder

chmod 700 /home/builder/.gnupg
chmod 600 /home/builder/.gnupg/gpg.conf

# Set correct variables according to the passed parameters
sed -i "s#@@BUILD_DIR@@#$3#" /home/builder/.bashrc
sed -i "s#@@SOURCE_DIR@@#$4#" /home/builder/.bashrc

build_dir=$3
source_dir=$4

echo -e "\033[32m[Sourcedir]:$source_dir \033[0m"

# Start builder
if [ "$8" != "" ] ; then
    su - builder -c "$8"
    exit $?
fi

chown -R builder: $source_dir
su - builder

#do something when exit
echo "Delete all files in $build_dir and external source or toolchain"
