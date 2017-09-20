terraform {
  backend "s3" {
    bucket = "incident-app-team-a-tfstate-epy0n0ff"
    key    = "incident-app-team-a-dev.tfstate"
    region = "ap-northeast-1"
  }
}
