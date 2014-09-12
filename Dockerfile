FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

#Runit
RUN apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd
RUN sed -i "s/session.*required.*pam_loginuid.so/#session    required     pam_loginuid.so/" /etc/pam.d/sshd
RUN sed -i "s/PermitRootLogin without-password/#PermitRootLogin without-password/" /etc/ssh/sshd_config

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#pagespeed
RUN apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev
RUN curl -L https://github.com/pagespeed/ngx_pagespeed/archive/v1.8.31.4-beta.tar.gz | tar xz
RUN cd ngx_pagespeed* && \
    curl https://dl.google.com/dl/page-speed/psol/1.8.31.4.tar.gz | tar xz

#purge
RUN git clone https://github.com/FRiCKLE/ngx_cache_purge.git

#nginx
RUN curl http://nginx.org/download/nginx-1.6.1.tar.gz | tar xz
RUN cd nginx* && \
    ./configure --add-module=/ngx_pagespeed-1.8.31.4-beta --add-module=/ngx_cache_purge && \ 
    make && \
    make install 
RUN ln -s /usr/local/nginx /etc/nginx
RUN ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
RUN mkdir -p /var/ngx_pagespeed_cache && chmod 777 /var/ngx_pagespeed_cache
RUN mkdir -p /var/log/pagespeed && chmod 777 /var/log/pagespeed
RUN mkdir -p /var/nginx/cache && chmod 777 /var/nginx/cache

#MySql
RUN apt-get install -y mysql-server php5-mysql

#PHP-FPM
RUN apt-get install -y php5-fpm
RUN sed -i "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" /etc/php5/fpm/php.ini

#conf
ADD etc/nginx.conf /etc/nginx/conf/nginx.conf

#test
ADD info.php /usr/local/nginx/html/

#Add runit services
ADD sv /etc/service 

