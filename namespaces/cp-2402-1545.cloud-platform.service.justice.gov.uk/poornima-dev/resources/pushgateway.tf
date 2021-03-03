module "pushgateway" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-pushgateway?ref=1.1"
  namespace              = var.namespace
}