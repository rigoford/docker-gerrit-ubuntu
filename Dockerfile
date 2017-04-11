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
ARG GERRIT_LIB=${GERRIT_SITE}/lib

ARG GERRIT_TMP=/tmp/gerrit
ARG GERRIT_CONFIG_TMP=${GERRIT_TMP}/config
ARG GERRIT_LIB_TMP=${GERRIT_TMP}/lib
ARG GERRIT_PLUGINS_TMP=${GERRIT_TMP}/plugins

ARG PLUGIN_VERSION=stable-${GERRIT_VERSION}
ARG PLUGIN_URL=https://gerrit-ci.gerritforge.com/view/Plugins-${PLUGIN_VERSION}/job
ARG PLUGIN_DIR=lastSuccessfulBuild/artifact/buck-out/gen/plugins

ARG BOUNCY_CASTLE_BASE_URL=http://central.maven.org/maven2/org/bouncycastle
ARG BOUNCY_CASTLE_VERSION=1.56

ENV GERRIT_HOME=${GERRIT_HOME} \
    GERRIT_SITE=${GERRIT_SITE} \
    GERRIT_PLUGINS=${GERRIT_PLUGINS} \
    GERRIT_LIB=${GERRIT_LIB} \
    GERRIT_CONFIG_TMP=${GERRIT_CONFIG_TMP} \
    GERRIT_LIB_TMP=${GERRIT_LIB_TMP} \
    GERRIT_PLUGINS_TMP=${GERRIT_PLUGINS_TMP}

RUN apt-get update && \
    apt-get install -y --no-install-recommends git openssh

RUN mkdir -p ${GERRIT_PLUGINS} && \
    mkdir -p ${GERRIT_LIB} && \
    mkdir -p ${GERRIT_LIB_TMP} && \
    mkdir -p ${GERRIT_PLUGINS_TMP}

ADD ${GERRIT_DOWNLOAD_URL} ${GERRIT_HOME}/gerrit.war

ADD ${PLUGIN_URL}/plugin-delete-project-${PLUGIN_VERSION}/${PLUGIN_DIR}/delete-project/delete-project.jar ${GERRIT_PLUGINS_TMP}/delete-project.jar
ADD ${PLUGIN_URL}/plugin-importer-${PLUGIN_VERSION}/${PLUGIN_DIR}/importer/importer.jar ${GERRIT_PLUGINS_TMP}/importer.jar
ADD ${PLUGIN_URL}/plugin-reviewers-${PLUGIN_VERSION}/${PLUGIN_DIR}/reviewers/reviewers.jar ${GERRIT_PLUGINS_TMP}/reviewers.jar

ADD ${BOUNCY_CASTLE_BASE_URL}/bcpkix-jdk15on/${BOUNCY_CASTLE_VERSION}/bcpkix-jdk15on-${BOUNCY_CASTLE_VERSION}.jar ${GERRIT_LIB_TMP}/bcpkix-jdk15on-${BOUNCY_CASTLE_VERSION}.jar
ADD ${BOUNCY_CASTLE_BASE_URL}/bcprov-jdk15on/${BOUNCY_CASTLE_VERSION}/bcprov-jdk15on-${BOUNCY_CASTLE_VERSION}.jar ${GERRIT_LIB_TMP}/bcprov-jdk15on-${BOUNCY_CASTLE_VERSION}.jar

ADD ./files/configure-and-run.sh ${GERRIT_HOME}/bin/configure-and-run.sh
RUN chmod +x ${GERRIT_HOME}/bin/configure-and-run.sh

RUN addgroup --gid ${GERRIT_USER_GID} ${GERRIT_USER} && \
    adduser --home ${GERRIT_HOME} --no-create-home --shell /bin/sh --uid ${GERRIT_USER_GID} --gid ${GERRIT_USER_GID} --disabled-login --system ${GERRIT_USER} && \
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME} && \
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_TMP}

USER ${GERRIT_USER}

EXPOSE 8080 29418

WORKDIR ${GERRIT_HOME}

ENTRYPOINT ["./bin/configure-and-run.sh"]
