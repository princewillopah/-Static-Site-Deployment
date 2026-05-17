




```yaml
# Apply Bootstrap
    cd Bootstrap-hosted-zone
    terraform init
    terraform apply
```

```yaml
# Terraform outputs would be something like:
hosted_zone_id = "Z03063322PRJEBX4TCBCS"
hosted_zone_name = "opah.name.ng"
name_servers = tolist([
  "ns-1276.awsdns-31.org",
  "ns-1853.awsdns-39.co.uk",
  "ns-411.awsdns-51.com",
  "ns-719.awsdns-25.net",
])

# Copy them below into your registrar.
  ns-1276.awsdns-31.org
  ns-1853.awsdns-39.co.uk
  ns-411.awsdns-51.com
  ns-719.awsdns-25.net

#create a custom nameserver and enter each of these nameservers to fill the box - see screenshot below

# Wait for propagation.

🕒 DNS propagation: 15 mins to 24 hours (usually < 1 hour).
🔍 Verify with: 
        - dig NS opah.name.ng or https://dnschecker.org or nslookup -type=NS opah.name.ng
        - dig +trace opah.name.ng NS      # Check what nameservers the TLD reports for your domain # (this queries the .com TLD directly, bypassing your cache)
        - dig @ns-1234.awsdns-12.com opah.name.ng A    # Ask a specific Route 53 nameserver directly
        - dig @8.8.8.8 opah.name.ng A        # Check from a public DNS resolver to see what most users would get
# Check propagation across global resolvers. (Use a tool like https://dnschecker.org for a visual map)


# for a precise diagnosis should the dns not propagating quickly:

dig +trace NS opah.name.ng
dig NS opah.name.ng @8.8.8.8


to confirm whether it's 
    - registrar-level misconfiguration
    - registry delay
    - or Route53 zone mismatch

# Check multiple resolvers
dig NS opah.name.ng @1.1.1.1
dig NS opah.name.ng @9.9.9.9
dig NS opah.name.ng @8.8.8.8


# Force authoritative path
    dig +trace opah.name.ng

```
<br>

![This is an alt text.](Screenshot%202026-05-17%20070735v.png "This is a sample image.")


