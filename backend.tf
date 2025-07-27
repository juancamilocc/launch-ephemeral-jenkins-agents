terraform {
    backend "s3" {
        bucket         = "terraform-backend-<YOUR_AWS_ID_ACCOUNT>"
        key            = "terraform.tfstate"
        region         = "<YOUR_AWS_REGION>"
        encrypt        = true
        use_lockfile   = true
    }
}