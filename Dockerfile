FROM alpine AS build

ENV NGINX_VERSION 1.18.0

WORKDIR /app

RUN apk update && apk add alpine-sdk openssl-dev pcre-dev zlib-dev

RUN curl -LSs http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O && \
    tar xf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    git clone https://github.com/chobits/ngx_http_proxy_connect_module  && \
    patch -p1 < ./ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_1018.patch && \
    ./configure --add-module=./ngx_http_proxy_connect_module --sbin-path=/usr/sbin/nginx && \
    make -j $(nproc) && \
    make install -j $(nproc)

COPY ./nginx.conf /usr/local/nginx/conf/nginx.conf

EXPOSE 3128

CMD [ "nginx", "-g", "daemon off;" ]
