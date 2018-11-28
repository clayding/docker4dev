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
sed -i "s#@@LM_KERNEL_SOURCE_URL@@#$5#" /home/builder/.bashrc
sed -i "s#@@LM_UBOOT_SOURCE_URL@@#$6#" /home/builder/.bashrc
sed -i "s#@@LM_TOOLSCHAIN_URL@@#$7#" /home/builder/.bashrc

build_dir=$3
source_dir=$4
toolchain_dir=$7
chown -R builder: $source_dir $toolchain_dir
echo "Sourcedir:$source_dir"
echo "Toolchaindir:$toolchain_dir"

git_str=`echo $5 | grep ".git"`
if [ "$git_str" == "" ];then
    sed -i "s#@@LM_KERNEL_SOURCE_DIR@@#$5#" /home/builder/.bashrc
else
    kernel_url=`echo $5 | awk -F";branch=" '{print $1}'` 
    kernel_branch=`echo $5 | awk -F";branch=" '{print $2}' | awk -F";" '{print $1}' `
    kernel_dir=`echo $kernel_url | awk -F".git" '{print $1}' | awk -F"/" '{print $NF}'`
    echo "Kernelurl:$kernel_url"
    echo "Kernelbranch:$kernel_branch"
    echo "Kerneldir:$source_dir/$kernel_dir"
    if [ $kernel_url ];then
        tmp_path=$PWD
        echo "Clone the kernel source from $kernel_url"
        cd $source_dir && git clone $kernel_url 
        cd $kernel_dir
        sed -i "s#@@LM_KERNEL_SOURCE_DIR@@#"$source_dir/$kernel_dir"#" /home/builder/.bashrc
        git checkout -b $kernel_branch remotes/origin/$kernel_branch
        cd $tmp_path
    fi
fi
u_boot_url=""
git_str=`echo $6 | grep ".git"`
if [ "$git_str" == "" ];then
    sed -i "s#@@LM_UBOOT_SOURCE_DIR@@#$6#" /home/builder/.bashrc
else
    u_boot_url=`echo $6 | awk -F";branch=" '{print $1}'` 
    u_boot_branch=`echo $6 | awk -F";branch=" '{print $2}' | awk -F";" '{print $1}'`
    u_boot_dir=`echo $u_boot_url | awk -F".git" '{print $1}' | awk -F"/" '{print $NF}'`
    echo "Ubooturl:$u_boot_url"
    echo "Ubootbranch:$u_boot_branch"
    echo "Ubootdir:$source_dir/$u_boot_dir"
    if [ $u_boot_url ];then
        tmp_path=$PWD
        echo "Clone the uboot source from $u_boot_url"
        cd $source_dir && git clone $u_boot_url 
        cd $u_boot_dir
        sed -i "s#@@LM_UBOOT_SOURCE_DIR@@#"$source_dir/$u_boot_dir"#" /home/builder/.bashrc
        git checkout -b $u_boot_branch remotes/origin/$u_boot_branch
        cd $tmp_path
    fi
fi


# Start builder
if [ "$8" != "" ] ; then
    su - builder -c "$8"
    exit $?
fi

su - builder

#do something when exit
echo "Delete all files in $build_dir and external source or toolchain"
rm $build_dir/*  $build_dir/../externalsrc  $build_dir/../toolchain/external -rf
