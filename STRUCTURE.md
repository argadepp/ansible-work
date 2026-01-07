# Repository Structure

This document explains the organization of this Ansible repository for Galaxy compatibility.

## Overview

This repository is organized to work both as:
1. **Ansible Collection** - Can be installed via `ansible-galaxy collection install`
2. **Individual Roles** - Can be installed as separate roles
3. **Direct Usage** - Can be used directly from the repository

## Directory Structure

```
ansible-work/
├── galaxy.yml              # Collection metadata for Ansible Galaxy
├── META.yml                # Alternative collection metadata
├── requirements.yml        # Dependencies and installation instructions
├── README.md               # Main documentation
├── INSTALL.md              # Installation guide
├── STRUCTURE.md            # This file
├── example-playbook.yml     # Example playbook
├── .gitignore              # Git ignore rules
│
├── docker/                 # Docker-related roles and playbooks
│   ├── roles/
│   │   ├── users/          # User management role
│   │   │   ├── meta/
│   │   │   │   └── main.yml    # Role metadata
│   │   │   ├── tasks/
│   │   │   │   └── main.yaml   # Role tasks
│   │   │   ├── vars/
│   │   │   │   ├── main.yaml
│   │   │   │   └── secrets.yaml
│   │   │   ├── handlers/
│   │   │   │   └── main.yaml
│   │   │   └── README.md       # Role documentation
│   │   │
│   │   └── 2fa-auth/       # 2FA authentication role
│   │       ├── meta/
│   │       │   └── main.yml
│   │       ├── tasks/
│   │       │   ├── main.yaml
│   │       │   ├── install.yaml
│   │       │   ├── users.yaml
│   │       │   ├── setup-otp.yaml
│   │       │   ├── pam.yaml
│   │       │   └── ssh.yaml
│   │       ├── templates/
│   │       │   └── sshd_pam.j2
│   │       ├── defaults/
│   │       │   └── main.yml
│   │       ├── handlers/
│   │       │   └── main.yaml
│   │       └── README.md
│   │
│   ├── playbook.yaml       # Example playbook
│   ├── 2FA_SETUP.md        # 2FA setup guide
│   ├── ansible.cfg         # Ansible configuration
│   ├── docker-compose.yaml
│   └── Dockerfile
│
├── playbooks/              # Additional playbooks and roles
│   ├── roles/
│   │   ├── microk8s-cluster/
│   │   │   ├── meta/
│   │   │   │   └── main.yml
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   ├── defaults/
│   │   │   │   └── main.yml
│   │   │   ├── handlers/
│   │   │   │   └── main.yml
│   │   │   ├── vars/
│   │   │   │   └── main.yml
│   │   │   └── README.md
│   │   │
│   │   └── setup-apache/
│   │       ├── meta/
│   │       │   └── main.yml
│   │       ├── tasks/
│   │       │   └── main.yml
│   │       ├── defaults/
│   │       │   └── main.yml
│   │       ├── handlers/
│   │       │   └── main.yml
│   │       ├── vars/
│   │       │   └── main.yml
│   │       └── README.md
│   │
│   └── *.yml               # Example playbooks
│
└── inventory/              # Inventory files
    └── *.yaml
```

## Key Files Explained

### Collection Files

- **galaxy.yml**: Main collection metadata file for Ansible Galaxy
- **META.yml**: Alternative metadata format
- **requirements.yml**: Dependencies and installation instructions

### Role Files

Each role should have:
- **meta/main.yml**: Role metadata (author, description, tags, etc.)
- **tasks/main.yaml**: Main task file
- **defaults/main.yml**: Default variables
- **vars/main.yml**: Role variables (if needed)
- **handlers/main.yaml**: Handlers (if needed)
- **templates/**: Jinja2 templates (if needed)
- **README.md**: Role documentation

## Usage Patterns

### Pattern 1: As Collection

```yaml
# requirements.yml
collections:
  - name: pratikargade.ansible_work
    source: https://github.com/pratikargade/ansible-work.git
    type: git
    version: main

# Install
ansible-galaxy collection install -r requirements.yml

# Use in playbook
roles:
  - pratikargade.ansible_work.users
  - pratikargade.ansible_work.2fa_auth
```

### Pattern 2: Individual Roles

```yaml
# requirements.yml
roles:
  - name: users
    src: https://github.com/pratikargade/ansible-work.git
    scm: git
    path: docker/roles/users
  - name: 2fa-auth
    src: https://github.com/pratikargade/ansible-work.git
    scm: git
    path: docker/roles/2fa-auth

# Install
ansible-galaxy install -r requirements.yml

# Use in playbook
roles:
  - users
  - 2fa-auth
```

### Pattern 3: Direct Usage

```yaml
# Clone repository
git clone https://github.com/pratikargade/ansible-work.git

# Use in playbook
roles:
  - role: ansible-work/docker/roles/users
  - role: ansible-work/docker/roles/2fa-auth
```

## Best Practices

1. **Always include meta/main.yml** for each role
2. **Document roles** with README.md
3. **Use defaults/main.yml** for configurable variables
4. **Keep secrets in vault** - never commit unencrypted secrets
5. **Version your roles** in meta/main.yml
6. **Tag roles appropriately** for Galaxy discoverability

## Publishing to Ansible Galaxy

To publish this collection to Ansible Galaxy:

1. **Create Galaxy account**: https://galaxy.ansible.com/
2. **Get API token**: From your Galaxy profile
3. **Build collection**:
   ```bash
   ansible-galaxy collection build
   ```
4. **Publish**:
   ```bash
   ansible-galaxy collection publish pratikargade-ansible_work-1.0.0.tar.gz --api-key YOUR_API_KEY
   ```

Or use GitHub integration for automatic publishing.

## Maintenance

- Update version in `galaxy.yml` for new releases
- Update CHANGELOG.md (if maintained)
- Tag releases in Git
- Keep documentation up to date

