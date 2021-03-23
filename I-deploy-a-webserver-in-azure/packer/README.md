# Create resource group
Do it in portal (**packer-rg** in this example)

# Export credentials
```bash
export CLIENT_ID=YOUR_CLIENT_ID && export CLIENT_SECRET=YOUR_CLIENT_SECRET && export SUBSCRIPTION_ID=YOUR_SUBSCRIPTION_ID
```

# Build packer image
```bash
packer build ubuntu-webserver-packer.json
```

# Delete packer image
```bash
az image delete -g packer-rg -n grayfox-ubuntu18.04
```