ARG COMMANDBOX_IMAGE=ortussolutions/commandbox:boxlang-3.16.0@sha256:963093195c6dabc33c5a2bd2a765ae28d495c778744054a3462acbc3d9adec6a
FROM ${COMMANDBOX_IMAGE}

ARG BUILD_DATE=unknown
ARG VCS_REF=unknown
ARG VERSION=dev

LABEL org.opencontainers.image.title="Jojo"
LABEL org.opencontainers.image.description="Jojo BoxLang and ColdBox administration portal"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.source="https://github.com/jhocali/aiseries"

ENV APP_DIR=/app \
    APPNAME=Jojo \
    BOXLANG_DEBUG=false \
    BOX_SERVER_PROFILE=production \
    ENVIRONMENT=production \
    HEALTHCHECK_URI=http://127.0.0.1:8080/healthcheck \
    PORT=8080

WORKDIR ${APP_DIR}

# Install only runtime dependencies before copying application code so this
# layer remains cacheable when source files change.
COPY box.json ./
RUN box install --production

COPY app ./app
COPY public ./public
COPY lib/java ./lib/java
COPY runtime/boxlang.production.json ./runtime/boxlang.production.json
COPY server.production.json ./server.json

# Resolve the BoxLang engine and server modules during the image build instead
# of downloading them during a production start.
RUN ${BUILD_DIR}/util/warmup-server.sh

EXPOSE 8080

CMD ["/bin/bash", "-c", "$BUILD_DIR/run.sh"]
