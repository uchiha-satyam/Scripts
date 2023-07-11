# Straship automatic installer

Place the python_scripts folder anywhere on any machine and run the connector.py script for alerts.

# Configuration

Change the values in config/config.cfg according to your setup to configure the script to your needs.

- python-api section stores the api-key and api-id for a new api-key for elastic superuser ( or any other user with appropriate permissions to access the kibana index where alerts are being stored).
- webhook section stores the url for the teams webhook which will send the alerts.
- smtp section stores data regarding smtp server.

# Pre-Requisites

Your system must have python installed. To check run in terminal:

``` which python3 ```

If you get output as a path like ``` /usr/bin/python3 ```, then you are good to go else you need to install python3 using command:

``` sudo yum install python3 ```

# Commands

From python_scripts directory run the following in terminal:

``` python3 -u connector.py > files/output.log & ```

This will run the script in background & store its log in ``` files/output.log ```, but if you want to run this process in foreground then just run:

``` python3 connector.py ```

# Author

## Satyam Abhishek