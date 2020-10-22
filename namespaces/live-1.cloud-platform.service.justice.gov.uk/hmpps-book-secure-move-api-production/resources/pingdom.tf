provider "pingdom" {
}

# Integration IDs
# 94314 = #pecs-alerts

resource "pingdom_check" "book-secure-move-api-check" {
  type                     = "http"
  name                     = "Book Secure Move API - api.bookasecuremove.service.justice.gov.uk"
  host                     = "api.bookasecuremove.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping.json"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [94314]
}
