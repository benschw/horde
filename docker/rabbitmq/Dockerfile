FROM ubuntu:16.04

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y rabbitmq-server
RUN rabbitmq-plugins enable rabbitmq_management


EXPOSE 15672

CMD ["/usr/sbin/rabbitmq-server"]


