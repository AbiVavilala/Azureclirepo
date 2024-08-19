# Create a resource group
ResourceGroup=SpokeRG
VnetName=Spoke-Vnet
VnetPrefix=10.1.0.0/16
SubnetName=Spoke-subnet
SubnetPrefix=10.1.1.0/24
Location=Australiaeast
az group create -l $Location -n $ResourceGroup

# create a Vnet and subnet 
az network vnet create --name $VnetName --resource-group $ResourceGroup --address-prefix $VnetPrefix --subnet-name $SubnetName --subnet-prefixes $SubnetPrefix -l $Location

#create nsg
nsgname=SpokeNsg
echo create nsg

az network nsg create -g $ResourceGroup -n $nsgname --tags NSG=Spoke-nsg
az network nsg rule create -g $ResourceGroup --nsg-name $nsgname -n SpokeNsgRule --priority 110 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges '*' --access Allow --protocol Tcp --description "Allow all traffic"

# create VM 
echo create VM
name=spoke-vm
image="MicrosoftWindowsServer:WindowsServer:2019-datacenter-gensecond:latest"
size=Standard_D2ds_v4
AdminUser=azureuser
AdminPassword=Azure123456!


az vm create --resource-group $ResourceGroup --admin-username $AdminUser --authentication-type password --admin-password $AdminPassword --name $name --image $image  --size $size --vnet-name $VnetName --subnet $SubnetName --nsg $nsgname


#Retrieve Public IP Address

az vm show \
  --resource-group SpokeRG \
  --name spoke-vm \
  --show-details \
  --query [publicIps] \
  --output tsv

# delete RG after deploying
echo deleting Resourcegroup 
az group delete -n SpokeRG --force-deletion-types Microsoft.Compute/virtualMachines

# get list of images in a location 
az vm image list -l Australiaeast -f windowsserver


az vm create --resource-group HubRG --admin-username azureuser --authentication-type password --admin-password Sydney@12345678 --name Hub-VM --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest --size Standard_DS1_v2 --vnet-name Spoke-Vnet --subnet hub-subnet --nsg HubNsg
