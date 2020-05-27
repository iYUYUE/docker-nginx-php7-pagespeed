FROM ubuntu:bionic

RUN export BUILD_PACKAGES="curl wget unzip sudo build-essential zlib1g-dev libpcre3-dev uuid-dev gpg gpg-agent" \
  && export SUDO_FORCE_REMOVE=yes \
  && export DEBIAN_FRONTEND=noninteractive \
  && export HEADERS_MORE_VERSION=0.33 \
  && apt-get -y update \
  && apt-get -y --no-install-recommends install ca-certificates $BUILD_PACKAGES \
  && apt-get -y update \
  && apt-get -y --no-install-recommends install \
    libssl-dev \
    exim4 \
    php7.2-fpm \
    php7.2-mysql \
    php7.2-sqlite3 \
    php7.2-cli \
    php7.2-curl \
    php7.2-gd \
    php7.2-intl \
    php7.2-imap \
    php7.2-xml \
    php7.2-mbstring \
    php-pear \
    php7.2-pspell \
    php7.2-tidy \
    php7.2-xmlrpc \
    php7.2-xsl \
    php7.2-recode \
    php-memcached \
    php-redis \
    supervisor \
    incron \
  && phpenmod -v mcrypt imap memcached redis \
  && mkdir -p /run/php/ \
  && wget -qO- https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz | tar zxf - -C /tmp \
  && bash -c "bash <(curl -f -L -sS https://ngxpagespeed.com/install) --nginx-version latest -a '--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=www-data --group=www-data --with-http_ssl_module --with-http_v2_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_secure_link_module --with-http_realip_module' -y" \
  && apt-get remove --purge -y $BUILD_PACKAGES \
  && apt-get autoremove --purge -y \
  && rm -rf /var/lib/apt/lists/* /tmp/* \
  && rm -f /etc/incron.allow \
  && mkdir -p /var/cache/nginx/client_temp \
  && mkdir /var/cache/ngx_pagespeed \
  && chown nginx:nginx /var/cache/ngx_pagespeed

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

COPY root /

RUN chmod 0644 /etc/incron.d/run

RUN incrontab /etc/incron.d/run
