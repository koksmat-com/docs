---
title: "List Subscriptions"
description: "Description for list-subscriptions.ps1."
tags: []
author: "Unknown"
---

```powershell
#>

. "$root/.koksmat/pwsh/check-env.ps1" "GRAPH_APPID", "GRAPH_APPSECRET", "GRAPH_APPDOMAIN", "REQUEST", "PNPAPPID", "PNPTENANTID", "PNPCERTIFICATE", "KOKSMATSITE", "NOTICATION_URL"
. "$root/.koksmat/pwsh/connectors/graph/connect.ps1"

$notificationUrl = $env:NOTICATION_URL
```

## Getting list from the site


```powershell


$accessToken = $env:GRAPH_ACCESSTOKEN

GraphAPIAll $accessToken "GET" "https://graph.microsoft.com/v1.0/subscriptions"
```

### Environment Variables Used

| Environment Variable |
|----------------------|| GRAPH_ACCESSTOKEN |
| NOTICATION_URL |


