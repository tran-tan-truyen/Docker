FROM debian
COPY . /data
RUN apt-get update && apt-get install -y \
    openssl \
	unzip \
	bash \
	rename \
	sed

RUN cd /home

ADD ipa_check.sh /

RUN chmod +x /ipa_check.sh

ENTRYPOINT ["/bin/bash","-c","/ipa_check.sh"]
