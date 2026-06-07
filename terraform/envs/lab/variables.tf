variable "project" {
  type    = string
  default = "miva-zt-api-auth"
}

variable "environment" {
  type    = string
  default = "lab"
}

variable "azure_location" {
  type    = string
  default = "westeurope"
}

variable "huawei_region" {
  type    = string
  default = "af-south-1"
}

variable "tags" {
  type = map(string)
  default = {
    project     = "miva-zt-api-auth"
    environment = "lab"
    owner       = "oche-eluma"
    purpose     = "academic-research"
  }
}
