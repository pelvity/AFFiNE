# IAM Role for EC2 to allow pulling from ECR
resource "aws_iam_role" "ec2_ecr_role" {
  name = "affine-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for ECR Read Access
resource "aws_iam_policy" "ecr_read_policy" {
  name        = "affine-ecr-read-policy"
  description = "Allows EC2 to read from ECR"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "ecr_read_attach" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = aws_iam_policy.ecr_read_policy.arn
}

# Create Instance Profile to attach to EC2
resource "aws_iam_instance_profile" "ec2_ecr_profile" {
  name = "affine-ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr_role.name
}
