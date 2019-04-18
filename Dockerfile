FROM openjdk:8-jdk-slim

ARG MTA_HOME='/opt/sap/mta'
ARG NEO_HOME='/opt/sap/neo'
ARG MTA_VERSION=1.1.19
ARG NODE_VERSION=v10.15.3
ARG NEO_SDK_VERSION=3.78.15

ENV MTA_JAR_LOCATION="${MTA_HOME}/lib/mta.jar"

ADD scripts/mtaBuild.sh ${MTA_HOME}/bin/mtaBuild.sh

RUN apt-get update && apt-get install -y \
      curl wget jq procps && \
    rm -rf /var/lib/apt/lists/* && \
    #
    # Install mta
    #
    mkdir -p `dirname ${MTA_JAR_LOCATION}` && \
    curl --fail \
         --silent \
         --cookie "eula_3_1_agreed=tools.hana.ondemand.com/developer-license-3_1.txt;" \
         --output ${MTA_JAR_LOCATION} \
      https://tools.hana.ondemand.com/additional/mta_archive_builder-${MTA_VERSION}.jar && \
    curl --fail \
         --silent \
         --output ${MTA_HOME}/LICENSE.txt \
       https://tools.hana.ondemand.com/developer-license-3_1.txt && \
    chmod 755 ${MTA_HOME}/bin/mtaBuild.sh && \
    ln -s ${MTA_HOME}/bin/mtaBuild.sh /usr/local/bin/mtaBuild && \
    INSTALLED_MTA_VERSION=`mtaBuild --version` && \
    echo "[INFO] mta version: \"${INSTALLED_MTA_VERSION}\"." && \
    #
    # Install node
    #
    NODE_HOME=/opt/nodejs; mkdir -p ${NODE_HOME} && \
    curl --fail --silent --output - http://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz \
     |tar -xzv -f - -C ${NODE_HOME} && \
    ln -s ${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/node /usr/local/bin/node && \
    ln -s ${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/npm /usr/local/bin/npm && \
    INSTALLED_NODE_VERSION=`node --version` && \
    echo "[INFO] node version: \"${INSTALLED_NODE_VERSION}\"." && \
    #
    # Provide SAP registry
    #
    npm config set @sap:registry https://npm.sap.com --global && \
    #
    # Install neo command line client 
    #
    wget -P ${NEO_HOME} http://central.maven.org/maven2/com/sap/cloud/neo-java-web-sdk/${NEO_SDK_VERSION}/neo-java-web-sdk-${NEO_SDK_VERSION}.zip && \
    unzip -o ${NEO_HOME}/neo-java-web-sdk-${NEO_SDK_VERSION}.zip -d ${NEO_HOME} && \
    rm ${NEO_HOME}/neo-java-web-sdk-${NEO_SDK_VERSION}.zip && \
    ln -s ${NEO_HOME}/tools/neo.sh /usr/bin/neo.sh && \
    #
    # Cleanup curl and wget (was only needed for downloading artifacts)
    #
    apt-get remove --purge --autoremove -y \
      curl wget && \
    #
    # Install grunt-cli
    #
    npm install -g grunt-cli

ENV PATH=./node_modules/.bin:$PATH

#
# Install karma and related tools
#
COPY package.json ./package.json
RUN npm install