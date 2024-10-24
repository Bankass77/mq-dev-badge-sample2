# © Copyright 2019, 2024 IBM Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Specify default base images 
# Can be overidden with different arguments for Mac and Linux in the build command
ARG baseImageBuildStage=docker.io/library/maven:3.8.4-openjdk-17
ARG baseImageRunStage=icr.io/ibm-messaging/mq:latest
#
# stage 1
#
FROM $baseImageBuildStage AS build
USER root
#
COPY ./TicketGenerator /data/TicketGenerator
#
#
# Compile the source code
RUN cd /data/TicketGenerator && \
    mvn -f /data/TicketGenerator/pom.xml clean package;
#
# stage 2
#
#
# Switch to the MQ image
# Tested with 
#     9.4.0.0 
#
FROM $baseImageRunStage
#
# Specify platform architecture - either arm64 or amd64(default)
ARG platformArch=amd64
#
# Set platform architecture as an environment variable
ENV envPlatformArch=${platformArch}
#
USER 0
#
#
# install platform specific jdk libraries
# if architecture is not amd64 or arm64, then forcing abort of build
RUN mkdir -p /opt/jdk && \
    if [ "$platformArch" = "amd64" ]; then \
        curl -Lo OpenJDK17Ux64.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13+11/OpenJDK17U-jdk_x64_alpine-linux_hotspot_17.0.13_11.tar.gz && \
        tar -xvzf OpenJDK17Ux64.tar.gz -C /opt/jdk && \
        ls -la /opt/jdk; \
    elif [ "$platformArch" = "arm64" ]; then \
        curl -Lo OpenJDK17U.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13+11/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.13_11.tar.gz && \
        tar -xvzf OpenJDK17U.tar.gz -C /opt/jdk && \
        ls -la /opt/jdk; \
    else \
        echo "Error: Valid platform architectures are amd64 or arm64" && \
        exit 1; \
    fi


#
# Copy over config and scripts
COPY ./startApp.sh /data/startApp.sh
COPY ./20-config.mqsc /etc/mqm/20-config.mqsc
#
# fix line ending issue on windows system
RUN if [ "$platformArch" == "amd64" ]; then \
    sed -i 's/\r$//' /data/startApp.sh && \
    sed -i 's/\r$//' /etc/mqm/20-config.mqsc; \
  fi
#    
#
# Copy over compiled classes from previous stage
COPY --from=build /data/TicketGenerator /data/TicketGenerator
#
# Fix permissions for compiled classes and app shell script
RUN chmod 776 -R /data/TicketGenerator
RUN chmod a+x /data/startApp.sh
#
# Run MQ and execute TicketGenerator
USER 1001
ENTRYPOINT [ "/data/startApp.sh" ]