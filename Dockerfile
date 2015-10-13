FROM debian:jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/debian/ jessie nginx\ndeb-src http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list

ADD https://raw.githubusercontent.com/guilhem/apt-get-install/master/apt-get-install /usr/local/bin/
ADD https://raw.githubusercontent.com/guilhem/apt-get-install/master/apt-get-remove /usr/local/bin/
RUN chmod +x /usr/local/bin/apt-get-install /usr/local/bin/apt-get-remove

ENV NPS_VERSION=1.9.32.10

RUN mkdir -p /nginx && cd /nginx && \
    apt-get-install ca-certificates build-essential zlib1g-dev libpcre3 libpcre3-dev unzip wget && \
    wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip && \
    unzip release-${NPS_VERSION}-beta.zip && \
    cd /nginx/ngx_pagespeed-release-${NPS_VERSION}-beta/ && \
    wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
    tar -xzvf ${NPS_VERSION}.tar.gz && \
    cd /nginx && \
    apt-get update && apt-get source nginx && \
    cd /nginx/nginx-* && \
    ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --add-module=/nginx/ngx_pagespeed-release-${NPS_VERSION}-beta && \
    make && \
    sh -c "make install" && \
    cd && \
    apt-get-remove build-essential zlib1g-dev libpcre3-dev unzip wget && \
    rm -rf /nginx

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
