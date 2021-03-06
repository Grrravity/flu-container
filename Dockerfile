FROM ubuntu:20.10

ENV TZ=Europe/Paris
   
# Prerequisites
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update -y && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome-stable_current_amd64.deb
RUN apt install -y scrcpy

# Set up new user
RUN useradd -ms /bin/bash -u 1004 developer
RUN usermod -aG plugdev developer
# RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer
   
# Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"
   
# Switch to stable
RUN flutter channel stable

# Upgrading flutter version
RUN flutter upgrade

# Installing Chrome 
RUN flutter config --enable-web

# Run basic check to download Dark SDK
RUN flutter doctor -v

# Adding working folder
RUN mkdir dev
WORKDIR /home/developer/dev
