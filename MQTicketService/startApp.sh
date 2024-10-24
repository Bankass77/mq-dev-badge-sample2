#!/bin/bash
# Vérifie que Java 17 est utilisé
java_version=$(java -version 2>&1 | awk -F[\"_] '/version/ {print $2}')
if [[ "$java_version" != "17"* ]]; then
    echo "Error: Java 17 is required, but found $java_version"
    exit 1
fi

# Démarrer MQ et exécuter l'application
cd /data/TicketGenerator
runmqdevserver &
sleep 30
. /opt/mqm/bin/setmqenv -s

# Exécuter TicketGenerator
if [ "$envPlatformArch" == "amd64" ]; then
   /opt/jdk/bin/java -cp /data/TicketGenerator/target/TicketGenerator-1.4.jar com.ibm.mq.badge.Manager
elif [ "$envPlatformArch" == "arm64" ]; then
    /opt/jdk/bin/java -cp /data/TicketGenerator/target/TicketGenerator-1.4.jar com.ibm.mq.badge.Manager
else
    echo "Error: Valid platform architectures are amd64 or arm64"
    exit 1
fi
