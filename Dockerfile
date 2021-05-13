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

ENV TZ=America/Toronto

ENV DEBIAN_FRONTEND=noninteractive
# ENV TERM=dumb
ENV TERM=xterm-256color

RUN dpkg --add-architecture i386
RUN apt-get update -yqq
RUN apt-get install -y apt apt-utils apt-transport-https 
RUN apt-get install -y sudo git vim ssh openssh-client ca-certificates make
RUN apt-get install -y gawk
RUN apt-get install -y gzip tar unzip zip bzip2
RUN apt-get install -y curl wget
# RUN apt-get install -y gradlew

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
RUN apt-get install -y locales && locale-gen $LANG

# JVM
RUN apt-get install -y openjdk-11-jdk
# ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/"

RUN groupadd montransit
RUN useradd -g montransit montransit
USER montransit
ENV HOME /home/montransit

CMD ["/bin/sh"]

WORKDIR /home/montransit

ENV ANDROID_HOME="${HOME}/android-sdk"
# https://developer.android.com/studio/#command-tools
ENV ANDROID_SDK_TOOLS_VERSION="7302050" 
ENV ANDROID_API_LEVEL="30"
ENV ANDROID_BUILD_TOOLS_VERSION="${ANDROID_API_LEVEL}.0.3"

RUN sudo mkdir -p ${ANDROID_HOME}
# RUN sudo chown montransit:montransit ${ANDROID_HOME}

ARG CMDLINE_TOOLS=https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip
# RUN wget --output-document=$ANDROID_HOME/cmdline-tools.zip $CMDLINE_TOOLS
RUN sudo mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    sudo chown -R montransit:montransit ${ANDROID_HOME} && \
    wget -O /tmp/cmdline-tools.zip -t 5 "${CMDLINE_TOOLS}" && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    rm /tmp/cmdline-tools.zip

ENV PATH=${PATH}:${ANDROID_HOME}
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin
ENV PATH=${PATH}:${ANDROID_HOME}/tools
ENV PATH=${PATH}:${ANDROID_HOME}/tools/bin
ENV PATH=${PATH}:${ANDROID_HOME}/platform-tools

RUN yes | sdkmanager --licenses && yes | sdkmanager --update

# RUN sdkmanager "tools"
RUN sdkmanager "platform-tools"
RUN sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
RUN sdkmanager "platforms;android-${ANDROID_API_LEVEL}"

# https://github.com/mtransitapps/commons/blob/master/shared/gradle/wrapper/gradle-wrapper.properties
# https://docs.gradle.org/current/userguide/installation.html
ENV GRADLE_VERSION="6.7.1"
# ENV GRADLE_HOME="/o pt/gradle"
ENV GRADLE_DIR="${HOME}/gradle"
RUN mkdir -p ${GRADLE_DIR}
ARG GRADLE_ZIP=gradle-${GRADLE_VERSION}-all.zip
ARG GRADLE_SDK_URL=https://services.gradle.org/distributions/${GRADLE_ZIP}
RUN curl -sSL "${GRADLE_SDK_URL}" -o ${GRADLE_ZIP}  \
	&& unzip ${GRADLE_ZIP} -d ${GRADLE_DIR}  \
	&& rm -rf ${GRADLE_ZIP}
ENV GRADLE_HOME="${GRADLE_DIR}/gradle-${GRADLE_VERSION}"
ENV PATH=${PATH}:${GRADLE_HOME}/bin