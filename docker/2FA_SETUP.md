# 2FA/OTP Setup Guide

This guide explains how to configure Two-Factor Authentication (2FA) using Google Authenticator for SSH access.

## Overview

The `2fa-auth` role configures PAM (Pluggable Authentication Modules) to require Google Authenticator OTP codes for users in the `otpusers` group when logging in via SSH.

## Prerequisites

- Users must be created first (via the `users` role)
- Users must have passwords set
- SSH must be accessible

## Configuration Steps

### 1. Enable 2FA in Ansible

Edit `group_vars/all.yaml`:

```yaml
# Enable 2FA
pam_otp_enabled: true

# List users who should have 2FA enabled
otp_users:
  - pratik
  - john
  - alice
  - bob
  - rushi
```

### 2. Run the Playbook

```bash
cd docker
ansible-playbook playbook.yaml --ask-vault-pass
```

This will:
- Install `libpam-google-authenticator`
- Create the `otpusers` group
- Add specified users to the `otpusers` group
- Configure PAM to require OTP for users in `otpusers` group
- Initialize google-authenticator for each user (if not already done)
- Configure SSH to use PAM authentication

### 3. User Setup (Manual Step Required)

**IMPORTANT**: After running the playbook, each user must complete their setup:

1. **SSH into the server** (using password authentication - this will be the last time without OTP):
   ```bash
   ssh user@server
   ```

2. **Run google-authenticator** to see the QR code:
   ```bash
   google-authenticator
   ```
   
   Answer the prompts:
   - **Do you want authentication tokens to be time-based?** → `y`
   - **Do you want me to update your "/home/user/.google_authenticator" file?** → `y`
   - **Do you want to disallow multiple uses of the same authentication token?** → `y`
   - **Do you want to allow up to 3 attempts?** → `y` (or your preference)
   - **Do you want to enable rate-limiting?** → `y`

3. **Scan the QR code** with your authenticator app:
   - Google Authenticator
   - Authy
   - Microsoft Authenticator
   - Any TOTP-compatible app

4. **Save the emergency scratch codes** - these can be used if you lose access to your authenticator app

5. **Test the setup**:
   - Log out and log back in
   - You should be prompted for:
     1. Password
     2. Verification code (from your authenticator app)

## Alternative: Automated Setup (Non-Interactive)

The playbook attempts to initialize google-authenticator non-interactively, but users still need to:

1. Retrieve their secret key:
   ```bash
   cat ~/.google_authenticator | head -1
   ```

2. Manually enter this secret into their authenticator app, OR

3. Generate a QR code using the secret:
   ```bash
   # Install qrencode if needed
   apt-get install qrencode
   
   # Generate QR code
   SECRET=$(head -1 ~/.google_authenticator)
   qrencode -t ANSI "otpauth://totp/user@hostname?secret=$SECRET&issuer=SSH"
   ```

## Troubleshooting

### User can't log in after enabling 2FA

1. **Check if user is in otpusers group**:
   ```bash
   groups username
   ```

2. **Check if .google_authenticator file exists**:
   ```bash
   ls -la ~/.google_authenticator
   ```

3. **Verify PAM configuration**:
   ```bash
   cat /etc/pam.d/sshd
   ```

4. **Check SSH configuration**:
   ```bash
   grep -E "UsePAM|ChallengeResponseAuthentication" /etc/ssh/sshd_config
   ```

### Temporarily disable 2FA for a user

Remove user from `otpusers` group:
```bash
sudo gpasswd -d username otpusers
```

Or disable 2FA entirely:
```yaml
pam_otp_enabled: false
```

### User lost their authenticator device

1. Use one of the emergency scratch codes saved during setup
2. Or, as root, remove the user's `.google_authenticator` file and have them re-run `google-authenticator`

## Security Notes

- The `nullok` option in PAM config allows users NOT in `otpusers` group to log in without OTP
- Only users in `otpusers` group are required to provide OTP
- Emergency scratch codes should be stored securely
- Consider enabling 2FA gradually, starting with a test user

## Testing

1. Enable 2FA for a test user first
2. Complete the setup process
3. Test login with password + OTP
4. Once confirmed working, enable for additional users

