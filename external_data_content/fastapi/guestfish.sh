sudo mkdir -p /var/www/html/{3}
echo ${2} > /var/www/html/{3}/authorized_keys
guestfish add ${1} : run : mount /dev/sda2 / : copy-in /home/www/html/{3}/authorized_keys /home/user/.ssh/ : chown 1000 1000 /home/user/.ssh
