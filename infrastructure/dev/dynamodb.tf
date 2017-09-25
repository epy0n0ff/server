## Alert Table
resource "aws_dynamodb_table" "alert_table" {
  name           = "Alert"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "OrgName"
  range_key      = "CreatedAt"

  local_secondary_index {
    name            = "OrgNameStatusIndex"
    range_key       = "Status"
    projection_type = "ALL"
  }

  local_secondary_index {
    name            = "OrgNameIsOpenIndex"
    range_key       = "IsOpen"
    projection_type = "ALL"
  }

  attribute {
    name = "OrgName"
    type = "S"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }

  attribute {
    name = "Status"
    type = "S"
  }

  attribute {
    name = "IsOpen"
    type = "N"
  }

  tags {
    Name        = "Alert Table"
    Environment = "development"
  }
}

resource "aws_dynamodb_table" "call_history_table" {
  name           = "CallHistory"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "IncidentId"
  range_key      = "CreatedAt"

  local_secondary_index {
    name            = "IncidentIdCognitoIdIndex"
    range_key       = "CognitoId"
    projection_type = "ALL"
  }

  local_secondary_index {
    name            = "IncidentIdActionIndex"
    range_key       = "Action"
    projection_type = "ALL"
  }

  attribute {
    name = "IncidentId"
    type = "N"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }
}
