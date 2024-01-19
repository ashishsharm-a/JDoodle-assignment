# JDoodle-assignment
# AWS AutoScaling Group with Custom Metrics

This repository contains Terraform code to create an AutoScaling Group (ASG) in AWS based on custom load metrics. The ASG dynamically scales instances in and out based on load averages, and it also performs a daily refresh of all instances. It also contains script for pushing custom metrics to AWS Cloudwatch.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Custom Metrics](#custom-metrics)
- [AWS Resources Created](#aws-resources-created)
- [Notifications](#notifications)
- [Contact](#contact)

## Prerequisites

Before using this Terraform code, make sure you have the following:

- Terraform installed.
- AWS credentials configured on your machine.
- An existing EC2 key pair for instances.
- IAM Role to attach with EC2 instances for pushing metrics

## Setup

1. Clone this repository:

2. Initialize the Terraform configuration:

    ```bash
    terraform init
    ```

3. Plan and Apply the Terraform configuration:

    ```bash
    terrform plan
    terraform apply
    ```

    Follow the prompts to confirm and apply changes.

## Usage

The Terraform configuration creates an AutoScaling Group with the specified configurations. Instances are scaled in and out based on custom load metrics.

To view the scaling policies and alarms, navigate to the [AWS Management Console](https://aws.amazon.com/console/), and go to the Auto Scaling section.

## Custom Metrics

The custom metrics used for scaling are load averages, and they are pushed to CloudWatch from each EC2 instance. The script for pushing metrics is located in the `script.sh` file in the root directory.

## AWS Resources Created

- AutoScaling Group
- Launch Configuration
- CloudWatch Alarms
- CloudWatch Metric Filters
- SNS Topic for Email Alerts

## Notifications

Email notifications for scaling events and daily refresh are sent to the specified email address. Ensure that the email subscription is confirmed.

## Contact

For any details please reach out at ashisharun7@gmail.com .
