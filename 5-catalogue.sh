#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file="$logs_folder/${0}.log"
domine_name="khiranya.online"
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
    echo " $(timestamp) [ERROR] $2.. ${R}FAILED${N}"  | tee -a "$logs_file"
    exit 1
    else
    echo " $(timestamp) [INFO] $2.. ${G}SUCCESS${N}"  | tee -a "$logs_file"
    fi
}

echo "Script started at [INFO] $(timestamp)" | tee -a "$logs_file"

dnf module disable  nodejs -y -y &>> $logs_file
dnf module enable  nodejs:24 -y &>> $logs_file
dnf install nodejs -y &>> $logs_file
validation $? "NodeJS Installation"



