#!/bin/bash
set -e
APPNAME=gotestapp

cd /home/ec2-user/services/$APPNAME/
rm -f $APPNAME
/usr/local/go/bin/go build -o $APPNAME

./$APPNAME -port=9001
