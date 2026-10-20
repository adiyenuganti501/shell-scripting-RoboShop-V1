#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/mysql"
logs_file="$logs_folder/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $"user_id" -ne 0 ]; then
    echo -e "${R}You should run this script as root user or with sudo privileges.${N}"
    exit 1
fi
mkdir -p "$logs_folder"

timestamp(){
    date "+%F %T" 
}

validation(){
    if [ $1 -ne 0 ] ; then
    echo " $2 Installation failed. Check the logs for more details."  | tee -a "$logs_file"
    exit 1
    else
    echo " $2 Installation completed successfully."  | tee -a "$logs_file"
    fi
}

echo "Script started at [INFO] $(timestamp)" | tee -a "$logs_file"

dnf module enable mysql:8.4 -y $>> $logs_file
dnf install mysql-server -y  $>> $logs_file
validation $? "MySQL"

systemctl enable mysqld  $>> $logs_file
systemctl start mysqld
validation $? "Enable and start MySQL"

mysql_secure_installation --set-root-pass RoboShop@1  $>> $logs_file
validation $? "Setup MySQL root password"

echo "Script completed at [INFO] $(timestamp)" | tee -a "$logs_file"
