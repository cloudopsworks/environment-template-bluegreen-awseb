##
# (c) 2021 - CloudopsWorks OÜ - https://docs.cloudops.works/
#
data "aws_route53_zone" "app_domain" {
  count = var.domain_name_alias_prefix != "" ? 1 : 0

  name = var.domain_name
}

resource "aws_route53_record" "app_record_plain" {
  count = var.domain_name_alias_prefix != "" && var.domain_name_weight <= 0 ? 1 : 0

  zone_id = data.aws_route53_zone.app_domain.0.id
  name    = "${var.domain_name_alias_prefix}.${var.domain_name}"
  type    = "CNAME"
  ttl     = var.default_domain_ttl
  records = [
    aws_elastic_beanstalk_environment.beanstalk_environment.cname
  ]
}

resource "aws_route53_record" "app_record_weighted" {
  count = var.domain_name_alias_prefix != "" && var.domain_name_weight >= 0 ? 1 : 0

  zone_id = data.aws_route53_zone.app_domain.0.id
  name    = "${var.domain_name_alias_prefix}.${var.domain_name}"
  type    = "CNAME"
  ttl     = var.default_domain_ttl

  weighted_routing_policy {
    weight = var.domain_name_weight
  }

  set_identifier = var.release_name
  records = [
    aws_elastic_beanstalk_environment.beanstalk_environment.cname
  ]
}