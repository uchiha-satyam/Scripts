#! /bin/bash

if [ $(/usr/bin/id -u) -ne 0 ]
then
echo 'Need superuser privileges for proper functioning. Exiting ...'
exit
fi

username='elkstack'
password='E!kSt@ck#123'
ip='slazintern01.francecentral.cloudapp.azure.com'
cp_path='~/share/beats.zip'
cp_path_dest='beats.zip'

which sshpass
if [ $? -ne 0 ]
then
echo 'sshpass not found. Installing sshpass ...'
yes | yum install sshpass
echo 'Installed sshpass !'
fi

echo 'Getting beats installer script ...'
sshpass -p $password scp -o StrictHostKeyChecking=no $username@$ip:$cp_path $cp_path_dest
echo 'Got the beats installer script !'

echo 'Extracting beats script ...'
unzip $cp_path_dest
echo 'Extraction complete !'

echo 'Starting script ...'
sudo sh beats/setup.sh
echo 'Done !'

echo 'Removing files ...'
sudo rm $cp_path_dest
sudo rm -rf beats
echo 'Removal Done !'
