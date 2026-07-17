# SSH Key Setup for Fresh Rebuild
# ============================================
# Purpose: Enable passwordless SSH login using RSA key auth
# Prerequisites: 
#   - Key generated on local workstation
#   - Public key added to remote authorized_keys
#   - VM IP: 172.16.13.1 (MAY BE STALE — verify current VM IP)
#
# NOTE: Also see "SSH KEY instruction.txt" in this directory for an alternate
# version with the actual embedded public key for ken@Akuma.
# Note: VM at 172.16.13.1 may no longer be active — adjust IP to current target.

# =============================================================================
# PART 1: Generate SSH Key on Akuma (your local machine)
# =============================================================================
# Run this on Akuma terminal:
ssh-keygen -t rsa -b 4096 -C ken@Akuma

# Key explanations:
#   -t rsa        = Use RSA algorithm (widely supported)
#   -b 4096      = Key size 4096 bits (more secure than default 2048)
#   -C ken@Akuma  = Comment label (helps identify key later)
# 
# When prompted:
#   > Enter file in which to save the key: (press Enter for default ~/.ssh/id_rsa)
#   > Enter passphrase: (press Enter for no passphrase - or type one if you want)
#   > Enter same passphrase again: (confirm)

# Display your PUBLIC key (copy this):
cat ~/.ssh/id_rsa.pub

# What this does:
#   - id_rsa.pub is the PUBLIC key (shareable, goes on remote)
#   - id_rsa is the PRIVATE key (keeps secret, stays on Akuma)
#   - Never share id_rsa, only id_rsa.pub

# =============================================================================
# PART 2: Set up on OpenClaw VM (172.16.13.1)
# =============================================================================
# Log in as admin/root first, then run:

# Step 2a: Create 'ken' user if it doesn't exist
# --------------------------------------------------------
sudo useradd -m -d /home/ken -s /bin/bash ken

# useradd flags:
#   -m        = Create home directory (/home/ken)
#   -d /home/ken = Set home directory path
#   -s /bin/bash = Use bash shell
#   ken        = Username

# Step 2b: Create .ssh directory
# --------------------------------------------------------
sudo mkdir -p /home/ken/.ssh

# mkdir flags:
#   -p = Create parent dirs if needed, no error if exists

# Step 2c: Add your PUBLIC key to authorized_keys
# --------------------------------------------------------
# Replace KEY_HERE with your public key (starts with ssh-rsa AAAAB3...):
sudo bash -c 'echo "KEY_HERE" >> /home/ken/.ssh/authorized_keys'

# What this does:
#   - >> appends the key to authorized_keys (doesn't overwrite existing keys)
#   - authorized_keys = file containing public keys allowed to log in

# Step 2d: Set correct permissions (CRITICAL!)
# --------------------------------------------------------
sudo chmod 700 /home/ken/.ssh
# chmod 700 = Only ken can read/execute .ssh directory
# SSH rejects keys if directory is too open (group/other readable)

sudo chmod 600 /home/ken/.ssh/authorized_keys
# chmod 600 = Only ken can read/write authorized_keys
# SSH rejects keys if file is writable by others

sudo chown -R ken:ken /home/ken/.ssh
# chown -R = Recursively set ownership
# ken:ken = user:group for /home/ken/.ssh

# =============================================================================
# PART 3: Test the Connection
# =============================================================================
# From Akuma, run:
ssh -i ~/.ssh/id_rsa ken@172.16.13.1

# ssh flags:
#   -i ~/.ssh/id_rsa = Use specific private key file
#   ken@172.16.13.1 = Connect as 'ken' to VM IP

# If it works, you'll get a shell prompt on the VM.

# =============================================================================
# Troubleshooting
# ==============================================================================
# 
# "Permission denied (publickey)":
#   - Check key is in authorized_keys (no typos)
#   - Check permissions (700 on .ssh, 600 on authorized_keys)
#   - Check private key exists: ls -la ~/.ssh/id_rsa
# 
# "Connection refused":
#   - SSH service may not be running on VM
#   - Check firewall: sudo ufw allow ssh
# 
# "Too many authentication failures":
#   - Add to ~/.ssh/config:
#     Host 172.16.13.1
#       IdentityFile ~/.ssh/id_rsa
#       PreferredAuthentications publickey