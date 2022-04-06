FROM openjdk:16.0

ENV APP_DIR /usr/telestion/ba-telestion-innocube

ADD build/distributions/ba-telestion-innocube.tar /usr/telestion

WORKDIR $APP_DIR
EXPOSE 9870

ENTRYPOINT ["sh", "-c"]
CMD ["./bin/ba-telestion-innocube"]
