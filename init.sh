#!/bin/bash

/etc/init.d/postgresql start
/etc/init.d/djigzo start
/etc/init.d/tomcat8 start

tail -f /dev/null
