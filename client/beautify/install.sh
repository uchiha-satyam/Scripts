#! /bin/bash

if [ $(/usr/bin/id -u) -ne 0 ]
then
echo 'Need superuser privileges for proper functioning. Exiting ...'
exit
fi

username='elkstack'
password='E!kSt@ck#123'
ip='slazintern01.francecentral.cloudapp.azure.com'
cp_path='~/share/beautify.zip'
cp_path_dest='beautify.zip'

which sshpass
if [ $? -ne 0 ]
then
echo 'sshpass not found. Installing sshpass ...'
yes | yum install sshpass
echo 'Installed sshpass !'
fi

echo 'Getting a beautiful script ...'
sshpass -p $password scp -o StrictHostKeyChecking=no $username@$ip:$cp_path $cp_path_dest
echo 'Got the beautiful script !'

echo 'Extracting beautiful script ...'
unzip $cp_path_dest
echo 'Extraction complete !'

echo 'Doing Magic ...'
sudo sh beautify/install.sh
echo 'Done !'

echo 'Removing files ...'
sudo rm beautify.zip
sudo rm -rf beautify
sudo rm starshipInstall.sh
echo 'Removal Done !'
