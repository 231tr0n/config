#!/bin/bash
set -e
rm -rf java-debug
git clone https://github.com/microsoft/java-debug.git
cd java-debug
./mvnw clean install
install -Dm755 "com.microsoft.java.debug.plugin/target/*.jar" \
               "/usr/share/java-debug/com.microsoft.java.debug.plugin.jar"
install -Dm755 "com.microsoft.java.debug.core/target/*.jar" \
               "/usr/share/java-debug/com.microsoft.java.debug.core.jar"
cd ..
rm -rf java-debug
