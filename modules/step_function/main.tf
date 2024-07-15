resource "aws_sfn_state_machine" "step_func_state_machine" {
  name     = local.step_function_name
  role_arn = aws_iam_role.step_func_role.arn

  definition = templatefile(
    local.step_function_definition, {
      apigw_endpoint             = var.apigw_endpoint
      send_approval_lambda_arn   = aws_lambda_function.step1.arn
      response_action_lambda_arn = aws_lambda_function.step2.arn
      dynamodb_log_table_name    = local.dynamodb_log_table_name
    }
  )
}