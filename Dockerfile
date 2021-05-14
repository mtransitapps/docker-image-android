# LINKs:
# - https://github.com/CircleCI-Public/example-images/blob/master/android/Dockerfile
# - https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/android/images/api-30/Dockerfile
# - https://github.com/docker-android-sdk/android-30/blob/master/Dockerfile
# - https://github.com/alexisduque/android-sdk-gradle/blob/master/Dockerfile
# - https://github.com/mingchen/docker-android-build-box/blob/master/Dockerfile

# FROM ubuntu:18.04
# FROM ubuntu:20.04
FROM ubuntu:latest
# FROM openjdk:11-jdk-slim

LABEL maintainer="mtransit.apps@gmail.com"

ARG GIT_DIR="/tmp/mt_project"
ARG GIT_SRC_DIR="${GITHUB_WORKSPACE}/mt_project"
COPY ${GIT_SRC_DIR} ${GIT_DIR}

ENV TZ=America/Toronto

ENV DEBIAN_FRONTEND=noninteractive
# ENV TERM=dumb
ENV TERM=xterm-256color

RUN echo "GITHUB_REF:${GITHUB_REF}"
RUN echo "GITHUB_HEAD_REF:${GITHUB_HEAD_REF}"
RUN echo "GITHUB_BASE_REF:${GITHUB_BASE_REF}"
RUN echo "GITHUB_WORKSPACE:${GITHUB_WORKSPACE}"

RUN dpkg --add-architecture i386
RUN apt-get update -yqq
RUN apt-get install -y \
    apt apt-utils apt-transport-https \
    sudo git vim ssh openssh-client ca-certificates make \
    gawk \
    gzip tar unzip zip bzip2 \
    curl wget \
    locales \
    openjdk-11-jdk
# RUN apt-get install -y gradlew

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"

RUN locale-gen $LANG

# JVM
# RUN apt-get install -y openjdk-11-jdk
# ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/"

# RUN groupadd montransit
# RUN useradd -g montransit montransit
# RUN echo 'montransit ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-montransit
# USER montransit
# ENV HOME /home/montransit

CMD ["/bin/sh"]

# WORKDIR /home/montransit

# https://developer.android.com/studio/#command-tools
ENV ANDROID_SDK_TOOLS_VERSION="7302050" 
ENV ANDROID_API_LEVEL="30"
ENV ANDROID_BUILD_TOOLS_VERSION="${ANDROID_API_LEVEL}.0.3"

ENV ANDROID_HOME="android-sdk"
#ENV ANDROID_HOME="/opt/android-sdk"
# RUN sudo mkdir -p ${ANDROID_HOME}
# RUN sudo chown montransit:montransit ${ANDROID_HOME}

ARG CMDLINE_TOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip
# RUN wget --output-document=$ANDROID_HOME/cmdline-tools.zip $CMDLINE_TOOLS_URL
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools/latest \
    && wget -O /tmp/cmdline-tools.zip -t 5 "${CMDLINE_TOOLS_URL}" \
    && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && mv /tmp/cmdline-tools/cmdline-tools/* ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip \
    && rm -rf /tmp/cmdline-tools

ENV PATH=${PATH}:${ANDROID_HOME}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools
# ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin
# ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/bin
# ENV PATH=${PATH}:${ANDROID_HOME}/tools
# ENV PATH=${PATH}:${ANDROID_HOME}/tools/bin
#ENV PATH=${PATH}:${ANDROID_HOME}/platform-tools

RUN ls -al ${ANDROID_HOME} || echo "> SKIP"
RUN ls -al ${ANDROID_HOME}/cmdline-tools/ || echo "> SKIP"
RUN ls -al ${ANDROID_HOME}/cmdline-tools/latest || echo "> SKIP"
# RUN ls -al ${ANDROID_HOME}/tools/ || echo "> SKIP"
# RUN ls -al ${ANDROID_HOME}/platform-tools/ || echo "> SKIP"

# --sdk_root=${ANDROID_HOME}
RUN yes | sdkmanager --licenses
RUN yes | sdkmanager --update

RUN sdkmanager "platform-tools" \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_API_LEVEL}"
# RUN sdkmanager "cmdline-tools;latest"
# RUN sdkmanager "tools"

# # https://github.com/mtransitapps/commons/blob/master/shared/gradle/wrapper/gradle-wrapper.properties
# # https://docs.gradle.org/current/userguide/installation.html
# ENV GRADLE_VERSION="6.7.1"
# ENV GRADLE_SHA256="22449f5231796abd892c98b2a07c9ceebe4688d192cd2d6763f8e3bf8acbedeb"

# # ENV GRADLE_DIR="/opt/gradle"
# ENV GRADLE_DIR="gradle"
# # ENV GRADLE_DIR="${HOME}/gradle"
# RUN sudo mkdir -p ${GRADLE_DIR}
# # RUN sudo chown montransit:montransit ${GRADLE_DIR}

# ARG GRADLE_ZIP=gradle-${GRADLE_VERSION}-all.zip
# ARG GRADLE_SDK_URL=https://services.gradle.org/distributions/${GRADLE_ZIP}
# RUN curl -sSL "${GRADLE_SDK_URL}" -o ${GRADLE_ZIP}  \
# 	&& unzip ${GRADLE_ZIP} -d ${GRADLE_DIR}  \
# 	&& rm -rf ${GRADLE_ZIP}
# ENV GRADLE_HOME="${GRADLE_DIR}/gradle-${GRADLE_VERSION}"
# ENV PATH=${PATH}:${GRADLE_HOME}/bin

# RUN ls -al ${GRADLE_HOME} || echo "> SKIP"
# RUN ls -al ${GRADLE_HOME}/bin || echo "> SKIP"

# RUN gradle --version

# RUN gradle wrapper \
# 	--gradle-version ${GRADLE_VERSION} \
#     --gradle-distribution-sha256-sum="${GRADLE_SHA256}" \
#     --distribution-type="all"

# ARG GIT_DIR="/tmp/mt_project"
# ARG GIT_SRC_DIR="${GITHUB_WORKSPACE}/mt_project"
# ARG GIT_SRC_DIR="mt_project"
# ARG GIT_URL="git@github.com:mtransitapps/ca-montreal-bixi-bike-gradle.git"
# ARG GIT_URL="https://github.com/mtransitapps/ca-montreal-bixi-bike-gradle.git"
# ARG GIT_BRANCH="use_docker_image"
# RUN git clone ${GIT_URL} --branch ${GIT_BRANCH} $GIT_DIR
# --depth 1 --single-branch
RUN ls -al ${GIT_DIR} || echo "> SKIP"
RUN cat ${GIT_DIR}/.git/HEAD || echo "> SKIP"
RUN cd ${GIT_DIR} && git status;
# RUN cd ${GIT_DIR} && ./checkout_submodules.sh
# RUN cd ${GIT_DIR} && ./commons/sync.sh
RUN cd ${GIT_DIR} && ./gradlew androidDependencies --console=plain
RUN ls -al ${GIT_DIR} || echo "> SKIP"
RUN rm -rf ${GIT_DIR}

RUN ls -al ${HOME} || echo "> SKIP"
RUN ls -al ${HOME}/.gradle || echo "> SKIP"
RUN ls -al ${HOME}/.gradle/wrapper || echo "> SKIP"
RUN ls -al ${HOME}/.gradle/caches || echo "> SKIP"

# # CircleCI Compat
# RUN sudo mkdir -p /home/circleci
# RUN sudo chown montransit:montransit /home/circleci
