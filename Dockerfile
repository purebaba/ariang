FROM alpine:3.15.0 AS builder

ARG THTTPD_VERSION=2.29
ARG ARIANG_VERSION=1.2.3

RUN apk add --update --no-cache \
    build-base \
    wget


RUN wget http://www.acme.com/software/thttpd/thttpd-${THTTPD_VERSION}.tar.gz \
  && tar xzf thttpd-${THTTPD_VERSION}.tar.gz \
  && mv /thttpd-${THTTPD_VERSION} /thttpd

RUN wget https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip \
  && unzip AriaNg-${ARIANG_VERSION}.zip -d /AriaNg

RUN cd /thttpd \
  && ./configure \
  && make CCOPT='-O2 -s -static' thttpd



FROM scratch

COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /thttpd/thttpd /
COPY --from=builder /AriaNg /AriaNg

ENTRYPOINT ["/thttpd","-D","-h","0.0.0.0","-p","80","-d","/AriaNg","-l", "-", "-M", "60"]
