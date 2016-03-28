
######################
### NETWORK ##########
######################

# iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
# iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
# service iptables save
# service iptables restart
# sed -i 's/enforcing/disabled/g' /etc/selinux/config
# echo 0 > /selinux/enforce
