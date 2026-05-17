
output "hosted_zone_id" {
  value = aws_route53_zone.primary.zone_id
}
output "hosted_zone_name" {
  value = aws_route53_zone.primary.name
}
output "name_servers" {
  value = aws_route53_zone.primary.name_servers
}