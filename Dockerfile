FROM mono:latest
ENV mongodb_host=mongodb
ENV mongodb_port=27017


RUN apt-get update -y && apt-get install libssl-dev -y

COPY Deadline-10.3.2.1-linux-installers.tar /tmp/Deadline-10.3.2.1-linux-installers.tar
COPY setup_deadline.sh /tmp/setup_deadline.sh
RUN chmod +x /tmp/setup_deadline.sh \
    && /tmp/setup_deadline.sh

COPY deadline.ini /var/lib/Thinkbox/Deadline10/deadline.ini
COPY run_webservice.sh /opt/Thinkbox/Deadline10/run_webservice.sh
RUN chmod +x /opt/Thinkbox/Deadline10/run_webservice.sh
CMD /opt/Thinkbox/Deadline10/run_webservice.sh

EXPOSE 8081