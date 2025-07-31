# ---------------------
# DynamoDB Table
# ---------------------
resource "aws_dynamodb_table" "transactions" {
  name         = "Transactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# ---------------------
# IAM Role & Policy for Lambda
# ---------------------
resource "aws_iam_role" "lambda_role" {
  name = "lambda-dynamodb-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_dynamodb_attach" {
  name       = "lambda-dynamodb-attach"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy_attachment" "lambda_basic_attach" {
  name       = "lambda-basic-attach"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ---------------------
# Lambda Function
# ---------------------
# Lambda for POST transaction
resource "aws_lambda_function" "add_transaction" {
  function_name = "Add_Transaction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  architectures = [
    "x86_64"
  ]
  filename      = "${path.module}/lambda/add_transaction.zip"  # packaged zip
  source_code_hash = filebase64sha256("${path.module}/lambda/add_transaction.zip")

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/Get_Transaction"
  }

  tracing_config {
    mode = "PassThrough"
  }
  # environment {
  #   variables = {
  #     TABLE_NAME = aws_dynamodb_table.transactions.name
  #   }
  # }
}

# Lambda for GET transactions
resource "aws_lambda_function" "get_transactions" {
  function_name = "Get_Transactions"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  architectures = [
    "x86_64"
  ]
  filename      = "${path.module}/lambda/get_transactions.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/get_transactions.zip")

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/Get_Transaction"
  }

  # environment {
  #   variables = {
  #     TABLE_NAME = aws_dynamodb_table.transactions.name
  #   }
  # }
}

# ---------------------
# API Gateway (HTTP API)
# ---------------------
resource "aws_apigatewayv2_api" "api" {
  name          = "Budget-Tracker"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins  = ["*"]                # For dev: allow all origins
    allow_methods  = ["GET", "POST", "OPTIONS"]
    allow_headers  = ["Content-Type"]
  }
}

# POST Transaction
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.add_transaction.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_transaction" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /transaction"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_transaction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# GET Transactions
resource "aws_apigatewayv2_integration" "lambda_get_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_transactions.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_transactions_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /transactions"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_get_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_get_invoke" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_transactions.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# OPTIONS /transaction
resource "aws_apigatewayv2_route" "options_transaction" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "OPTIONS /transaction"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "options_transactions" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "OPTIONS /transactions"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_get_integration.id}"
}


resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "dev"
  auto_deploy = true
}

