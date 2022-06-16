FROM centos:7
LABEL maintainer="okeyear@outlook.com"

ENV SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=squid

RUN curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo \
    && yum -y install squid 

# yum -y update \
#     && mkdir /etc/yum.repos.d/bak \
#     && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/ \
#     && 

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]