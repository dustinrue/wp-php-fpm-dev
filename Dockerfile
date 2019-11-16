ARG PHP_VERSION=7.3
FROM dustinrue/wp-php-fpm:${PHP_VERSION}

ARG PHP_VERSION=7.3

USER root
RUN yum install \
  php-pecl-xdebug \
  mariadb \
  nc \
  wget \
  git \
  strace \
  telnet \
  rsync \
  vim \
  unzip -y && yum clean all

WORKDIR /
COPY scripts/composer-installer.sh /composer-installer.sh
RUN sh /composer-installer.sh && mv /composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp
RUN echo "catch_workers_output = yes" >> /etc/php-fpm.d/www.conf

# entrypoint needs to manage the PHP config but will be running as www-data
# Get things setup and then rw-own the files necessary to allow this
RUN  mkdir /etc/php-extensions-available; \
  mv /etc/php.d/15-xdebug.ini /etc/php-extensions-available; \
  chown www-data -R /etc/php*

COPY entrypoint-dev.sh /
RUN chmod +x /entrypoint-dev.sh

USER www-data
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash && \
  source ~/.bashrc && \
  nvm install --lts
WORKDIR /var/www/html

ENTRYPOINT ["/entrypoint-dev.sh"]
