FROM centos:7
MAINTAINER hxai.net
ENV TIME_ZOME Asia/Shanghai
ENV NGINX_VERSION 1.16.1



#安装基本环境
RUN yum install -y gcc autoconf gcc-c++ make pcre-devel zlib-devel

#复制到容器 /opt下，自动解压
ADD nginx-${NGINX_VERSION}.tar.gz /opt/
ADD openssl-1.0.2k.tar.gz /opt/
ADD config.tar.gz /opt/

RUN cd /opt/nginx-${NGINX_VERSION} && \
    ./configure \
    --prefix=/usr/local/nginx \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-ipv6 \
    --with-http_sub_module \
    --with-openssl=/opt/openssl-1.0.2k && \
    make && \
    make install

RUN echo "${TIME_ZOME}" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/${TIME_ZOME} /etc/localtime

# 生成service
RUN cp /opt/nginx /etc/init.d/nginx && chmod +x /etc/init.d/nginx
# 添加 默认虚拟站点
RUN mkdir -p /usr/local/nginx/conf/vhost
RUN cp /opt/www.test.com.conf /usr/local/nginx/conf/vhost/

RUN yum clean all
WORKDIR /usr/local/nginx/
EXPOSE 80 443
CMD ["/usr/local/nginx/sbin/nginx","-g","daemon off;"]