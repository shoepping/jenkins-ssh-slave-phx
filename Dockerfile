FROM jenkinsci/ssh-slave

# https://github.com/keeganwitt/docker-gradle/blob/e486d3ff8bb68e77ac37239d68d4d60f4a9485fc/jdk7/Dockerfile
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 4.10.3


ARG GRADLE_DOWNLOAD_SHA256=8626cbf206b4e201ade7b87779090690447054bc93f052954c78480fa6ed186e

RUN apt-get update
RUN apt-get install -y curl zip wget

RUN apt-get install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

RUN apt-get update
RUN apt-cache madison docker-ce
RUN apt-get install -y docker-ce=18.06.1~ce~3-0~debian

RUN usermod -aG docker jenkins

ENV DOCKER-COMPOSE_VERSION 1.23.2
RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER-COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
	-o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

RUN set -o errexit -o nounset \
	&& echo "Downloading Gradle" \
	&& wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
	\
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle


# groovy installation based on https://github.com/groovy/docker-groovy/blob/master/jdk8/Dockerfile
ENV GROOVY_HOME /opt/groovy
ENV GROOVY_VERSION 2.5.2


RUN set -o errexit -o nounset \
	&& echo "Downloading Groovy" \
	&& wget --no-verbose --output-document=groovy.zip "https://dist.apache.org/repos/dist/release/groovy/${GROOVY_VERSION}/distribution/apache-groovy-binary-${GROOVY_VERSION}.zip" \
	\
	&& echo "Importing keys listed in http://www.apache.org/dist/groovy/KEYS from key server" \
	&& echo "Installing Groovy" \
	&& unzip groovy.zip \
	&& rm groovy.zip \
	&& mv "groovy-${GROOVY_VERSION}" "${GROOVY_HOME}/" \
	&& ln --symbolic "${GROOVY_HOME}/bin/grape" /usr/bin/grape \
	&& ln --symbolic "${GROOVY_HOME}/bin/groovy" /usr/bin/groovy \
	&& ln --symbolic "${GROOVY_HOME}/bin/groovyc" /usr/bin/groovyc \
	&& ln --symbolic "${GROOVY_HOME}/bin/groovyConsole" /usr/bin/groovyConsole \
	&& ln --symbolic "${GROOVY_HOME}/bin/groovydoc" /usr/bin/groovydoc \
	&& ln --symbolic "${GROOVY_HOME}/bin/groovysh" /usr/bin/groovysh \
  && ln --symbolic "${GROOVY_HOME}/bin/java2groovy" /usr/bin/java2groovy
