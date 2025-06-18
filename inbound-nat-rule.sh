az network lb inbound-nat-rule list \
  --resource-group "cdp-dev-sea-rg" \
  --lb-name "cdp-dev-sea-lb" \
  --query "[].{Name:name, FrontendPort:frontendPort, BackendPort:backendPort, BackendIP:backendIpConfiguration.id}" \
  --output table