# Installation Guide

This guide explains how to install and use this Ansible collection.

## Prerequisites

- Ansible 2.9 or higher
- Python 3.6 or higher
- Git (if installing from source)

## Installation Methods

### Method 1: Install as Collection (Recommended)

Create a `requirements.yml` file:

```yaml
---
collections:
  - name: pratikargade.ansible_work
    source: https://github.com/pratikargade/ansible-work.git
    type: git
    version: main
```

Install:

```bash
ansible-galaxy collection install -r requirements.yml
```

Use in playbooks:

```yaml
---
- hosts: all
  become: yes
  roles:
    - pratikargade.ansible_work.users
    - pratikargade.ansible_work.2fa_auth
```

### Method 2: Install from Git Directly

```bash
ansible-galaxy collection install git+https://github.com/pratikargade/ansible-work.git
```

### Method 3: Install Individual Roles

If you prefer to install roles individually:

```bash
# Clone the repository
git clone https://github.com/pratikargade/ansible-work.git
cd ansible-work

# Install roles
ansible-galaxy install -r requirements.yml
```

Then use roles directly:

```yaml
---
- hosts: all
  become: yes
  roles:
    - users
    - 2fa-auth
```

### Method 4: Use from Local Path

If you've cloned the repository locally:

```yaml
---
- hosts: all
  become: yes
  roles:
    - role: docker/roles/users
    - role: docker/roles/2fa-auth
```

Or add to `ansible.cfg`:

```ini
[defaults]
roles_path = ./docker/roles:./playbooks/roles
```

## Verifying Installation

Check installed collections:

```bash
ansible-galaxy collection list
```

Check installed roles:

```bash
ansible-galaxy role list
```

## Using in Playbooks

### Example 1: Basic User Management

```yaml
---
- name: Create users
  hosts: all
  become: yes
  
  vars:
    users:
      - pratik
      - john
  
  vars_files:
    - group_vars/my_vault.yaml
  
  roles:
    - pratikargade.ansible_work.users
```

### Example 2: User Management with 2FA

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

## Troubleshooting

### Collection not found

If you get "collection not found" error:

1. Verify installation:
   ```bash
   ansible-galaxy collection list | grep pratikargade
   ```

2. Reinstall:
   ```bash
   ansible-galaxy collection install -r requirements.yml --force
   ```

3. Check Ansible version:
   ```bash
   ansible --version
   ```
   Must be 2.9 or higher.

### Role not found

If using individual roles:

1. Check role path in `ansible.cfg`
2. Verify roles are in the correct directory
3. Use full path: `- role: /path/to/role`

## Updating

To update the collection:

```bash
ansible-galaxy collection install -r requirements.yml --force
```

## Uninstalling

```bash
ansible-galaxy collection remove pratikargade.ansible_work
```

