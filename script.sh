#!/bin/bash

#install aws-cli
sudo apt-get update -y
sudo apt-get install -y awscli

# Add crontab entry to run this script every minute
(crontab -l ; echo "* * * * * /home/ubuntu/script.sh") | crontab -


cat << 'EOF' > /home/ubuntu/script.sh

#!/bin/bash

export AWS_DEFAULT_REGION=ap-south-1

#Fetch load average of 5 minutes interval
load=$(cat /proc/loadavg | awk '{print $2}')

# Get the Auto Scaling Group name from the instance metadata
asg_name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" --query "Tags[?Key=='aws:autoscaling:groupName'].Value" --output text)

# Get the list of instance IDs in the Auto Scaling Group
instance_ids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asg_name --query "AutoScalingGroups[0].Instances[].InstanceId" --output text)

# Loop through each instance and send metric data
for instance_id in $instance_ids; do
    echo "Instance ID: $instance_id, Load: $load" > /home/ubuntu/load_info_$instance_id.txt
    aws cloudwatch put-metric-data --metric-name="load" --namespace "ServerLoad" --dimensions ASG="$asg_name" --value "$load"
done

EOF

#make script executable
sudo chmod +x /home/ubuntu/script.sh
