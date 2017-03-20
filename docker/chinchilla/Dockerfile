FROM ubuntu:16.04

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y curl

ADD http://dl.fligl.io/artifacts/chinchilla/chinchilla_linux_amd64_latest.gz /tmp/chinchilla.gz

RUN cd /tmp && gunzip chinchilla.gz && chmod 755 chinchilla && mv chinchilla /bin/chinchilla

ADD run.sh /tmp/run.sh

CMD ["/tmp/run.sh"]

