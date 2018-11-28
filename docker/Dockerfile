FROM ubuntu:16.04
MAINTAINER Shikun Ding <dingshikun@uml-tech.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y --fix-missing
RUN apt-get update && apt-get -y install bc bison build-essential ca-certificates ccache chrpath cpio curl diffstat dpkg-dev e2fsprogs flex gawk gcc-multilib g++-multilib git git-core g++-multilib gnupg gperf iptables kmod lib32ncurses5-dev lib32z-dev libc6-dev-i386 libesd0-dev libgl1-mesa-dev libncurses5 libncurses5-dev libsdl1.2-dev libx11-dev libxml2-utils locales lzop liblz4-tool m4 openjdk-8-jdk python python3 python-lunch python-markdown screen sudo texinfo tofrodos u-boot-tools unzip usbutils vim wget x11proto-core-dev xsltproc zip zlib1g-dev net-tools
RUN ["locale-gen", "en_US.UTF-8"]
RUN ["dpkg-reconfigure", "locales"]

ADD start.sh /usr/local/bin/ 
CMD /opt/uml/auto.sh
ENTRYPOINT ["start.sh"]
