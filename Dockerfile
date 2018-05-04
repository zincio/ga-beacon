# Build Stage
FROM lacion/docker-alpine:gobuildimage AS build-stage

LABEL app="build-ga-beacon"
LABEL REPO="https://github.com/zincio/ga-beacon"

ENV GOROOT=/usr/lib/go \
    GOPATH=/gopath \
    GOBIN=/gopath/bin \
    PROJPATH=/gopath/src/github.com/zincio/ga-beacon

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /gopath/src/github.com/zincio/ga-beacon
WORKDIR /gopath/src/github.com/zincio/ga-beacon

RUN make build-alpine

# Final Stage
FROM lacion/docker-alpine:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/zincio/ga-beacon"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/ga-beacon/bin

WORKDIR /opt/ga-beacon/bin

COPY --from=build-stage /gopath/src/github.com/zincio/ga-beacon/bin/ga-beacon /opt/ga-beacon/bin/
RUN chmod +x /opt/ga-beacon/bin/ga-beacon

EXPOSE 9001
HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=15s \
    CMD curl -f http://localhost:9001

CMD /opt/ga-beacon/bin/ga-beacon