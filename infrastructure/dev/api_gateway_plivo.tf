variable "plivo_request_templates" {
  type = "map"

  default = {
    "application/x-www-form-urlencoded" = <<EOF
#set($allParams = $input.params())
{
"body-json" : $input.json('$'),
"params" : {
#foreach($type in $allParams.keySet())
    #set($params = $allParams.get($type))
"$type" : {
    #foreach($paramName in $params.keySet())
    "$paramName" : "$util.escapeJavaScript($params.get($paramName))"
        #if($foreach.hasNext),#end
    #end
}
    #if($foreach.hasNext),#end
#end
},
"context" : {
    "account-id" : "$context.identity.accountId",
    "api-id" : "$context.apiId",
    "api-key" : "$context.identity.apiKey",
    "authorizer-principal-id" : "$context.authorizer.principalId",
    "caller" : "$context.identity.caller",
    "cognito-authentication-provider" : "$context.identity.cognitoAuthenticationProvider",
    "cognito-authentication-type" : "$context.identity.cognitoAuthenticationType",
    "cognito-identity-id" : "$context.identity.cognitoIdentityId",
    "cognito-identity-pool-id" : "$context.identity.cognitoIdentityPoolId",
    "http-method" : "$context.httpMethod",
    "stage" : "$context.stage",
    "source-ip" : "$context.identity.sourceIp",
    "user" : "$context.identity.user",
    "user-agent" : "$context.identity.userAgent",
    "user-arn" : "$context.identity.userArn",
    "request-id" : "$context.requestId",
    "resource-id" : "$context.resourceId",
    "resource-path" : "$context.resourcePath"
    }
}
EOF
  }
}

#
# /plivo
#
## resource
resource "aws_api_gateway_resource" "plivo" {
  rest_api_id = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  parent_id   = "${aws_api_gateway_rest_api.incident-app-team-a.root_resource_id}"
  path_part   = "plivo"
}

module "plivo_makecall" {
  source               = "github.com/epy0n0ff/tf_aws_apigateway_apex"
  resource_path        = "/${aws_api_gateway_resource.plivo.path_part}"
  http_method          = "POST"
  resource_id          = "${aws_api_gateway_resource.plivo.id}"
  rest_api_id          = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  apex_function_arns   = "${var.apex_function_arns}"
  lambda_function_name = "post_makecall"
  request_templates    = "${var.plivo_request_templates}"
}


#
# /plivo/callback
#
## resource
resource "aws_api_gateway_resource" "plivo_callback" {
  rest_api_id = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  parent_id   = "${aws_api_gateway_resource.plivo.id}"
  path_part   = "callback"
}

## /plivo/callback/{incidentId}
#
## resource
resource "aws_api_gateway_resource" "plivo_callback_incidentid" {
  rest_api_id = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  parent_id   = "${aws_api_gateway_resource.plivo_callback.id}"
  path_part   = "{incidentId}"
}

## /plivo/callback/{incidentId}/{cognitoId}
#
## resource
resource "aws_api_gateway_resource" "plivo_callback_incidentid_cognitoid" {
  rest_api_id = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  parent_id   = "${aws_api_gateway_resource.plivo_callback_incidentid.id}"
  path_part   = "{cognitoId}"
}

module "plivo_callback_incidentid_cognitoid" {
  source               = "github.com/epy0n0ff/tf_aws_apigateway_apex"
  resource_path        = "${format("/%s/%s/*/*",aws_api_gateway_resource.plivo.path_part,aws_api_gateway_resource.plivo_callback.path_part)}"
  http_method          = "POST"
  resource_id          = "${aws_api_gateway_resource.plivo_callback_incidentid_cognitoid.id}"
  rest_api_id          = "${aws_api_gateway_rest_api.incident-app-team-a.id}"
  apex_function_arns   = "${var.apex_function_arns}"
  lambda_function_name = "post_plivo_callback"
  request_templates    = "${var.plivo_request_templates}"
}
