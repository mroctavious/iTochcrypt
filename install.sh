#!/bin/bash

##Install virtual enviroment to avoid problems with other enviroments
pip install virtualenv

##Create new enviroment
virtualenv iTochcrypt

##Install the libraries needed
iTochcrypt/bin/pip install sympy flask flask_restful flask_httpauth pymysql

echo "Install ready :)"
