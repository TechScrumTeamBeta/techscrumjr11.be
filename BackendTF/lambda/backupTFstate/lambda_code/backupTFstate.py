import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):
    source_bucket = "techscrum-tf-state-hub"
    destination_bucket = "backup-techscrum-tf-state"
    object_key = event['Records'][0]['s3']['object']['key']
    copy_source = {'Bucket': source_bucket, 'Key': object_key}
    copy_params = {'Bucket': destination_bucket, 'CopySource': copy_source, 'Key': object_key}
    response = s3.copy_object(**copy_params)
    print("S3 object copied successfully")
