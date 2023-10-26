FROM openjdk:22-slim-bullseye
ENV APP_FILE caller-service-0.0.1.jar
ENV APP_HOME /usr/app
EXPOSE 8080
COPY target/$APP_FILE $APP_HOME/
WORKDIR $APP_HOME
ENTRYPOINT ["sh", "-c"]
CMD ["exec java -jar $APP_FILE"]
