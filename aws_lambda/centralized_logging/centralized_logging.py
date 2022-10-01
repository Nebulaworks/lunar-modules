import boto3
import os
import time
from botocore.exceptions import ClientError, WaiterError
from botocore.waiter import WaiterModel, create_waiter_with_client

waiter_delay = 2
waiter_max_attempts = 60
waiter_name = "KinesisFirehoseDeliveryStreamCreated"
waiter_config = {
  'version': 2,
  'waiters': {
    'KinesisFirehoseDeliveryStreamCreated': {
      'operation': 'DescribeDeliveryStream',
      'delay': waiter_delay,
      'maxAttempts': waiter_max_attempts,
      'acceptors': [
        {
          'matcher': 'path',
          'expected': 'ACTIVE',
          'argument': 'DeliveryStreamDescription.DeliveryStreamStatus',
          'state': 'success'
        },
        {
          'matcher': 'path',
          'expected': 'CREATING',
          'argument': 'DeliveryStreamDescription.DeliveryStreamStatus',
          'state': 'retry'
        },
        {
          'matcher': 'path',
          'expected': 'CREATING_FAILED',
          'argument': 'DeliveryStreamDescription.DeliveryStreamStatus',
          'state': 'failure'
        }
      ]
    }
  }
}


def does_kinesis_delivery_stream_exist(client, firehose_delivery_stream_name):
    waiter_model = WaiterModel(waiter_config)
    firehose_waiter = create_waiter_with_client(waiter_name, waiter_model, client) 
    try:
      delivery_stream_status = firehose_waiter.wait(DeliveryStreamName=firehose_delivery_stream_name)
    except WaiterError as e:
      print(f'[ERROR]: {e}')


def create_subscription_filter(client, log_groups, firehose_delivery_stream_arn, subscription_filter_role_arn):
  for log_group in log_groups:
    try:
      subscription_filters = client.describe_subscription_filters(
        logGroupName=log_group)["subscriptionFilters"]
      parsed_subscription_filters = list(filter(lambda subscription_filters: subscription_filters['destinationArn'] == firehose_delivery_stream_arn, subscription_filters))
      if not subscription_filters or not parsed_subscription_filters:
        client.put_subscription_filter(
          logGroupName=log_group,
          filterName=log_group,
          destinationArn=firehose_delivery_stream_arn,
          filterPattern="",
          roleArn=subscription_filter_role_arn,
          distribution="ByLogStream")
    except ClientError as e:
      print(f'[ERROR]: {e}')


def get_log_groups(client, cloudtrail_log_group):
  paginator = client.get_paginator('describe_log_groups')
  iterator = paginator.paginate()
  log_groups = [] 
  for page in iterator:
    for log_group in page["logGroups"]:
      # Assuming Cloudtrail is configured to foward logs directly to s3 in this region
      if not log_group["logGroupName"] == cloudtrail_log_group:
        log_groups.append(log_group["logGroupName"])
  return log_groups


def lambda_handler(event, context):
  kinesis_firehose_delivery_stream_arn = os.environ["kinesis_firehose_delivery_stream_arn"]
  kinesis_firehose_delivery_stream_name = kinesis_firehose_delivery_stream_arn.partition("/")[2]
  cloudwatch_logs_kinesis_firehose_role_arn = os.environ["cloudwatch_logs_kinesis_firehose_role_arn"]
  cloudtrail_log_group = os.environ["cloudtrail_log_group"]
  
  firehose_client = boto3.client('firehose', region_name=event['region'])
  cloudwatch_logs_client = boto3.client('logs', region_name=event['region'])  
  
  does_kinesis_delivery_stream_exist(firehose_client, kinesis_firehose_delivery_stream_name) 
  # cron event
  if event["detail-type"] == "Scheduled Event":
    log_groups = get_log_groups(cloudwatch_logs_client, cloudtrail_log_group) 
    create_subscription_filter(
      cloudwatch_logs_client,
      log_groups,
      kinesis_firehose_delivery_stream_arn,
      cloudwatch_logs_kinesis_firehose_role_arn
    )
  # creation of new log group
  else:
    new_log_group = [event["detail"]["requestParameters"]["logGroupName"]]
    create_subscription_filter(
      cloudwatch_logs_client,
      new_log_group,
      kinesis_firehose_delivery_stream_arn,
      cloudwatch_logs_kinesis_firehose_role_arn
    )
