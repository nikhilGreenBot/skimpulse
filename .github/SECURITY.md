# Security Configuration

## ✅ Current Security Status

All secrets are properly encrypted and stored in GitHub Secrets. No sensitive data is committed to the repository.

### Files Protected by .gitignore

- ✅ `lib/config/admob_config.dart` - AdMob configuration (contains real AdMob IDs)
- ✅ `android/key.properties` - Android keystore passwords
- ✅ `android/keystore/` - Android keystore files
- ✅ `*.jks`, `*.keystore` - Keystore files

### GitHub Secrets Used

All secrets are encrypted by GitHub and only accessible during workflow execution:

1. **iOS Code Signing** (optional):
   - `IOS_CERTIFICATE_BASE64`
   - `IOS_CERTIFICATE_PASSWORD`
   - `IOS_PROVISIONING_PROFILE_BASE64`
   - `KEYCHAIN_PASSWORD`
   - `IOS_TEAM_ID`

2. **App Store Connect** (optional):
   - `APP_STORE_CONNECT_API_KEY_ID`
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_API_KEY_BASE64`

## 🔒 Security Best Practices Implemented

1. **No Hardcoded Secrets**: All sensitive data is stored as GitHub Secrets
2. **Secrets Masked in Logs**: GitHub automatically masks secret values in workflow logs
3. **Conditional Execution**: Workflow steps only run if required secrets are present
4. **Environment Variables**: Secrets are passed as environment variables, not directly in commands
5. **Cleanup**: Temporary files and keychains are cleaned up after use
6. **Artifact Retention**: Build artifacts are retained for only 7 days

## 📝 How Secrets Work

1. Secrets are stored encrypted in GitHub repository settings
2. Secrets are only accessible during workflow execution
3. Secrets are automatically masked in logs (you'll see `***` instead of the actual value)
4. Secrets cannot be accessed by repository code or other workflows
5. Only repository administrators can view/manage secrets

## 🚨 If Secrets Are Compromised

If you suspect secrets have been compromised:

1. **Immediately rotate all secrets**:
   - Generate new certificates/profiles
   - Update all secret values in GitHub
   - Revoke old API keys

2. **Check workflow logs**:
   - Review recent workflow runs
   - Look for unauthorized access

3. **Review access**:
   - Check who has access to the repository
   - Review GitHub Actions permissions

## 📚 Documentation

See `SECRETS.md` for detailed instructions on setting up secrets.

