# GitHub Secrets Configuration Guide

This document explains how to securely configure secrets for iOS deployment using GitHub Actions.

## 🔒 Security Best Practices

- **Never commit secrets to the repository**
- All sensitive data is stored as GitHub Secrets (encrypted)
- Secrets are only accessible during workflow execution
- Secrets are masked in logs automatically

## 📋 Required Secrets for iOS Deployment

### For Basic Build (No Code Signing)
No secrets required - the workflow will build without signing.

### For App Store / TestFlight Deployment

You need to configure the following secrets in your GitHub repository:

#### 1. Code Signing Certificate
- **Secret Name**: `IOS_CERTIFICATE_BASE64`
- **Description**: Your iOS distribution certificate (.p12 file) encoded in base64
- **How to create**:
  ```bash
  # Export your certificate from Keychain Access
  # Then encode it:
  base64 -i YourCertificate.p12 | pbcopy
  # Paste the result as the secret value
  ```

#### 2. Certificate Password
- **Secret Name**: `IOS_CERTIFICATE_PASSWORD`
- **Description**: Password for the .p12 certificate file
- **Type**: Plain text (GitHub encrypts it)

#### 3. Provisioning Profile
- **Secret Name**: `IOS_PROVISIONING_PROFILE_BASE64`
- **Description**: Your App Store provisioning profile encoded in base64
- **How to create**:
  ```bash
  # Download from Apple Developer Portal
  # Then encode it:
  base64 -i YourProfile.mobileprovision | pbcopy
  # Paste the result as the secret value
  ```

#### 4. Keychain Password
- **Secret Name**: `KEYCHAIN_PASSWORD`
- **Description**: Temporary password for the build keychain (can be any secure random string)
- **Type**: Plain text (GitHub encrypts it)
- **Example**: Generate with: `openssl rand -base64 32`

#### 5. Apple Team ID
- **Secret Name**: `IOS_TEAM_ID`
- **Description**: Your Apple Developer Team ID (found in Apple Developer Portal)
- **Type**: Plain text (e.g., `ABC123DEF4`)

### For TestFlight Deployment (Optional)

#### 6. App Store Connect API Key ID
- **Secret Name**: `APP_STORE_CONNECT_API_KEY_ID`
- **Description**: The Key ID from your App Store Connect API key
- **Type**: Plain text (e.g., `ABC123DEF4`)

#### 7. App Store Connect Issuer ID
- **Secret Name**: `APP_STORE_CONNECT_ISSUER_ID`
- **Description**: Your App Store Connect Issuer ID
- **Type**: Plain text (UUID format)

#### 8. App Store Connect API Key
- **Secret Name**: `APP_STORE_CONNECT_API_KEY_BASE64`
- **Description**: Your App Store Connect API key (.p8 file) encoded in base64
- **How to create**:
  ```bash
  # Download from App Store Connect
  # Then encode it:
  base64 -i AuthKey_ABC123DEF4.p8 | pbcopy
  # Paste the result as the secret value
  ```

## 🔧 How to Add Secrets to GitHub

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter the secret name (exactly as listed above)
5. Enter the secret value
6. Click **Add secret**

## ✅ Verification

After adding secrets, the workflow will:
- Automatically detect if secrets are configured
- Use code signing if certificates are provided
- Skip code signing if secrets are not available (builds without signing)

## 🚨 Important Notes

1. **AdMob Configuration**: The `lib/config/admob_config.dart` file is already in `.gitignore` and should not be committed. Create it locally from the template.

2. **Android Keystore**: The `android/key.properties` file is already in `.gitignore` and should not be committed.

3. **Secret Rotation**: If you need to rotate secrets:
   - Update the secret value in GitHub
   - The next workflow run will use the new value automatically

4. **Secret Access**: Secrets are only available to:
   - Repository administrators
   - During workflow execution (encrypted)
   - Never visible in logs or code

## 📚 Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Apple Code Signing Guide](https://developer.apple.com/documentation/security/code_signing_services)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

## 🔍 Current Secret Status

To check which secrets are configured, look at the workflow summary after a build:
- ✅ Code signing configured - All required secrets are present
- ⚠️ Code signing not configured - Build will complete without signing

