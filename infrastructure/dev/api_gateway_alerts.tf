variable "alerts_request_templates" {
  type = "map"

  default = {
    "application/json" = <<EOF
$input.json('$')
EOF
  }
}

#
# /alerts
#
## resource
resource "aws_api_gateway_resource" "alerts" {
  rest_api_id = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  parent_id   = "${aws_api_gateway_rest_api.incident-app-team-a.root_resource_id}"
  path_part   = "alerts"
}

module "get_alerts" {
  source             = "github.com/epy0n0ff/tf_aws_apigateway_apex"
  resource_name      = "alerts"
  http_method        = "GET"
  parent_path_part   = ""
  resource_id        = "${aws_api_gateway_resource.alerts.id}"
  rest_api_id        = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  apex_function_arns = "${var.apex_function_arns}"
  request_templates  = {}
}

#
# /alerts/mackerel
#
## resource
resource "aws_api_gateway_resource" "alerts_mackerel" {
  rest_api_id = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  parent_id   = "${aws_api_gateway_resource.alerts.id}"
  path_part   = "mackerel"
}

module "alerts_mackerel" {
  source             = "github.com/epy0n0ff/tf_aws_apigateway_apex"
  resource_name      = "mackerel"
  parent_path_part   = "${aws_api_gateway_resource.alerts.path_part}"
  http_method        = "POST"
  resource_id        = "${aws_api_gateway_resource.alerts_mackerel.id}"
  rest_api_id        = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  apex_function_arns = "${var.apex_function_arns}"
  request_templates  = "${var.alerts_request_templates}"
}
