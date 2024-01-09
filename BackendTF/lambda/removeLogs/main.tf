module "lambda" {
  source              = "../../../modules/lambda"
  projectName         = var.projectName
  s3_bucket_name      = var.s3_bucket_name
  lambda_zipfile_name = var.lambda_zipfile_name
  lambda_name         = var.lambda_name
}

module "lambda-s3policy" {
  source          = "../../../modules/lambda-s3policy"
  projectName     = var.projectName
  lambda_name     = var.lambda_name
  lambdaRole_name = module.lambda.lambdaRole_name
}

module "eventbridge" {
  source          = "../../../modules/eventbridge"
  lambda_name_arn = module.lambda.lambda_name_arn
  description     = var.description
  schedule_expression = var.schedule_expression
}