FROM rigoford/ubuntu-java-newrelic:3.33.0.0

MAINTAINER Martin Ford <ford.j.martin@gmail.com>

ARG GERRIT_USER=gerrit
ARG GERRIT_USER_GID=5203
ARG GERRIT_VERSION=2.11
ARG GERRIT_POINT_VERSION=${GERRIT_VERSION}.3
ARG GERRIT_HOME=/opt/gerrit
ARG GERRIT_DOWNLOAD_URL=https://www.gerritcodereview.com/download/gerrit-${GERRIT_POINT_VERSION}.war
ARG GERRIT_SITE=${GERRIT_HOME}/site
ARG GERRIT_PLUGINS=${GERRIT_SITE}/plugins

ARG PLUGIN_VERSION=stable-${GERRIT_VERSION}
ARG PLUGIN_URL=https://gerrit-ci.gerritforge.com/view/Plugins-${PLUGIN_VERSION}/job
ARG PLUGIN_DIR=lastSuccessfulBuild/artifact/buck-out/gen/plugins

ENV GERRIT_HOME=${GERRIT_HOME} \
    GERRIT_SITE=${GERRIT_SITE} \
    GERRIT_PLUGINS=${GERRIT_PLUGINS}

RUN apt-get update && \
    apt-get install -y --no-install-recommends git

RUN mkdir -p ${GERRIT_PLUGINS}

ADD ${GERRIT_DOWNLOAD_URL} ${GERRIT_HOME}/gerrit.war
ADD ${PLUGIN_URL}/plugin-delete-project-${PLUGIN_VERSION}/${PLUGIN_DIR}/delete-project/delete-project.jar ${GERRIT_PLUGINS}/delete-project.jar
ADD ${PLUGIN_URL}/plugin-importer-${PLUGIN_VERSION}/${PLUGIN_DIR}/importer/importer.jar ${GERRIT_PLUGINS}/importer.jar
ADD ${PLUGIN_URL}/plugin-reviewers-${PLUGIN_VERSION}/${PLUGIN_DIR}/reviewers/reviewers.jar ${GERRIT_PLUGINS}/reviewers.jar

ADD ./files/configure-and-run.sh ${GERRIT_HOME}/bin/configure-and-run.sh
RUN chmod +x ${GERRIT_HOME}/bin/configure-and-run.sh

RUN addgroup -g ${GERRIT_USER_GID} ${GERRIT_USER} && \
    adduser -h ${GERRIT_HOME} -s /bin/sh -u ${GERRIT_USER_GID} -D -G ${GERRIT_USER} -H ${GERRIT_USER} && \
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME}

USER ${GERRIT_USER}

EXPOSE 8080 29418

VOLUME ["${GERRIT_PLUGINS}"]

WORKDIR "${GERRIT_HOME}"

ENTRYPOINT ["./bin/configure-and-run.sh"]
