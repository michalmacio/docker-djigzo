#!/bin/bash

set -e

/etc/init.d/djigzo start
/etc/init.d/tomcat6 start

while true
do
 sleep 60
done
