# syntax=docker/dockerfile:1

# latest node-bookworm image
FROM node:22-bookworm-slim
WORKDIR /app

# Install node dependencies and update vulnerable packages
RUN npm install --ignore-scripts  --global npm@11.1.0 && \
    npm install --ignore-scripts  --global npx --force && \
    npm cache clean --force && \
    npm install --ignore-scripts  --global @security-alert/sarif-to-comment@1.10.10 --omit=dev --no-audit --no-fund

# Remove unnecessary cache and temp files to reduce attack surface
RUN rm -rf /root/.npm /root/.cache

RUN apt-get update && \
    apt-get install --no-install-recommends -y wget ca-certificates && \
    wget -O /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.8.0/jq-linux-amd64 && \
    chmod +x /usr/local/bin/jq && \
    apt-get remove -y wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh
USER node
ENTRYPOINT ["bash", "/app/entrypoint.sh"]
