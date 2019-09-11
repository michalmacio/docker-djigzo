#!/bin/bash

#configure database connection
sudo 'echo "<property name=\"hibernate.connection.url\">jdbc:oracle:thin:@tdgdadelta123:1521:DUPA</property><property name=\"hibernate.connection.username\">djigzo</property><property name=\"hibernate.connection.password\">djigzo</property>"' > /usr/share/djigzo/conf/database/hibernate.oracle.connection.xml

/etc/init.d/postgresql start
/etc/init.d/djigzo start
/etc/init.d/tomcat8 start

tail -f /dev/null
