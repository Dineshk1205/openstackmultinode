#Update Deployment IP 
DeploymentIP= "172.90.0.33"
ceph osd pool create volumes
ceph osd pool create images
ceph osd pool create backups
ceph osd pool create vms
rbd pool init volumes
rbd pool init images
rbd pool init backups
rbd pool init vms

ceph auth get-or-create client.glance mon 'profile rbd' osd 'profile rbd pool=images' mgr 'profile rbd pool=images'

ceph auth get-or-create client.cinder mon 'profile rbd' osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd-read-only pool=images' mgr 'profile rbd pool=volumes, profile rbd pool=vms'

ceph auth get-or-create client.cinder-backup mon 'profile rbd' osd 'profile rbd pool=backups' mgr 'profile rbd pool=backups'

ssh-copy-id root@$DeploymentIP
scp -r /etc/ceph/ceph.conf root@$DeploymentIP:/etc/kolla/config/cinder/cinder-backup/ceph.conf
scp -r /etc/ceph/ceph.conf root@$DeploymentIP:/etc/kolla/config/cinder/cinder-volume/ceph.conf
scp -r /etc/ceph/ceph.conf root@$DeploymentIP:/etc/kolla/config/glance/ceph.conf
scp -r /etc/ceph/ceph.conf root@$DeploymentIP:/etc/kolla/config/nova/ceph.conf

ceph auth get-or-create client.cinder-backup  > /etc/ceph/ceph.client.cinder-backup.keyring
ceph auth get-or-create client.cinder > /etc/ceph/ceph.client.cinder.keyring
ceph auth get-or-create client.glance > /etc/ceph/ceph.client.glance.keyring



scp -r /etc/ceph/ceph.client.glance.keyring root@$DeploymentIP:/etc/kolla/config/glance/ceph.client.glance.keyring
scp -r /etc/ceph/ceph.client.cinder-backup.keyring  root@$DeploymentIP:/etc/kolla/config/cinder/cinder-backup/ceph.client.cinder-backup.keyring 
scp -r /etc/ceph/ceph.client.cinder.keyring  root@$DeploymentIP:/etc/kolla/config/cinder/cinder-backup/ceph.client.cinder.keyring
scp -r /etc/ceph/ceph.client.cinder.keyring  root@$DeploymentIP:/etc/kolla/config/cinder/cinder-volume/ceph.client.cinder.keyring
scp -r /etc/ceph/ceph.client.cinder.keyring  root@$DeploymentIP:/etc/kolla/config/nova/ceph.client.cinder.keyring



