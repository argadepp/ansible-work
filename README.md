# Ansible Work Collection

A collection of Ansible roles and playbooks for user management, 2FA authentication, Kubernetes, and infrastructure automation.

## Installation

### From Ansible Galaxy (Recommended)

```bash
# Install as a collection
ansible-galaxy collection install pratikargade.ansible_work

# Or install from Git
ansible-galaxy collection install git+https://github.com/pratikargade/ansible-work.git
```

### From Source

```bash
# Clone the repository
git clone https://github.com/pratikargade/ansible-work.git
cd ansible-work

# Install using requirements.yml
ansible-galaxy install -r requirements.yml
```

### Using requirements.yml

Create a `requirements.yml` file in your project:

```yaml
---
collections:
  - name: argadepp.ansible_work
    source: https://github.com/argadepp/ansible-work.git
    type: git
    version: main
```

Then install:

```bash
ansible-galaxy collection install -r requirements.yml
```

## Available Roles

### 1. Users Role

Create and manage system users with password authentication.

**Location**: `docker/roles/users/`

**Usage**:
```yaml
- hosts: all
  become: yes
  roles:
    - users
```

**Documentation**: See [docker/roles/users/README.md](docker/roles/users/README.md)

### 2. 2FA Authentication Role

Configure Two-Factor Authentication using Google Authenticator for SSH access.

**Location**: `docker/roles/2fa-auth/`

**Usage**:
```yaml
- hosts: all
  become: yes
  vars:
    pam_otp_enabled: true
    otp_users:
      - pratik
  roles:
    - 2fa-auth
```

**Documentation**: See [docker/roles/2fa-auth/README.md](docker/roles/2fa-auth/README.md) and [docker/2FA_SETUP.md](docker/2FA_SETUP.md)

### 3. MicroK8s Cluster Role

Install and configure MicroK8s Kubernetes cluster.

**Location**: `playbooks/roles/microk8s-cluster/`

**Usage**:
```yaml
- hosts: all
  become: yes
  roles:
    - microk8s-cluster
```

**Documentation**: See [playbooks/roles/microk8s-cluster/README.md](playbooks/roles/microk8s-cluster/README.md)

### 4. Setup Apache Role

Install and configure Apache web server.

**Location**: `playbooks/roles/setup-apache/`

**Usage**:
```yaml
- hosts: all
  become: yes
  roles:
    - setup-apache
```

**Documentation**: See [playbooks/roles/setup-apache/README.md](playbooks/roles/setup-apache/README.md)

## Example Playbooks

### Complete User Management with 2FA

```yaml
---
- name: Setup users and 2FA
  hosts: all
  become: yes
  
  vars:
    users:
      - pratik
      - john
    pam_otp_enabled: true
    otp_users:
      - pratik
      - john
  
  vars_files:
    - group_vars/my_vault.yaml  # Contains encrypted user_passwords
  
  roles:
    - users
    - 2fa-auth
```

### Using from Installed Collection

```yaml
---
- name: Setup users and 2FA
  hosts: all
  become: yes
  
  vars:
    users:
      - pratik
    pam_otp_enabled: true
    otp_users:
      - pratik
  
  vars_files:
    - group_vars/my_vault.yaml
  
  roles:
    - pratikargade.ansible_work.users
    - pratikargade.ansible_work.2fa_auth
```

## Directory Structure

```
ansible-work/
├── galaxy.yml                 # Collection metadata
├── requirements.yml           # Dependencies
├── README.md                  # This file
├── .gitignore                # Git ignore rules
├── docker/                    # Docker-related roles and playbooks
│   ├── roles/
│   │   ├── users/            # User management role
│   │   └── 2fa-auth/         # 2FA authentication role
│   ├── playbook.yaml         # Example playbook
│   └── 2FA_SETUP.md          # 2FA setup guide
├── playbooks/                 # Additional playbooks
│   ├── roles/
│   │   ├── microk8s-cluster/ # MicroK8s role
│   │   └── setup-apache/     # Apache role
│   └── *.yml                 # Example playbooks
└── inventory/                 # Inventory files
```

## Requirements

- Ansible 2.9 or higher
- Python 3.6 or higher
- Target hosts must be Linux-based (Ubuntu, Debian, RHEL/CentOS)

## Security Best Practices

1. **Always use Ansible Vault** for sensitive data (passwords, tokens, etc.)
2. **Test 2FA** with one user before enabling for all users
3. **Store emergency codes** securely when setting up 2FA
4. **Use strong passwords** and rotate them regularly
5. **Review playbooks** before running in production

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT

## Author

**Pratik Argade**

- GitHub: [@pratikargade](https://github.com/pratikargade)

## Support

For issues and questions:
- Open an issue on GitHub
- Check the role-specific README files
- Review example playbooks in the repository

## Changelog

### Version 1.0.0
- Initial release
- Users role for user management
- 2FA authentication role with Google Authenticator
- MicroK8s cluster role
- Apache setup role
