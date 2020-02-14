#!/bin/bash
echo "> yum update start"
yum update -y

echo "> jdk1.8 install"
yum install -y java-1.8.0-openjdk-devel.x86_64

echo "> git install"
yum install -y git

echo "> create workspace directory"
mkdir /home/ec2-user/workspace

cd /home/ec2-user/workspace

echo "> git clone"
git clone https://github.com/csbsjy/hello-spring.git

cd hello-spring

echo "> start gradle build"
./gradlew clean build


cat <<EOF > /etc/systemd/system/sample-app.service 
[Unit]
Description=Java Application as a Service
[Service]
User=ec2-user
#change this directory into your workspace
#mkdir workspace 
WorkingDirectory=/home/ec2-user/workspace
#path to the executable bash script which executes the jar file
ExecStart=/bin/bash /home/ec2-user/workspace/deploy-app.sh
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

echo "> create deploy script"
cat <<EOF > /home/ec2-user/workspace/deploy-app.sh
java -Dexternal.sys.properties=file:system.properties -Dexternal.app.properties=file:application.properties -jar /home/ec2-user/workspace/hello-spring/build/libs/*.jar
EOF

systemctl daemon-reload
systemctl enable sample-app.service
sudo systemctl start sample-app

