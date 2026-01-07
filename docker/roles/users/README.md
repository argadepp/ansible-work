# Users Role

An Ansible role to create and manage system users with password authentication.

## Description

This role creates users on remote hosts and sets their passwords using Ansible Vault for secure password management.

## Requirements

- Ansible 2.9 or higher
- Target hosts must support user management
- Ansible Vault encrypted file containing user passwords

## Role Variables

### Required Variables

- `users`: List of usernames to create
  ```yaml
  users:
    - pratik
    - john
    - alice
  ```

- `user_passwords`: Dictionary of username:password pairs (should be in vault-encrypted file)
  ```yaml
  user_passwords:
    pratik: "encrypted_password"
    john: "encrypted_password"
  ```

### Default Variables

- `users`: Empty list by default
- Users are added to `sudo` group by default
- Shell is set to `/bin/bash` by default

## Dependencies

None

## Example Playbook

```yaml
---
- name: Create users on remote hosts
  hosts: all
  become: yes
  
  vars_files:
    - group_vars/my_vault.yaml  # Contains encrypted user_passwords
  
  roles:
    - users
```

### With Variables

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
    - users
```

## Security Notes

- Passwords should always be stored in Ansible Vault encrypted files
- The password setting task uses `no_log: true` to prevent password exposure in logs
- Use strong passwords and rotate them regularly

## License

MIT

## Author Information

Pratik Argade

