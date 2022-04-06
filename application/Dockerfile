FROM openjdk:16.0

ENV APP_DIR /usr/telestion/##REPO_NAME##

ADD build/distributions/##REPO_NAME##.tar /usr/telestion

WORKDIR $APP_DIR
EXPOSE 9870

ENTRYPOINT ["sh", "-c"]
CMD ["./bin/##REPO_NAME##"]
