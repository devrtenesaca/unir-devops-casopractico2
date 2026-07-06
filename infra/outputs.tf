output "vm_public_ip" {
    description = "Public IP address of the virtual machine"
    value       = azurerm_public_ip.pip_caso2.ip_address
}