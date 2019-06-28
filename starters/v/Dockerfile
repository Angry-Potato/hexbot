FROM alpine

RUN apk --update --no-cache add git make curl gcc build-base curl-dev
ENV WORK_DIR /usr/src
ENV VROOT ${WORK_DIR}/v
WORKDIR ${WORK_DIR}
RUN git clone https://github.com/vlang/v && \
    cd ${VROOT}/compiler && \
    make && \
    ln -s ${VROOT}/compiler/v /usr/local/bin/v

COPY . ./
ENTRYPOINT [ "v" ]
CMD ["run", "main.v"]