output "api_endpoint" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}

output "lambda_arn" {
  value = aws_lambda_function.add_transaction.arn
}

output "dynamodb_table" {
  value = aws_dynamodb_table.transactions.name
}
