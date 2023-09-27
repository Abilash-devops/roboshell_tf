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

yum install maven -y &>> $LOGFILE

validate $? "install maven"

useradd roboshop &>> $LOGFILE

mkdir /app &>> $LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>> $LOGFILE

validate $? "copy package"

cd /app &>> $LOGFILE

validate $? "cd app"

unzip /tmp/shipping.zip &>> $LOGFILE

validate $? "unzip package"

mvn clean package &>> $LOGFILE

validate $? "clean package"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

validate $? "move jar files"

cp -rp /home/centos/roboshell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

validate $? "copy config service file"

systemctl daemon-reload &>> $LOGFILE

validate $? "reload service"

systemctl enable shipping  &>> $LOGFILE

validate $? "enable service"

systemctl start shipping &>> $LOGFILE

validate $? "start service"

yum install mysql -y &>> $LOGFILE

validate $? "install mysql client"

mysql -h mysql.padmasrikanth.tech -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

validate $? "set password"

systemctl restart shipping &>> $LOGFILE

validate $? "restart service"