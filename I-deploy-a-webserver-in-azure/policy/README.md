# Create policy definition
az policy definition create --name enforce-tags --display-name "Enforce tags" --description "Enforce tags for new subscriptions" --rules enforce-tags/azurepolicy.rules.json --params enforce-tags/azurepolicy.parameters.json

# Create policy assignment
az policy assignment create --policy enforce-tags --display-name "Enforce the name tag" -p enforce-tags/azurepolicy.parameters.set.json

# List assignments
az policy assignment list
