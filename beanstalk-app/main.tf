provider "aws" {
  region = "us-east-1"
}

resource "aws_elastic_beanstalk_application" "my_app1" {
  name        = "my-app1"
  description = "My Elastic Beanstalk Application"
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-bucketB"
  acl    = "private"
}

resource "aws_s3_bucket_object" "app_version" {
  bucket = aws_s3_bucket.app_bucket.bucket
  key    = "application.zip"
  source = "C:/Users/DELL/Downloads/Compressed/a1-azizfurkanyilmaz-main/a1-azizfurkanyilmaz-main/beanstalk-app/application.zip"
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name        = "v1"
  application = aws_elastic_beanstalk_application.my_app1.name
  bucket      = aws_s3_bucket.app_bucket.bucket
  key         = aws_s3_bucket_object.app_version.key
}

resource "aws_elastic_beanstalk_environment" "my_app_env1" {
  name                = "my-app-env1"
  application         = aws_elastic_beanstalk_application.my_app1.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.3 running Docker"
  version_label       = aws_elastic_beanstalk_application_version.app_version.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }
}
