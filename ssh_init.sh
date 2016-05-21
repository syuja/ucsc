docker run -h hive -v /vault/ssh:/home -p 23:22 -it centos:7 bash

yum update -y
yum update -y && yum install -y openssh-server openssh-clients.x86_64 rsync chkconfig coreutils curl findutils gawk glibc-common grep initscripts lsof net-tools rpm shadow-utils tar util-linux which yum authconfig policycoreutils-python


sed -i 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config
sed -i 's/#TCPKeepAlive/TCPKeepAlive/g' /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 540/g' /etc/ssh/sshd_config

ssh-keygen -A

/usr/sbin/sshd

curl --silent --show-error --header 'x-connect-key: 14c7ef9a1f651492c3ed64b949d7934d06058ff6' https://kickstart.jumpcloud.com/Kickstart | bash

/etc/init.d/jcagent start
