#!/bin/bash
echo "> yum update start"
yum update -y

echo "> jdk1.8 install"
yum install -y java-1.8.0-openjdk-devel.x86_64

echo "> git install"
yum install -y git 

