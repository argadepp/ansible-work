# 2FA Authentication Role

An Ansible role to configure Two-Factor Authentication (2FA) using Google Authenticator for SSH access.

## Description

This role configures PAM (Pluggable Authentication Modules) to require Google Authenticator OTP codes for users in a specific group when logging in via SSH. It provides a secure way to add an extra layer of authentication to SSH logins.

## Requirements

- Ansible 2.9 or higher
- Target hosts must be Linux-based (Ubuntu, Debian, RHEL/CentOS)
- SSH server must be installed and configured
- Users must be created before enabling 2FA

## Role Variables

### Required Variables

- `pam_otp_enabled`: Boolean to enable/disable 2FA (default: `false`)
  ```yaml
  pam_otp_enabled: true
  ```

- `otp_users`: List of users who should have 2FA enabled
  ```yaml
  otp_users:
    - pratik
    - john
  ```

### Default Variables

- `pam_otp_enabled`: `false` (safe default)
- `pam_otp_package`: `libpam-google-authenticator`
- `pam_otp_users_group`: `otpusers` (group name for users requiring OTP)

## Dependencies

None

## Example Playbook

```yaml
---
- name: Configure 2FA for SSH
  hosts: all
  become: yes
  
  vars:
    pam_otp_enabled: true
    otp_users:
      - pratik
      - john
  
  roles:
    - 2fa-auth
```

### Complete Example with Users Role

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
    - group_vars/my_vault.yaml
  
  roles:
    - users
    - 2fa-auth
```

## How It Works

1. **Installation**: Installs `libpam-google-authenticator` package
2. **Group Creation**: Creates the `otpusers` group
3. **User Assignment**: Adds specified users to the `otpusers` group
4. **Initialization**: Initializes google-authenticator for users (non-interactive)
5. **PAM Configuration**: Configures `/etc/pam.d/sshd` to require OTP for users in `otpusers` group
6. **SSH Configuration**: Enables PAM and ChallengeResponseAuthentication in SSH config

## User Setup (Manual Step Required)

After running the playbook, each user must complete their setup:

1. SSH into the server (last time without OTP)
2. Run `google-authenticator` to see the QR code
3. Scan QR code with authenticator app (Google Authenticator, Authy, etc.)
4. Save emergency scratch codes
5. Test login with password + OTP

See `2FA_SETUP.md` for detailed instructions.

## Security Notes

- The `nullok` option allows users NOT in `otpusers` group to log in without OTP
- Only users in `otpusers` group are required to provide OTP
- Emergency scratch codes should be stored securely
- Enable 2FA gradually, starting with a test user
- Always test with one user before enabling for all users

## Troubleshooting

### User can't log in after enabling 2FA

1. Check if user is in `otpusers` group: `groups username`
2. Check if `.google_authenticator` file exists: `ls -la ~/.google_authenticator`
3. Verify PAM configuration: `cat /etc/pam.d/sshd`
4. Check SSH configuration: `grep -E "UsePAM|ChallengeResponseAuthentication" /etc/ssh/sshd_config`

### Temporarily disable 2FA for a user

```bash
sudo gpasswd -d username otpusers
```

Or disable 2FA entirely:
```yaml
pam_otp_enabled: false
```

## License

MIT

## Author Information

Pratik Argade

