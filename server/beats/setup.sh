#! /bin/bash

echo 'Installing and configuring Metricbeat & Filebeat ...'

metricbeat_path='beats/rpm/metricbeat-8.8.0-x86_64.rpm'
filebeat_path='beats/rpm/filebeat-8.8.0-x86_64.rpm'
metricbeat_config_http='beats/config/metricbeat-http.yml'
metricbeat_config_https='beats/config/metricbeat-https.yml'
metricbeat_config_dest='/etc/metricbeat/metricbeat.yml'
filebeat_config_http='beats/config/filebeat-http.yml'
filebeat_config_https='beats/config/filebeat-https.yml'
filebeat_config_dest='/etc/filebeat/filebeat.yml'
metric_modules='beats/modules/metricbeat/*.yml'
metric_modules_dest='/etc/metricbeat/modules.d/'
file_modules='beats/modules/filebeat/*.yml'
file_modules_dest='/etc/filebeat/modules.d/'

echo 'Installing metricbeat ...'
yes | rpm -vi $metricbeat_path
echo 'Metricbeat installed !'

echo 'Installing filebeat ...'
yes | rpm -vi $filebeat_path
echo 'Filebeat installed !'

echo 'Enabling services ...'
systemctl enable metricbeat
systemctl enable filebeat
echo 'Services enabled !'

echo 'Configuring metricbeat & filebeat ...'
echo 'Enter metric_api_key: '
read metric_api_key
echo 'Setting metric-api-key ...'
echo $metric_api_key | metricbeat keystore add api_key --stdin --force

echo 'Enter file_api_key: '
read file_api_key
echo 'Setting file-api-key ...'
echo $file_api_key | filebeat keystore add api_key --stdin --force

echo 'Enter elastic_host (complete address with port number & without http/https): '
read elastic_host
echo 'Enter kibana_host (complete address with port number & without http/https): '
read kibana_host

echo 'Setting elastic-host & kibana-host ...'
echo $elastic_host | metricbeat keystore add elastic_host --stdin --force
echo $elastic_host | filebeat keystore add elastic_host --stdin --force
echo $kibana_host | metricbeat keystore add kibana_host --stdin --force
echo $kibana_host | filebeat keystore add kibana_host --stdin --force

echo 'Enabling modules ...'
metricbeat modules enable elasticsearch
metricbeat modules enable elasticsearch-xpack
metricbeat modules enable kibana
metricbeat modules enable kibana-xpack
metricbeat modules enable linux
metricbeat modules enable system
filebeat modules enable elasticsearch
filebeat modules enable kibana
filebeat modules enable system
echo 'Modules enabled !'

echo 'Copying config files -> /etc/ ...'
echo 'Do you want to use https protocol ? (y/n) '
read yn
if [ $yn = 'y' ]
then
echo 'https selected !'
\cp -r $metricbeat_config_https $metricbeat_config_dest
\cp -r $filebeat_config_https $filebeat_config_dest
else
echo 'http selected !'
\cp -r $metricbeat_config_http $metricbeat_config_dest
\cp -r $filebeat_config_http $filebeat_config_dest
fi

\cp -r $metric_modules $metric_modules_dest
\cp -r $file_modules $file_modules_dest
echo 'Files copied !'

echo 'Setting permissions ...'
chown root:root $metricbeat_config_dest
chown root:root $filebeat_config_dest
chown root:root $metric_modules_dest*.yml
chown root:root $file_modules_dest*.yml
echo 'Permissions set !'

echo 'Starting Metricbeat & Filebeat ...'
systemctl start metricbeat.service
systemctl start filebeat.service
echo 'Metricbeat & Filebeat started !'

echo 'Metricbeat & Filebeat installed and configured !'
