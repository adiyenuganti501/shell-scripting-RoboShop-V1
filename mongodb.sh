#!/bin/bash

user_id=$(id -u)
logs_folder="/var/logs/mongodb"
logs_file="$logs_folder/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ "$user_id" -ne 0 ]; then
    echo -e "${R}You should run this script as root user or with sudo privileges.${N}"
    exit 1
fi

# if [ $# -eq 0 ] ; then
#      echo -e "${Y}Usage: $0 <package1> <package2> ...${N}"
#     exit 1
# fi

mkdir -p "$logs_folder" 

echo "Script started at $(date '+%F %T')" | tee -a "$logs_file"

validation(){
    if [ $1 -ne 0 ] ; then
    echo " $2 Installation failed. Check the logs for more details."  | tee -a "$logs_file"
    exit 1
    else
    echo " $2 Installation completed successfully." >> | tee -a "$logs_file"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validation $? "MongoDB Repo"

dnf install mongodb-org -y  &>> "$logs_file"
validation $? "MongoDB"

systemctl enable mongod
systemctl start mongod
validation $? "MongoDB Service enable and start"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validation $? "MongoDB Remote Connection Config"

systemctl restart mongod
validate $? "Restarting MongoDB"

echo "Script completed at $(date '+%F %T')" | tee -a "$logs_file"