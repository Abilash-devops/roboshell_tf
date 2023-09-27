#!/bin/bash
D=$(date +%F:%H:%M:%S)
SCRIPT_NAME=$0
LOG_PATH=/home/centos/roboshell/logs
LOGFILE=$LOG_PATH/$0-$D-log
u=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
if [ $u -ne 0 ]
then
echo " Please run the script with root or superuser previliges "
exit 1
fi
validate(){
    if [ $? -ne 0 ]
    then
        echo -e " $2 is $R FAILURE $N"
        exit 1
    else
        echo -e " $2 is $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

validate $? "copy nodejs repo"

yum install nodejs -y &>>$LOGFILE

validate $? "install nodejs"

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>$LOGFILE

validate $? "download the catalogue package"

cd /app &>>$LOGFILE

validate $? "cd app"

unzip /tmp/catalogue.zip &>>$LOGFILE

validate $? "unzip catalogue zip"

npm install &>>$LOGFILE

validate $? "validate dependencies"

cp -rp /home/centos/roboshell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

validate $? "catalogue.servcie file"

systemctl daemon-reload &>>$LOGFILE

validate $? "reload service"

systemctl enable catalogue &>>$LOGFILE

validate $? "enable service"

systemctl start catalogue &>>$LOGFILE

validate $? "start service"

cp -rp /home/centos/roboshell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

validate $? "copy mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE

validate $? "install mongo client"

mongo --host mongodb.padmasrikanth.tech </app/schema/catalogue.js &>>$LOGFILE

validate $? "push data to mongodb"