ARG PHP_VERSION=7.3
FROM docker.10up.com/10up-systems/official-docker/centos-8/base-php:${PHP_VERSION}-latest

ARG PHP_VERSION=7.3

USER root
RUN yum install php-fpm \
  php-pecl-xdebug \
  mariadb \
  nc \
  wget \
  git \
  unzip -y && yum clean all

RUN mkdir -p /run/php-fpm && chown 33:33 $_ && chown 33:33 /var/log/php-fpm
RUN sed -i 's/;clear_env = no/clear_env = no/' /etc/php-fpm.d/www.conf
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /etc/php-fpm.d/www.conf
RUN sed -i 's/^listen.allowed_clients = 127.0.0.1/;listen.allowed_clients = 127.0.0.1/' /etc/php-fpm.d/www.conf
RUN echo "pm.max_requests = 500" >> /etc/php-fpm.d/www.conf
RUN echo "php_value[session.save_handler] = memcached" >> /etc/php-fpm.d/www.conf
RUN echo "php_value[session.save_path]    = 'memcached:11211'" /etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /etc/php-fpm.d/www.conf
RUN echo "post_max_size = 150m" >> /etc/php.ini
RUN echo "upload_max_filesize = 150m" >> /etc/php.ini
COPY scripts/composer-installer.sh /composer-installer.sh
RUN sh /composer-installer.sh && mv /composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp

USER www-data
WORKDIR /var/www/html
ENTRYPOINT ["php-fpm", "-F"]
