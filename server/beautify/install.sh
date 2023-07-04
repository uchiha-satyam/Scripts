#! /bin/bash

if [ $(/usr/bin/id -u) -ne 0 ]
then
echo 'Need superuser privileges for proper functioning. Exiting ...'
exit
fi

echo 'Making your prompt beautiful ...'

starship_url='https://starship.rs/install.sh'
font_url='https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip'
font_path='/usr/share/fonts/truetype/'
configure_command='eval "$(/usr/local/bin/starship init bash)"'
root_path='/root'
home_path=$(pwd)

which curl
if [ $? -ne 0 ]
then
echo 'curl not found. Installing curl ...'
yes | yum install curl
echo 'curl Installed !'
fi

which wget
if [ $? -ne 0 ]
then
echo 'wget not found. Installing wget ...'
yes | yum install wget
echo 'wget Installed !'
fi

which unzip
if [ $? -ne 0 ]
then
echo 'unzip not found. Installing unzip ...'
yes | yum install unzip
echo 'unzip Installed !'
fi

echo 'Downloading FiraCode Nerd Font ...'
wget $font_url
echo 'Download Complete !'

echo 'Unzipping FiraCode ...'
unzip FiraCode.zip -d FiraCode
echo 'FiraCode unzipped !'

echo 'Removing FiraCode.zip ...'
rm FiraCode.zip
echo 'Removed FiraCode.zip !'

echo 'Installing FiraCode ...'
ls $font_path
if [ $? -ne 0 ]
then
mkdir $font_path
fi
cp FiraCode/*.ttf $font_path
echo 'FiraCode Installed !'

echo 'Removing FiraCode fonts ...'
rm -rf FiraCode
echo 'Removed FiraCode fonts !'

echo 'Installing starship ...'
wget -O starshipInstall.sh $starship_url
sh starshipInstall.sh
echo 'starship Installed !'

echo 'Configuring starship for root user ...'
cat $root_path/.bashrc
if [ $? -ne 0 ]
then
touch $root_path/.bashrc
fi
echo $configure_command >> $root_path/.bashrc
echo 'Done !'

echo 'Configuring starship for local user ...'
cat $home_path/.bashrc
if [ $? -ne 0 ]
then
touch $home_path/.bashrc
fi
echo $configure_command >> $home_path/.bashrc
echo 'Done !'

echo 'Congratulations, prompt beautified !'
echo 'Just restart the terminal to see MAGIC !'
