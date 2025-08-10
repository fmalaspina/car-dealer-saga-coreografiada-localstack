output "topic_arn" {
  value = aws_sns_topic.car_events.arn
}

output "orders_url" {
  value = aws_sqs_queue.orders.id
}

output "inventory_url" {
  value = aws_sqs_queue.inventory.id
}

output "billing_url" {
  value = aws_sqs_queue.billing.id
}

output "contracts_url" {
  value = aws_sqs_queue.contracts.id
}

output "app_access_key_id" {
  value = aws_iam_access_key.app_key.id
}

output "app_secret_access_key" {
  value     = aws_iam_access_key.app_key.secret
  sensitive = true
}