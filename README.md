# Exercice Cloud et Infrastructure

## Infrastructure :

### Création sur aws :

1. **Un VPC**
   - CIDR : 192.168.0.0/16
   - name : myVPC

2. **Un subnet public**
   - CIDR : 192.168.0.0/20
   - Zone de disponibilité : a
   - name : myPublicSubnet
  
3. **Un subnet privé**
   - CIDR : 192.168.16.0/20
   - Zone de disponibilité : b
   - name : myPrivateSubnet

4. **Une instance EC2 public**
   - port ouvert : 22
   - name : myPublicInstance

5. **Une instance EC2 privé**
   - port ouvert : 80 et 22
   - name : myPrivateInstance_1
   - Connecté à : LoadBalancer[0] et NAT

6. **Une instance EC2 privé**
   - port ouvert : 22
   - name : AnsibleControlPlane
   - Connecté à : NAT
  
---

## Configuration myPrivateInstance_1            

### Configuration de l'instance grâce à **Ansible** :

1. Installation de NGINX
2. Envoi du site sur le dossier /var/www/html


