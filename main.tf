terraform {
  backend "local" {
    path = ".terraform/terraform.tfstate"
  }
}

provider "pagerduty" {
  token = ""
}

data "pagerduty_vendor" "cloudwatch" {
  name = "Amazon Cloudwatch"
}

resource "pagerduty_user" "test-user" {
  name  = "TestMan"
  email = "test-user@example.com"
  role  = "limited_user"
}

resource "pagerduty_escalation_policy" "test-escalation-policy" {
  name        = "test"
  description = ""

  rule {
    escalation_delay_in_minutes = 30

    target {
      type = "user_reference"
      id   = "${pagerduty_user.test-user.id}"
    }
  }
}

resource "pagerduty_service" "test-service" {
  name        = "test service"
  description = ""

  escalation_policy = "${pagerduty_escalation_policy.test-escalation-policy.id}"

  incident_urgency_rule {
    type    = "constant"
    urgency = "low"
  }
}

resource "pagerduty_service_integration" "test-integration-cloudwatch" {
  name    = "Amazon CloudWatch"
  service = "${pagerduty_service.test-service.id}"
  vendor  = "${data.pagerduty_vendor.cloudwatch.id}"
}

resource "pagerduty_service_integration" "test-integration-email" {
  name              = "Test"
  type              = "generic_email_inbound_integration"
  service           = "${pagerduty_service.test-service.id}"
  integration_email = "test-integration@jsaito-email-integration.pagerduty.com"
}
