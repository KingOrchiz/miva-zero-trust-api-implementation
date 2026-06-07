locals {
  prefix           = "${var.project}-${var.environment}"
  create_dedicated = var.deployment_mode == "dedicated-lab"
}

# Huawei Cloud infrastructure is intentionally staged. We will finalize VPC,
# subnet, CCE, ELB, DEW/secrets, LTS, and Cloud Eye resources after Oche confirms
# the exact dev/staging project or approves a dedicated lab deployment.

# This module currently captures the selected deployment mode and known existing
# environment identifiers so Terraform plans can remain safe before credentials
# and target environment details are confirmed.
