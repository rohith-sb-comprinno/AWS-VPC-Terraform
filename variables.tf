# variables.tf
variable "access_key" {
     default = "accesskey"
}
variable "secret_key" {
     default = "sceretkey"
}
variable "region" {
     default = "ap-south-1"
}
variable "availabilityZone1" {
     default = "ap-south-1a"
}
variable "availabilityZone2" {
     default = "ap-south-1b"
}
variable "instanceTenancy" {
    default = "default"
}
variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}
variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}
variable "subnetCIDRblock1" {
    default = "10.0.1.0/24"
}
variable "subnetCIDRblock2" {
    default = "10.0.2.0/24"
}
variable "subnetCIDRblock3" {
    default = "10.0.3.0/24"
}
variable "subnetCIDRblock4" {
    default = "10.0.4.0/24"
}
variable "subnetCIDRblock5" {
    default = "10.0.5.0/24"
}
variable "subnetCIDRblock6" {
    default = "10.0.6.0/24"
}
variable "destinationCIDRblock" {
    default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
    default = [ "0.0.0.0/0" ]
}
variable "egressCIDRblock" {
    default = [ "0.0.0.0/0" ]
}
variable "mapPublicIP" {
    default = true
}

# end of variables.tf

