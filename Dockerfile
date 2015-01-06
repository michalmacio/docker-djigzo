FROM ubuntu:14.04

WORKDIR /root

RUN apt-get update
RUN apt-get upgrade -yq

RUN apt-get install postgresql postfix openjdk-6-jre openjdk-6-jre-headless tzdata-java ant ant-optional mktemp wget libsasl2-modules gdebi-core -yq
RUN wget https://www.ciphermail.com/downloads/djigzo-release-2.9.0-0/djigzo-web_2.9.0-0_all.deb
RUN wget https://www.ciphermail.com/downloads/djigzo-release-2.9.0-0/djigzo_2.9.0-0_all.deb

RUN service postgresql start

RUN gdebi -n djigzo_2.9.0-0_all.deb
RUN gdebi -n djigzo-web_2.9.0-0_all.deb

RUN apt-get install -f

RUN service postgresql stop

CMD /bin/bash
