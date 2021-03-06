provider "pingdom" {}

resource "pingdom_check" "dev-pk-poornima-dev-pingdom-check" {
  type                     = "http"
  name                     = "poornima-dev - cloud-platform - Healthcheck"
  host                     = "dev-pk.apps.cp-2402-1545.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_poornima_dev_app,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [111647]
}
