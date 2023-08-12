##Update below information according to your infra 
Openstack_Version='2023.1'
Openstack_VIP='172.90.0.201'
Internal_NIC_Name='ens192'
External_NIC_Name='ens224'

#openstack multi node deployment
yum update -y
dnf install git python3-devel libffi-devel gcc openssl-devel python3-libselinux -y
dnf install python3-pip -y
pip3 install -U pip
pip install 'ansible-core>=2.13,<=2.14.2'
pip install 'ansible>=6,<8'
pip3 install git+https://opendev.org/openstack/kolla-ansible@stable/$Openstack_Version --ignore-installed requests
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp /usr/local/share/kolla-ansible/ansible/inventory/* .
cd /etc/kolla
kolla-ansible install-deps
mkdir -p /etc/ansible
cat << EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF

kolla-genpwd
cp /usr/local/share/kolla-ansible/ansible/inventory/* .
cd /etc/kolla
echo "kolla_internal_vip_address: "$Openstack_VIP"" >> globals.yml
echo "network_interface: "$Internal_NIC_Name"" >> globals.yml
echo "neutron_external_interface: "$External_NIC_Name"" >> globals.yml
echo "enable_cinder: "yes"" >> globals.yml >> globals.yml
echo "nova_compute_virt_type: "qemu"" >> globals.yml
echo "enable_grafana: "yes"" >> globals.yml
echo "enable_prometheus: "yes"" >> globals.yml
echo "enable_skyline: "yes"" >> globals.yml
echo "neutron_plugin_agent: "ovn"" >> globals.yml
echo "enable_hacluster: "yes"" >> globals.yml
echo "glance_backend_ceph: "yes"" >> globals.yml
echo "cinder_backend_ceph: "yes"" >> globals.yml
echo "nova_backend_ceph: "yes"" >> globals.yml
echo "enable_masakari: "yes"" >> globals.yml 
echo "enable_freezer: "yes"" >> globals.yml
echo "enable_sahara: "yes"" >> globals.yml
echo "enable_trove: "yes""  >> globals.yml
echo "glance_backend_file: "no"" >> globals.yml
echo "enable_magnum: "yes"" >> globals.yml
echo "enable_cluster_user_trust: true" >> globals.yml
echo "enable_mariabackup: "yes"" >> globals.yml


## If you're having more than 3 controllers and compute, update the below details 
sed -i '6,7 s/^/#/' multinode
sed -i '5s/control01/controller[0:2]/' multinode
sed -i '15s/network01/controller[0:2]/' multinode
sed -i '16s/network02/compute[0:1]/' multinode
sed -i '19s/compute01/compute[0:1]/' multinode
sed -i '22s/monitoring01/controller[0:2]/' multinode
sed -i '23 i compute[0:1]' multinode
sed -i '31s/storage01/controller[0:2]/' multinode
sed -i '32 i compute[0:1]' multinode



mkdir -p /etc/kolla/config/{glance,nova,cinder}
mkdir -p /etc/kolla/config/cinder/cinder-backup
mkdir -p /etc/kolla/config/cinder/cinder-volume
mkdir -p /etc/cinder
mkdir -p /etc/kolla/cinder


cat << EOF > /etc/kolla/config/glance/glance-api.conf
[DEFAULT]
show_image_direct_url = True

[glance_store]
stores = rbd
default_store = rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8
EOF


cat << EOF > /etc/kolla/cinder/cinder.conf
[DEFAULT]
...
enabled_backends = ceph
glance_api_version = 2
...
[ceph]
rbd_user = cinder
volume_driver = cinder.volume.drivers.rbd.RBDDriver
volume_backend_name = ceph
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
EOF


cat << EOF > /etc/cinder/cinder.conf
[DEFAULT]
backup_driver = cinder.backup.drivers.ceph.CephBackupDriver
backup_ceph_conf = /etc/ceph/ceph.conf
backup_ceph_user = cinder-backup
backup_ceph_chunk_size = 134217728
backup_ceph_pool = backups
backup_ceph_stripe_unit = 0
backup_ceph_stripe_count = 0
restore_discard_excess_bytes = true
[libvirt]
rbd_user = cinder
EOF

pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/$Openstack_Version
pip install python-magnumclient
pip install python-glanceclient

