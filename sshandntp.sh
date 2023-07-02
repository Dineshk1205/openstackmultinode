# SSH Key generation and copy ssh to other nodes 
ssh-keygen
ssh-copy-id root@controller0
ssh-copy-id root@controller1
ssh-copy-id root@controller2
ssh-copy-id root@compute0
ssh-copy-id root@compute1 
sed 's/^pool/#&/' -i /etc/chrony.conf
echo -e "pool 0.in.pool.ntp.org  iburst \nallow 172.90.0.0/24 " >> /etc/chrony.conf
systemctl enable chronyd&&systemctl restart chronyd
scp -r /etc/chrony.conf root@controller0:/etc/chrony.conf
scp -r /etc/chrony.conf root@controller1:/etc/chrony.conf
scp -r /etc/chrony.conf root@controller2:/etc/chrony.conf
scp -r /etc/chrony.conf root@compute0:/etc/chrony.conf
scp -r /etc/chrony.conf root@compute1:/etc/chrony.conf
ssh root@controller0 'systemctl enable chronyd&&systemctl restart chronyd'
ssh root@controller1 'systemctl enable chronyd&&systemctl restart chronyd'
ssh root@controller2 'systemctl enable chronyd&&systemctl restart chronyd'
ssh root@compute0 'systemctl enable chronyd&&systemctl restart chronyd'
ssh root@compute1 'systemctl enable chronyd&&systemctl restart chronyd'
