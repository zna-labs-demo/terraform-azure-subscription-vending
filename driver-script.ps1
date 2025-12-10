  $body = @{
      app_id = "a954299"
      owner_email = "demo@example.com"
      cost_center = "12345678"
  } | ConvertTo-Json

  Invoke-RestMethod -Method Post -Uri "https://prod-05.eastus.logic.azure.com:443/workflows/2965d4b092df4100a58d228c486f2992/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=lyQ1dPF3ZGaR7YO-EFSh0-y77porDC9_cV8zDHGqpmI" -ContentType "application/json" -Body $body
