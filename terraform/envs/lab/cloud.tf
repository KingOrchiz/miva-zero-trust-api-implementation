terraform {
  cloud {
    organization = "oche-miva"

    workspaces {
      name = "miva-zero-trust-api-lab"
    }
  }
}
