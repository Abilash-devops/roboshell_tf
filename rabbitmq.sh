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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

validate $? "install erlang"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

validate $? "install rabbitmq repo"

yum install rabbitmq-server -y &>> $LOGFILE

validate $? "install rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILE

validate $? "enable service"

systemctl start rabbitmq-server &>> $LOGFILE

validate $? "start service"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

validate $? "create user and password"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

validate $? "set permissions"
