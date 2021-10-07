terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_amplify_app" "example" {
  name       = "example"
  repository = "https://github.com/yukinissie/amplify-next-ts-isr-template"

  access_token = var.github_access_token

  enable_branch_auto_build = true

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - yarn install
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source    = "/<*>"
    status    = "404"
    target    = "/"
    condition = null
  }

  environment_variables = {
    ENV = "dev"
  }

  tags = {
    Group = var.aws_amplify_tags_group
  }
}
resource "aws_amplify_branch" "develop" {
  app_id      = aws_amplify_app.example.id
  branch_name = "main"
  framework   = "React"
  stage       = "PRODUCTION"
}
