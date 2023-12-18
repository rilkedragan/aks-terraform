# Introduction 
Terrafom code to deploy AKS cluster

Deploys AKS cluster with Azure AD integration and RBAC support

Creates ACR and assign permissions fro AKS cluster

Enables Application Gateway Ingress controller

!!!IMPORTANT  After deployment is finished - role assignment for application gateway ingress controller managed identity needs to be added to grant Network contributor permissions to the app gateway subnet
