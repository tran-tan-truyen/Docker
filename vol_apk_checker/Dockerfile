FROM debian
COPY . /data
RUN apt-get update && apt-get install -y \
	unzip \
	bash \
	sed \
	rename \
    openssl \
	default-jre \
	libbcprov-java

RUN cd /home

ADD apk_check.sh /

RUN chmod +x /apk_check.sh

ENTRYPOINT ["/bin/bash","-c","/apk_check.sh"]
