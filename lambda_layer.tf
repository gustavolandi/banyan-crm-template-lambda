#define variables
locals {
  layer_path        = "lambda_layer"
  layer_zip_name    = "layer-${var.lambda_name}.zip"
  layer_name        = "layer-${var.lambda_name}-${var.environment}"
  requirements_name = "requirements.txt"
  requirements_path = "${path.module}/${local.layer_path}/${local.requirements_name}"
}

resource "terraform_data" "lambda_layer" {
  triggers_replace = {
    requirements = filesha1(local.requirements_path)
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
      cd ${local.layer_path}
      rm -rf python
      mkdir python
      pip3 install -r ${local.requirements_name} -t python/
      zip -r ${local.layer_zip_name} python/
    EOT
  }
}

# upload zip file to s3
resource "aws_s3_object" "lambda_layer_zip" {
  bucket     = data.terraform_remote_state.bucket_pipeline.outputs.bucket_name_pipelines_lambda_name
  key        = "lambda_layers/${local.layer_name}/${local.layer_zip_name}"
  source     = "${local.layer_path}/${local.layer_zip_name}"
  depends_on = [terraform_data.lambda_layer] # triggered only if the zip file is created
}

# create lambda layer from s3 object
resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket           = data.terraform_remote_state.bucket_pipeline.outputs.bucket_name_pipelines_lambda_name
  s3_key              = aws_s3_object.lambda_layer_zip.key
  layer_name          = local.layer_name
  compatible_runtimes = ["python3.11"]
  skip_destroy        = true
  depends_on          = [aws_s3_object.lambda_layer_zip] # triggered only if the zip file is uploaded to the bucket
}