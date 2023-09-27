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

yum install nginx -y &>> $LOGFILE
sleep 10

validate $? "install nginx"

systemctl enable nginx &>> $LOGFILE

validate $? "enable service"

systemctl start nginx &>> $LOGFILE

validate $? "start service"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

validate $? "remove html"

curl -o /tmp/web.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> $LOGFILE

validate $? "copy package"

cd /usr/share/nginx/html &>> $LOGFILE

validate $? "cd html"

unzip /tmp/web.zip &>> $LOGFILE

validate $? "unzip package"

cp -rp /home/centos/roboshell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

validate $? "create reverse proxy"

systemctl restart nginx &>> $LOGFILE

validate $? "restart nginx"