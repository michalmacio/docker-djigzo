FROM debian:stable-slim

ENV HOME /root
ENV DJIGZO_VERSION 4.3.0-1
RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done

RUN echo "deb http://deb.debian.org/debian oldstable main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install postgresql postfix openjdk-8-jre openjdk-8-jre-headless ant ant-optional libsasl2-modules symlinks wget symlinks sudo tomcat8 coreutils -yq && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8 && \
    adduser --system --group --home /usr/local/djigzo --disabled-password --shell /bin/false djigzo && \
    usermod -a -G adm djigzo && \
    mkdir /usr/local/djigzo-web && \
    chown djigzo:djigzo /usr/local/djigzo-web && \
    apt-get autoremove -y && \
    apt-get clean

# download and install djigzo packages
WORKDIR /tmp
RUN wget https://www.ciphermail.com/downloads/djigzo-release-${DJIGZO_VERSION}/djigzo_${DJIGZO_VERSION}_all.deb && \
    wget https://www.ciphermail.com/downloads/djigzo-release-${DJIGZO_VERSION}/djigzo-web_${DJIGZO_VERSION}_all.deb && \
    wget https://www.ciphermail.com/downloads/djigzo-release-${DJIGZO_VERSION}/djigzo-postgres_${DJIGZO_VERSION}_all.deb && \
    sudo dpkg -i djigzo_${DJIGZO_VERSION}_all.deb && \
    rm djigzo_${DJIGZO_VERSION}_all.deb && \
    sudo service postgresql start && \
    sudo dpkg -i djigzo-postgres_${DJIGZO_VERSION}_all.deb && \
    rm djigzo-postgres_${DJIGZO_VERSION}_all.deb && \
    sudo service djigzo restart && \
    sudo dpkg -i djigzo-web_${DJIGZO_VERSION}_all.deb && \
    rm djigzo-web_${DJIGZO_VERSION}_all.deb && \
    apt-get clean

# configure postfix
RUN sudo cp /etc/postfix/djigzo-main.cf /etc/postfix/main.cf && \
    sudo cp /etc/postfix/djigzo-master.cf /etc/postfix/master.cf && \
    sudo newaliases && \
    sudo service postfix restart

# configure tomcat8
RUN sudo bash -c 'echo "JAVA_OPTS=\"\$JAVA_OPTS -Ddjigzo-web.home=/usr/share/djigzo-web -Ddjigzo.home=/usr/share/djigzo\"" >> /etc/default/tomcat8' && \
    sudo bash -c 'echo "JAVA_OPTS=\"\$JAVA_OPTS -Djava.awt.headless=true -Xmx128M\"" >> /etc/default/tomcat8' && \
    sudo chown tomcat8:djigzo /usr/share/djigzo-web/ssl/sslCertificate.p12 && \
    sudo cp /usr/share/djigzo-web/conf/tomcat/server.xml /etc/tomcat8/ && \
    sudo sed -i 's/unpackWARs="false"/unpackWARs="true"/' /etc/tomcat8/server.xml && \
    sudo bash -c 'echo "<Context docBase=\"/usr/share/djigzo-web/djigzo.war\" />" > /etc/tomcat8/Catalina/localhost/ciphermail.xml' && \
    sudo bash -c 'echo "<Context docBase=\"/usr/share/djigzo-web/djigzo-portal.war\" />" > /etc/tomcat8/Catalina/localhost/web.xml'
    
    
# download sqlplus client and JDBC drivers
  
add ojdbc6.jar /usr/share/tomcat8/lib
add ojdbc7.jar /usr/share/tomcat8/lib
add orai18n.jar   /usr/share/tomcat8/lib

add ojdbc6.jar /usr/share/java
add ojdbc7.jar /usr/share/java
add orai18n.jar   /usr/share/java

add ojdbc6.jar /usr/share/djigzo/lib/lib.d
add ojdbc7.jar /usr/share/djigzo/lib/lib.d
add orai18n.jar   /usr/share/djigzo/lib/lib.d



#configure Ciphermail for Oracle 
sudo sed  /usr/share/djigzo/wrapper/wrapper-additional-parameters.conf


# download keystores
WORKDIR /usr/local/djigzo/resources/certificates
RUN wget https://www.ciphermail.com/downloads/roots.p7b && \
    wget https://www.ciphermail.com/downloads/intermediates.p7b && \
    chown -R djigzo:djigzo ./

# RUN mkdir /run/tomcat8 && chown -R tomcat8:tomcat8 /run/tomcat8 && sed -i 's/\/var\/run\/\$NAME.pid/\/var\/run\/tomcat8\/\$NAME.pid/' /etc/init.d/tomcat8

ADD init.sh /root/init.sh
RUN chmod +x /root/init.sh

EXPOSE 25
EXPOSE 8443
VOLUME ["/var/lib/postgresql"]

WORKDIR /root

CMD /root/init.sh
