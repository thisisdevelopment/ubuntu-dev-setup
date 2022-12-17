FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y xorriso patch wget gettext

WORKDIR /src

