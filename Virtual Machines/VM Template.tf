# Configure the Azure provider
provider "azurerm" { 
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

 # Populate variables.

variable "vmname" {
  type        = string
  description = "The name of the VM"
  default = "test01"
}

 variable "nicname" {
  type        = string
  description = "The name of the NIC"
  default = "test01-nic01"
}

 variable "osdisk" {
  type        = string
  description = "The name of the OS Disk"
  default = "test01-diskos"
}

 variable "datadisk01" {
  type        = string
  description = "The name of the OS Disk"
  default = "test01-disk01"
}

 variable "size" {
  type        = string
  description = "The VM instance size"
  default = "Standard_E4-2s_v3"
}

 variable "Environment" {
  type        = string
  description = "DEV, QA, PreProd or Prodution"
  default = "DEV"
}

 variable "Owner" {
  type        = string
  description = "Who is the business owner?"
  default = "Bernard Murphy"
}

 variable "Project" {
  type        = string
  description = "What is the name of the project?"
  default = "DBP"
}

 variable "RG" {
  type        = string
  description = "Resource Group Name"
  default = "RG-DBPDEV"
}

 variable "Location" {
  type        = string
  description = "Azure Region"
  default = "ukwest"
}



#



resource "azurerm_resource_group" "resourcegroup" {
        name = var.RG
        location = var.Location
        tags = {
            Project = var.Project
            Environment = var.Environment
            "Business Owner" = var.Owner

        }
}



#refer to a subnet
data "azurerm_subnet" "subnet" {
  name                 = "App01"
  virtual_network_name = "VNET-DBPDEVUKW"
  resource_group_name  = "RG-DBPDEV"
}


# create a network interface
resource "azurerm_network_interface" "nic" {
  name                =  var.nicname
  location            = "${resource.azurerm_resource_group.resourcegroup.location}"
  resource_group_name = "${resource.azurerm_resource_group.resourcegroup.name}"
  tags = {
            Project = var.Project
            Environment = var.Environment
            "Business Owner" = var.Owner

        }
        


  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    
  }
  enable_accelerated_networking = "true"
   
}




# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
    name                  = "${var.vmname}"
    location              = "${azurerm_network_interface.nic.location}"
    resource_group_name   = "${resource.azurerm_resource_group.resourcegroup.name}"
    vm_size               = "${var.size}"
    tags = {
            Project = var.Project
            Environment = var.Environment
            "Business Owner" = var.Owner

        }
    
    
   
    network_interface_ids = ["${azurerm_network_interface.nic.id}"]

license_type = "Windows_Server"





storage_os_disk {
    name              = "${var.osdisk}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb = "128"
  }
  

  storage_data_disk {
  
managed_disk_type = "Premium_LRS"
name = "${var.datadisk01}"
create_option = "empty"
disk_size_gb = "40"
lun = "0"

  }


os_profile {
  computer_name = "var.vmname"
  admin_username = "localadmin"
  admin_password = "Welcome123123!!"
}

os_profile_windows_config {
  provision_vm_agent = "true"
  
}



  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }


}











# Uncomment this line to delete the OS disk automatically when deleting the Virtual Machine
#delete_os_disk_on_termination = true

# Uncomment this line to delete the data disks automatically when deleting the VM
#delete_data_disks_on_termination = true


