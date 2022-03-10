##
# (c) 2021 - CloudopsWorks OÜ - https://docs.cloudops.works/
#
data "aws_route53_zone" "app_domain" {
  name = var.domain_name
}

resource "aws_route53_record" "app_record_plain" {
  count = var.domain_name_weight < 0 ? 1 : 0

  zone_id = data.aws_route53_zone.app_domain.zone_id
  name    = "${var.domain_name_alias_prefix}.${var.domain_name}"
  type    = "CNAME"
  ttl     = var.default_domain_ttl
  records = [
    var.beanstalk_environment_cname
  ]
}

resource "aws_route53_record" "app_record_weighted" {
  count = var.domain_name_weight >= 0 ? 1 : 0

  zone_id         = data.aws_route53_zone.app_domain.zone_id
  name            = "${var.domain_name_alias_prefix}.${var.domain_name}"
  type            = "CNAME"
  ttl             = var.default_domain_ttl

  weighted_routing_policy {
    weight = var.domain_name_weight
  }

  set_identifier = "${var.release_name}-${var.namespace}"
  records = [
    var.beanstalk_environment_cname
  ]
}