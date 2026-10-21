#!/bin/bash

user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file="$logs_folder/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ "$user_id" -ne 0 ]; then
    echo -e "${R}You should run this script as root user or with sudo privileges.${N}"
    exit 1
fi


mkdir -p "$logs_folder" 

timestamp(){
    date "+%F %T" 
}


validation(){
    if [ $1 -ne 0 ] ; then
    echo " $(timestamp) [ERROR] $2 Installation failed. Check the logs for more details."  | tee -a "$logs_file"
    exit 1
    else
    echo " $(timestamp) [INFO] $2 Installation completed successfully."  | tee -a "$logs_file"
    fi
}

echo "Script started at [INFO] $(timestamp)" | tee -a "$logs_file"

dnf module disable redis -y &>> $logs_file
dnf module enable redis:7 -y &>> $logs_file
dnf install redis -y &>> $logs_file
validation $? "Redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validation $? "Allowing remote connections to Redis"

systemctl enable redis &>> $logs_file
systemctl start redis
validate $? "Enable and start Redis"

echo "Script completed at [INFO] $(timestamp)" | tee -a "$logs_file"