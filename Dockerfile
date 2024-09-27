FROM ubuntu:22.04 AS downloader

RUN apt-get update && apt-get install -y wget unzip sudo

ARG CHARIOT_URL="https://chariot-releases.s3.amazonaws.com/2.6.0/chariot_linux_2.6.0.zip"

ENV INSTALLER_PATH /opt/chariot
ENV TMP_PATH "/tmp/chariot_linux.zip"


# Set to Bash Shell Execution instead of /bin/sh
SHELL [ "/bin/bash", "-c" ]

# Download Chariot
RUN set -exo pipefail; \
    wget -q --ca-certificate=/etc/ssl/certs/ca-certificates.crt -O "${TMP_PATH}" "${CHARIOT_URL}"
# TODO: check sha

WORKDIR ${INSTALLER_PATH}
RUN unzip -q "${TMP_PATH}" -d "${INSTALLER_PATH}" && \
    chmod +x install.sh status.sh uninstall.sh upgradeExport.sh upgradeImport.sh

# Clean up
RUN rm -rf "${TMP_PATH}"

# TODO: ln -s folders like logs, data, conf ...
# Wrapper conf : /opt/chariot/yajsw/conf/wrapper.conf
# ${INSTALLER_PATH}/log/wrapper.log


# FROM eclipse-temurin:8-jre-focal as final

# Install
RUN /bin/bash "${INSTALLER_PATH}/install.sh"

# Check alive
HEALTHCHECK --interval=20s --start-period=60s --timeout=3s \
    CMD /bin/bash -c /opt/chariot/status.sh 2>&1 | grep RUNNING

# Log to console
RUN mkdir -p "${INSTALLER_PATH}/log/" && \ 
    ln -s /dev/stdout "${INSTALLER_PATH}/log/stdout.log"
# chown -h ${CHARIOT_UID}:${CHARIOT_UID} "${INSTALLER_PATH}/log/wrapper.log"


# Setup Port Expose
EXPOSE 1883 8080 8883 8090 8091

# Copy in Entrypoint and helper scripts
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

STOPSIGNAL SIGINT

# ENTRYPOINT [ "/usr/local/bin/start.sh" ]
CMD ["/usr/local/bin/start.sh"]