## Sample Approve link
## https://${local.approval_apigw_endpoint}/execution?action=approve
output "apigw_endpoint" {
  value       = local.step_invoke_apiGWEndpoint
  description = "This is the API GW Endpoint used in the LINK to be use as a continue workflow for approval process."
}