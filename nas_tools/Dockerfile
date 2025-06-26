FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
COPY . /tmp/projeto
WORKDIR /tmp/projeto
RUN chmod +x configure.sh init_services.sh

CMD bash -c "./configure.sh && ./init_services.sh && mv /tmp/projeto /home/admin && chown -R admin:admin /home/admin && su - admin"
