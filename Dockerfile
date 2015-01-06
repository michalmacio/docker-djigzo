FROM ubuntu:14.04


RUN apt-get update
RUN apt-get upgrade -yq
RUN apt-get install postgresql postfix openjdk-7-jre openjdk-7-jre-headless tzdata-java ant ant-optional mktemp wget libsasl2-modules symlinks sudo -yq
RUN wget https://www.ciphermail.com/downloads/djigzo-release-2.9.0-0/djigzo-web_2.9.0-0_all.deb
RUN wget https://www.ciphermail.com/downloads/djigzo-release-2.9.0-0/djigzo_2.9.0-0_all.deb

RUN /etc/init.d/postgresql start


RUN adduser --system --group --home /usr/local/djigzo --disabled-password --shell /bin/false djigzo
RUN usermod -a -G adm djigzo

RUN mkdir /usr/local/djigzo-web
RUN chown djigzo:djigzo /usr/local/djigzo-web

WORKDIR /root

RUN wget https://www.ciphermail.com/downloads/djigzo-release-2.9.0-0/djigzo_2.9.0-0.tar.gz
RUN wget https://www.ciphermail.com/downloads/djigzo-release-2.9.0-0/djigzo-web_2.9.0-0.tar.gz

RUN sudo -H -u djigzo tar zxvf djigzo_2.9.0-0.tar.gz --directory /usr/local/djigzo
RUN sudo -H -u djigzo tar zxvf djigzo-web_2.9.0-0.tar.gz --directory /usr/local/djigzo-web

WORKDIR /var/lib/postgresql/9.3/main

RUN echo "CREATE USER djigzo NOCREATEUSER NOCREATEDB ENCRYPTED PASSWORD 'md5b720bc9de4ca53d53a4059882a0868b9';" | sudo -u -H postgres psql
RUN sudo -H -u postgres createdb --owner djigzo djigzo

RUN cd /usr/local/djigzo && sudo -u djigzo ant

RUN sudo -u djigzo djigzo psql djigzo < /usr/local/djigzo/conf/djigzo.sql
RUN bash -c 'echo "DJIGZO_HOME=/usr/local/djigzo" >> /etc/default/djigzo
RUN ln -s /usr/local/djigzo/scripts/djigzo /etc/init.d/

RUN /etc/init.d/postgresql stop

CMD /bin/bash
