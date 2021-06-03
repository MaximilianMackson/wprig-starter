FROM ubuntu:21.04

ENV TZ=Europe/Bucharest
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y software-properties-common apt-utils \
    # && add-apt-repository ppa:ondrej/php \
    # && apt-get update -y \
    && apt-get install -y php7.4 \
    && apt-get install -y php-pear php7.4-curl php7.4-dev php7.4-gd php7.4-mbstring php7.4-zip php7.4-mysql php7.4-xml

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash \
    && apt-get install -y nodejs

RUN apt-get install -y unzip

COPY init.sh /usr/src/init.sh

RUN mkdir /usr/src/theme

WORKDIR /usr/src/theme

EXPOSE 8080 3001

CMD [ "bash", "./../init.sh" ]