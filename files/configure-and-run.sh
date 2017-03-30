#!/bin/sh

GERRIT_CONFIG=/tmp/gerrit/gerrit.config
REVIEWERS_CONFIG=/tmp/gerrit/reviewers.config
SECURE_CONFIG=/tmp/gerrit/secure.config

if [ -f ${GERRIT_CONFIG} ];
then
  mkdir -p ${GERRIT_SITE}/etc
  cp ${GERRIT_CONFIG} ${GERRIT_SITE}/etc/gerrit.config
fi

if [ -f ${REVIEWERS_CONFIG} ];
then
  mkdir -p ${GERRIT_SITE}/etc
  cp ${REVIEWERS_CONFIG} ${GERRIT_SITE}/etc/reviewers.config
fi

if [ -f ${SECURE_CONFIG} ];
then
  mkdir -p ${GERRIT_SITE}/etc
  cp ${SECURE_CONFIG} ${GERRIT_SITE}/etc/secure.config
fi

java ${JAVA_FLAGS} -jar ${GERRIT_HOME}/gerrit.war init --batch --install-all-plugins --no-auto-start --site-path ${GERRIT_SITE}

java ${JAVA_FLAGS} -jar ${GERRIT_HOME}/gerrit.war reindex --site-path ${GERRIT_SITE}

java ${JAVA_FLAGS} -jar ${GERRIT_HOME}/gerrit.war daemon --console-log --site-path ${GERRIT_SITE}
