#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file="$logs_folder/${0}.log"
domine_name="khiranya.online"
scripts_dir=$(dirname "$(realpath "$0")")
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

id roboshop &>> $logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
    validation $? "Creating system user"
else
    echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
fi

rm -rf /app
validation $? "Removeing Old Code"

mkdir -p /app

validation $? "Creating app Directory"


curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $logs_file
validation $? "Downloading catalogue"

cd /app
unzip /tmp/catalogue.zip &>> $logs_file
validation $? "Unzipping catalogue"

npm install &>> $logs_file
validation $? "Installing dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/catalogue.service"
cp "$scripts_dir/catalogue.service" /etc/systemd/system/catalogue.service

systemctl daemon-reload &>> $logs_file
systemctl enable catalogue &>> $logs_file
systemctl start catalogue &>> $logs_file
validation $? "Starting and enabling catalogue"

cp "$scripts_dir/mongo.repo" /etc/yum.repos.d/mongo.repo
validation $? "Adding Mongo repo"


dnf install mongodb-mongosh -y &>> $logs_file
validation $? "Installing MongoDB Client"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>> $logs_file)
validation $? "Connecting to MongoDB"

if [ "$product_count" -eq 0 ]; then
    mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>> $logs_file
    validation $? "Loading products"
else
    echo -e "$(timestamp) [INFO] Products are already loaded...${Y}SKIPPING${N}"
fi

systemctl restart catalogue
validation $? "Restarting Catalogue"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file

