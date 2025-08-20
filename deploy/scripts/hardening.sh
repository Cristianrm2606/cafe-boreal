#!/bin/bash

echo "=== Aplicando Hardening Básico ==="

# 1. Firewall UFW más restrictivo
echo "1. Configurando firewall..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 443/tcp comment 'HTTPS Nginx'
sudo ufw allow 8081/tcp comment 'Apache Legacy'
sudo ufw --force enable

# 2. Deshabilitar servicios innecesarios
echo "2. Verificando servicios..."
sudo systemctl disable cups 2>/dev/null || echo "CUPS no instalado"
sudo systemctl disable bluetooth 2>/dev/null || echo "Bluetooth no instalado"

# 3. Configuración SSH más segura
echo "3. Configurando SSH..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl reload sshd

# 4. Limits de archivo para PostgreSQL
echo "4. Configurando limits..."
echo "postgres soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "postgres hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# 5. Configurar fail2ban básico
echo "5. Instalando fail2ban..."
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "✅ Hardening básico completado"
echo "📊 Estado del firewall:"
sudo ufw status numbered
