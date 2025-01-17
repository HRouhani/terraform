#!/bin/bash

# Variables
VAULT_NAME="vault-lyfo61lu"
RESOURCE_GROUP="Security-Team-resources-xnty"

# Function to disable protection and delete backup data
disable_protection_and_delete_data() {
  local item_name=$1
  local container_name=$2
  local backup_management_type=$3

  echo "Disabling protection for item: $item_name in container: $container_name"
  az backup protection disable --vault-name $VAULT_NAME --resource-group $RESOURCE_GROUP --container-name $container_name --item-name $item_name --backup-management-type $backup_management_type --delete-backup-data --yes
}

# Step 1: List all backup items in the vault
echo "Listing backup items..."
backup_items=$(az backup item list --vault-name $VAULT_NAME --resource-group $RESOURCE_GROUP --query "[].{name:name, containerName:containerName, backupManagementType:properties.backupManagementType}" -o tsv)

# Step 2: Stop protection and delete backup data for each item
echo "Stopping protection and deleting backup data for backup items..."
while IFS=$'\t' read -r item_name container_name backup_management_type; do
  disable_protection_and_delete_data "$item_name" "$container_name" "$backup_management_type"
done <<< "$backup_items"

# Step 3: List all backup policies in the vault
echo "Listing backup policies..."
backup_policies=$(az backup policy list --vault-name $VAULT_NAME --resource-group $RESOURCE_GROUP --query "[].name" -o tsv)

# Step 4: Delete each backup policy
echo "Deleting backup policies..."
for policy in $backup_policies; do
  az backup policy delete --vault-name $VAULT_NAME --resource-group $RESOURCE_GROUP --name $policy
done

# Step 5: Check for ongoing jobs and retry until no jobs are found
echo "Checking for ongoing jobs..."
while true; do
  ongoing_jobs=$(az backup job list --vault-name $VAULT_NAME --resource-group $RESOURCE_GROUP --query "[?status!='Completed']")

  if [[ "$ongoing_jobs" == "[]" ]]; then
    echo "No ongoing jobs found. Proceeding with vault deletion..."
    break
  else
    echo "There are ongoing jobs in the vault. Waiting for them to complete..."
    sleep 60 # Wait for 60 seconds before checking again
  fi
done

# Step 6: Delete the Recovery Services vault
echo "Deleting the Recovery Services vault..."
az backup vault delete --name $VAULT_NAME --resource-group $RESOURCE_GROUP --yes

echo "Recovery Services vault '$VAULT_NAME' has been successfully deleted."

