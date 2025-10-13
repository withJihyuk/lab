#!/bin/bash
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh

echo "installing python3-pip, oci sdk"
sudo yum install python3 -y
sudo yum install python3-pip -y
pip3 install oci
pip3 install requests

cat << 'EOF' > pyscript.py
#!/usr/bin/python
import oci
import requests

size_in_gbs = 50
vpus_per_gb = 20
mode = 'PARA'
device_path = "/dev/oracleoci/oraclevdb"

signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()

def get_current_instance_details():
    r = requests.get(url='http://169.254.169.254/opc/v2/instance', headers={"Authorization": "Bearer Oracle"})
    return r.json()

instanceDetails = get_current_instance_details()

compute_client = oci.core.ComputeClient({"region": instanceDetails["region"]}, signer=signer)
block_storage_client = oci.core.BlockstorageClient({"region": instanceDetails["region"]}, signer=signer)

def create_volume(block_storage, compartment_id, availability_domain, display_name: str):
    print("--- creating block volume ---")
    result = block_storage.create_volume(
        oci.core.models.CreateVolumeDetails(
            compartment_id=compartment_id,
            availability_domain=availability_domain,
            display_name=display_name,
            size_in_gbs=size_in_gbs,
            vpus_per_gb=vpus_per_gb
        )
    )
    volume = oci.wait_until(
        block_storage,
        block_storage.get_volume(result.data.id),
        'lifecycle_state',
        'AVAILABLE'
    ).data
    print('--- Created Volume ocid: {} ---'.format(result.data.id))
    return volume

def attach_volume(instance_id, volume_id, device_path):
    volume_attachment_response = ""
    if mode == 'ISCSI':
        print("--- Attaching block volume {} to instance {}---".format(volume_id, instance_id))
        volume_attachment_response = compute_client.attach_volume(
            oci.core.models.AttachIScsiVolumeDetails(
                display_name='IscsiVolAttachment',
                instance_id=instance_id,
                volume_id=volume_id,
                device=device_path
            )
        )
    elif mode == 'PARA':
        print("--- Attaching block volume {} to instance {} (Paravirtualized)---".format(volume_id, instance_id))
        volume_attachment_response = compute_client.attach_volume(
            oci.core.models.AttachParavirtualizedVolumeDetails(
                display_name='ParavirtualizedVolAttachment',
                instance_id=instance_id,
                volume_id=volume_id,
                device=device_path
            )
        )
    
    oci.wait_until(
        compute_client,
        compute_client.get_volume_attachment(volume_attachment_response.data.id),
        'lifecycle_state',
        'ATTACHED'
    )
    print("--- Attaching complete block volume {} to instance {}---".format(volume_id, instance_id))
    print(volume_attachment_response.data)

# 볼륨 생성 및 연결 실행
volume = create_volume(
    block_storage=block_storage_client,
    compartment_id=instanceDetails['compartmentId'],
    availability_domain=instanceDetails['availabilityDomain'],
    display_name=instanceDetails['displayName'] + '-longhorn-vol'
)
attach_volume(instance_id=instanceDetails['id'], volume_id=volume.id, device_path=device_path)
EOF

echo "running python script"
chmod 755 pyscript.py
./pyscript.py

echo "creating file system on volume"
sudo /sbin/mkfs.ext4 -L longhorn /dev/oracleoci/oraclevdb

echo "mounting volume"
sudo mkdir -p /mnt/longhorn
sudo mount /dev/oracleoci/oraclevdb /mnt/longhorn

echo "adding entry to fstab"
echo "/dev/oracleoci/oraclevdb /mnt/longhorn ext4 defaults,_netdev,nofail 0 2" | sudo tee -a /etc/fstab

echo "setting permissions for longhorn"
sudo chown -R 1000:1000 /mnt/longhorn
sudo chmod 755 /mnt/longhorn

echo "Longhorn volume setup completed!"
df -h | grep longhorn