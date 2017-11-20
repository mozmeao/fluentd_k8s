FROM alpine:latest

RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb \
 && apk add --no-cache --virtual .build-deps \
        build-base \
        libffi-dev \
        ruby-dev wget gnupg \
 && update-ca-certificates \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 2.18.3 \
 && gem install json -v 2.1.0 \
 && gem install fluentd -v 0.14.23 \
 && gem install fluent-plugin-kubernetes_metadata_filter \
 && gem install fluent-plugin-syslog-tls \
 && apk del build-base ruby-dev libffi-dev \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN adduser -D -g '' -u 1000 -h /home/fluent fluent
RUN chown -R fluent:fluent /home/fluent
# for log storage (maybe shared with host)
RUN mkdir -p /fluentd/log
# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc /fluentd/plugins
RUN chown -R fluent:fluent /fluentd

# !!!!! This runs as root to access external k8s volumes !!!!!
USER root
WORKDIR /home/fluent

COPY fluent.conf /fluentd/etc/

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

# you must specify these when starting Docker!
ENV SYSLOG_HOST=""
ENV SYSLOG_PORT=""

EXPOSE 24224 5140

CMD exec fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
