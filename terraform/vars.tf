variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group para el Caso Práctico."
  default     = "rg-casopractico2"
}

variable "location" {
  type        = string
  description = "Región de Azure donde desplegar los recursos."
  default     = "westeurope"
}

variable "acr_name" {
  type        = string
  description = "Nombre para el Azure Container Registry."
}
