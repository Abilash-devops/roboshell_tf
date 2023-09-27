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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

validate $? "download nodejs"

yum install nodejs -y &>> $LOGFILE
sleep 20

validate $? "install nodejs"

useradd roboshop &>> $LOGFILE

mkdir /app &>> $LOGFILE

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip &>> $LOGFILE

validate $? "copy package"

cd /app &>> $LOGFILE

validate $? "cd app"

unzip /tmp/user.zip &>> $LOGFILE

validate $? "unzip package"

npm install  &>> $LOGFILE

validate $? "depencencies package"

cp -rp /home/centos/roboshell/user.service /etc/systemd/system/user.service &>> $LOGFILE

validate $? "user service file"

systemctl daemon-reload &>> $LOGFILE

validate $? "reload service"

systemctl enable user &>> $LOGFILE

validate $? "enable service"

systemctl start user &>> $LOGFILE

validate $? "start service"

cp -rp /home/centos/roboshell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $

validate $? "mongo repo"

yum install mongodb-org-shell -y &>> $LOGFILE

validate $? "mongo client"

mongo --host mongodb.abilashhareendran.in </app/schema/user.js &>> $LOGFILE

validate $? "push data to DB"