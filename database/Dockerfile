ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB
ARG POSTGRES_PORT

FROM postgres:latest

COPY ./docker-entrypoint.sh /

RUN chmod 755 /docker-entrypoint.sh

USER postgres

ENTRYPOINT ["bash", "/docker-entrypoint.sh"]

EXPOSE ${POSTGRES_PORT}

CMD ["postgres"]
