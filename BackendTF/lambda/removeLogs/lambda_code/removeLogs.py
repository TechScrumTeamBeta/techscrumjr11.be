import boto3
from datetime import datetime, timedelta, timezone

s3 = boto3.resource('s3')
bucket_name = 'techscrum-log'
seconds_to_keep = 15
timezone_sydney = timezone(timedelta(hours=10), name='Australia/Sydney')

def lambda_handler(event, context):
    print(f"Starting cleanup for bucket {bucket_name}")
    bucket = s3.Bucket(bucket_name)
    current_time = datetime.now(timezone_sydney)
    print(f"Current time: {current_time}")
    for obj in bucket.objects.all():
        last_modified_time = obj.last_modified.astimezone(timezone_sydney)
        age = (current_time - last_modified_time).total_seconds()
        print(f"Object {obj.key} was last modified at {last_modified_time} ({age} seconds ago)")
        if age > seconds_to_keep:
            obj.delete()
            print(f"Deleted object: {obj.key}")
    print("Cleanup complete")