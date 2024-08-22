
resource "aws_ssm_document" "initial_ec2" {
  name          = "InitialEC2Document"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Deploy Backend"
    parameters = {
      destinationPathDatebase = {
        type        = "String"
        description = "Destination path on the EC2 instance for seeding.sql"
      }
      destinationPathBackend = {
        type        = "String"
        description = "Destination path on the EC2 instance for docker-compose.yaml"
      }
      databaseURL = {
        type        = "String"
        description = "Database URL including username, password, and endpoint"
      }
      backendPort = {
        type        = "String"
        description = "Port for the backend service"
      }
      vpcId = {
        type        = "String"
        description = "VPC ID"
      }
      stressDocument = {
        type        = "String"
        description = "Stress document name"
      }
      dockerId = {
        type        = "String"
        description = "Docker id"
      }
      dockerToken = {
        type        = "String"
        description = "Docker token"
      }
    }
    mainSteps = [
      # {
      #   action = "aws:runShellScript"
      #   name   = "GenerateSSHKey"
      #   inputs = {
      #     runCommand = [
      #       "echo '${tls_private_key.key-pair-for-ec2.private_key_pem}' > ./${aws_key_pair.ssh_key.key_name}.pem",
      #     ]
      #   },
      # },
      {
        action = "aws:runShellScript"
        name   = "DeployBackend"
        inputs = {
          runCommand = [
            "cat << EOF > {{ destinationPathDatebase }}",
            "${file("../../app/database/seeding.sql")}",
            "EOF",
            "sudo psql postgresql://{{ databaseURL }} < {{ destinationPathDatebase }}",
            "rm {{ destinationPathDatebase }}",
            "cat << EOG > {{ destinationPathBackend }}",
            "${file("../../docker-compose.yaml")}",
            "EOG",
            "TIME_SUFFIX=$(date +%Y%m%d%H%M%S)",
            "ENV_FILE=.env",
            "echo SERVER_PORT={{ backendPort }} | sudo tee $ENV_FILE",
            "echo DATABASE_URL=postgres://{{ databaseURL }} | sudo tee -a $ENV_FILE",
            "echo VPC_ID={{ vpcId }} | sudo tee -a $ENV_FILE",
            "echo STRESS_DOC_NAME={{ stressDocument }} | sudo tee -a $ENV_FILE",
            "echo '{{ dockerToken }}' | sudo docker login --username {{ dockerId }} --password-stdin",
            "sudo docker-compose -f {{ destinationPathBackend }} pull",
            "sudo docker-compose -f {{ destinationPathBackend }} down",
            "sudo docker-compose -f {{ destinationPathBackend }} -p $TIME_SUFFIX up -d",
            "sudo docker image prune -a -f"
          ]
        },
      },
    ]
  })

}



resource "aws_ssm_document" "stress_test" {
  name          = "StressTestDocument"
  document_type = "Command"
  content       = <<EOF
  {
    "schemaVersion": "2.2",
    "description": "Run stress command",
    "mainSteps": [
      {
        "action": "aws:runShellScript",
        "name": "runStress",
        "inputs": {
          "runCommand": ["stress -c 1 --timeout 300"]
        }
      }
    ]
  }
  EOF
}



# after creating ec2, run commond and output log to s3
resource "aws_s3_bucket" "ssm" {
  bucket        = "${local.project_name}-ssm"
  force_destroy = true
}
resource "aws_ssm_association" "log_s3" {
  depends_on = [aws_instance.backend]
  name       = aws_ssm_document.initial_ec2.name
  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
  # if not need log, can comment this block
  output_location {
    s3_bucket_name = aws_s3_bucket.ssm.bucket
  }
  parameters = {
    destinationPathDatebase = "./seeding.sql"
    destinationPathBackend  = "./docker-compose.yaml"
    databaseURL             = "${aws_db_instance.database.username}:${aws_db_instance.database.password}@${aws_db_instance.database.endpoint}/"
    backendPort             = 4000
    vpcId                   = aws_vpc.vpc.id
    stressDocument          = aws_ssm_document.stress_test.name
    dockerId                = var.docker_id
    dockerToken             = var.docker_token
  }
}

# # after creating ec2, run commond and output log to cloudwatch
# resource "aws_cloudwatch_log_group" "initial_ec2" {
#   name              = "/aws/ssm/${aws_ssm_document.initial_ec2.name}"
#   retention_in_days = 1
# }

# resource "null_resource" "output_to_cloudwatch" {
#   depends_on = [aws_instance.backend]
#   provisioner "local-exec" {
#     command = <<EOT
#       aws ssm send-command \
#       --document-name ${aws_ssm_document.initial_ec2.name} \
#       --targets Key=tag:Name,Values=${aws_instance.backend.tags["Name"]} \
#       --cloud-watch-output-config CloudWatchOutputEnabled=true,CloudWatchLogGroupName=${aws_cloudwatch_log_group.initial_ec2.name}
#     EOT
#   }
# }
