#!/bin/bash

/etc/init.d/postgresql start
/etc/init.d/djigzo start
/etc/init.d/tomcat6 start

tail -f /dev/null
