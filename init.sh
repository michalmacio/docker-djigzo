#!/bin/bash

set -e

/etc/init.d/djigzo start
/etc/init.d/tomcat6 start

tail -f /usr/local/djigzo/logs/james.wrapper.log
