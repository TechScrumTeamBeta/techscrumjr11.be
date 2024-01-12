######################iam role##################
data "aws_iam_policy_document" "yace_policy_document" {
  statement {
    actions = [
      "tag:GetResources",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "apigateway:GET",
      "aps:ListWorkspaces",
      "autoscaling:DescribeAutoScalingGroups",
      "dms:DescribeReplicationInstances",
      "dms:DescribeReplicationTasks",
      "ec2:DescribeTransitGatewayAttachments",
      "ec2:DescribeSpotFleetRequests",
      "shield:ListProtections",
      "storagegateway:ListGateways",
      "storagegateway:ListTagsForResource",
      "es:ESHttpGet",
      "es:ESHttpHead"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "yace_policy" {
  name        = "yace_policy"
  description = "yace policy"
  policy      = data.aws_iam_policy_document.yace_policy_document.json
}

resource "aws_iam_role" "ec2_yace_role" {
  name = "ec2_yace_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "yace-ec2-role-attach" {
  role       = aws_iam_role.ec2_yace_role.name
  policy_arn = aws_iam_policy.yace_policy.arn
}

resource "aws_iam_role_policy_attachment" "yace-ec2-role-attach-OpenSearch" {
  role       = aws_iam_role.ec2_yace_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
}
######################ec2#################################

resource "aws_iam_instance_profile" "ec2_yace_profile" {
  name = "${aws_iam_role.ec2_yace_role.name}-profile"
  role = aws_iam_role.ec2_yace_role.name
}
//generate ssh-key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "monitor-instance" {
  ami                    = "ami-05c3b6a7b33d2952c" # This is the Amazon Linux 2 LTS AMI ID for ap-souteast-2
  instance_type          = "t2.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.monitor_sg_id]
  key_name               = aws_key_pair.generated_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_yace_profile.name
  tags = {
    Name = "monitor-instance"
  }
}

//save the private key in local
resource "local_file" "private_key" {
  sensitive_content = tls_private_key.ssh.private_key_pem
  filename          = "./private_key.pem"
  file_permission   = "0600"
}

data "template_file" "ansible_playbook" {
  template = file("./provision_ec2.yml.tpl")

  vars = {
    ansible_host = aws_instance.monitor-instance.public_ip
  }
}

resource "local_file" "AnsiblePlaybook" {
  content  = data.template_file.ansible_playbook.rendered
  filename = "./provision_ec2.yml"
}

resource "local_file" "AnsibleInventory" {
  content  = "[ec2-instances]\n${aws_instance.monitor-instance.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=./private_key.pem"
  filename = "./inventory.ini"
}

resource "null_resource" "ansible_provisioner" {
  # Trigger re-provisioning each time the instance changes
  triggers = {
    instance_id = aws_instance.monitor-instance.id
  }

  provisioner "local-exec" {
    command = <<EOF
      echo "Waiting for SSH to become available..."
      while ! nc -z -v -w5 ${aws_instance.monitor-instance.public_ip} 22; do 
        sleep 5
      done

      echo "SSH is now available. Running ansible-playbook..."
      ansible-playbook -i ./inventory.ini ./provision_ec2.yml
    EOF
  }
}