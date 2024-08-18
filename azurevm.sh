# Create a resource group

az group create -l Australiaeast -n HubRG

# create a Vnet and subnet 
az network vnet create --name Hub-Vnet --resource-group HubRG --address-prefix 10.0.0.0/16 --subnet-name hub-subnet --subnet-prefixes 10.0.0.0/24 -l Australiaeast

#create nsg
echo create nsg

az network nsg create -g HubRG -n HubNsg --tags NSG=Hub
az network nsg rule create -g HubRG --nsg-name HubNsg -n HubNsgRule --priority 110 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges '*' --access Allow --protocol Tcp --description "Allow all traffic"

# create VM 
echo create VM

az vm create --resource-group HubRG --admin-username azureuser --authentication-type password --admin-password Avani@080323 --name Hub-VM --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest --size Standard_DS1_v2 --vnet-name Hub-Vnet --subnet hub-subnet --nsg HubNsg


#Retrieve Public IP Address

az vm show \
  --resource-group HubRG \
  --name Hub-VM \
  --show-details \
  --query [publicIps] \
  --output tsv


# delete RG after deploying
echo deleting Resourcegroup 
az group delete -n HubRG --force-deletion-types Microsoft.Compute/virtualMachines