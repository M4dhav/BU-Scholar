# GitHub OAuth Setup for BU Scholar

This document explains how to configure GitHub OAuth authentication for the BU Scholar app to avoid API rate limits when accessing the repository from college IPs.

## Why GitHub OAuth?

When multiple users access GitHub's API from the same IP address (like a college network), GitHub applies stricter rate limits. By allowing users to authenticate with their GitHub accounts, we can use their personal API quotas instead of the shared IP-based limits.

## GitHub OAuth App Configuration

### Step 1: Create a GitHub OAuth App

1. **Go to GitHub Settings**
   - Navigate to [GitHub Developer Settings](https://github.com/settings/developers)
   - Click on "OAuth Apps"
   - Click "New OAuth App"

2. **Configure the OAuth App**
   ```
   Application name: BU Scholar
   Homepage URL: https://your-domain.com (or http://localhost:3000 for development)
   Application description: Access to BU Scholar previous year question papers
   Authorization callback URL: https://your-domain.com/auth/callback (or http://localhost:3000/auth/callback for development)
   ```

3. **Get Your Credentials**
   - After creating the app, you'll see your **Client ID**
   - Generate a **Client Secret**
   - **Important:** Keep these credentials secure!

### Step 2: Set Environment Variables

The app now uses environment variables for security. **Never hardcode credentials in the source code.**

#### For Development (Local)

**Run with dart-define**:
```bash
flutter run -d web-server --dart-define=GITHUB_CLIENT_ID=your_client_id --dart-define=GITHUB_CLIENT_SECRET=your_secret --dart-define=GITHUB_REDIRECT_URI=http://localhost:3000/auth/callback
```

**Or set shell environment variables**:
```bash
export GITHUB_CLIENT_ID=your_client_id_here
export GITHUB_CLIENT_SECRET=your_client_secret_here
export GITHUB_REDIRECT_URI=http://localhost:3000/auth/callback
flutter run -d web-server
```

#### For Production Deployment

**Web Deployment (Vercel)**
Set these environment variables in your Vercel dashboard:
```bash
GITHUB_CLIENT_ID=your_production_client_id
GITHUB_CLIENT_SECRET=your_production_client_secret
GITHUB_REDIRECT_URI=https://yourapp.vercel.app/auth/callback
```

**Web Deployment (Netlify)**
Set these in Netlify environment variables:
```bash
GITHUB_CLIENT_ID=your_production_client_id
GITHUB_CLIENT_SECRET=your_production_client_secret
GITHUB_REDIRECT_URI=https://yourapp.netlify.app/auth/callback
```

**Flutter Build**:
```bash
flutter build web --dart-define=GITHUB_CLIENT_ID=$GITHUB_CLIENT_ID --dart-define=GITHUB_CLIENT_SECRET=$GITHUB_CLIENT_SECRET --dart-define=GITHUB_REDIRECT_URI=$GITHUB_REDIRECT_URI
```

### Step 3: Development vs Production Configuration

You'll need **separate GitHub OAuth Apps** for development and production:

1. **Development App**
   - Callback: `http://localhost:3000/auth/callback`
   - Use in local development

2. **Production App**
   - Callback: `https://yourdomain.com/auth/callback`
   - Use in deployed version

## Security Best Practices

- ✅ **Use environment variables**: Credentials are now loaded from environment variables
- ✅ **Separate dev/prod apps**: Different OAuth apps for different environments
- ✅ **Rotate credentials**: Change secrets periodically
- ✅ **Monitor usage**: Check OAuth app analytics in GitHub
- ⚠️ **Client secret exposure**: In web apps, consider using PKCE flow for extra security

## How It Works

1. **Rate Limit Detection**: When GitHub API returns a 403 rate limit error, the app shows a login button
2. **OAuth Flow**: User clicks login → redirected to GitHub → authorizes the app → redirected back with access token
3. **Authenticated Requests**: All subsequent GitHub API calls use the user's access token
4. **Higher Limits**: Authenticated users get 5,000 requests per hour instead of 60 requests per hour per IP

## Testing

1. **Set environment variables** as shown above
2. **Run the app**: `flutter run -d web-server --dart-define=GITHUB_CLIENT_ID=your_id --dart-define=GITHUB_CLIENT_SECRET=your_secret`
3. **Open**: `http://localhost:3000`
4. **Test error handling**: App should show error if credentials are missing
5. **Test login flow**: Click GitHub login button and complete OAuth
6. **Verify authentication**: User avatar should appear in top-right

## Troubleshooting

- **"GitHub OAuth credentials not configured"**: Set GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET environment variables
- **"Invalid redirect URI"**: Ensure the callback URL in GitHub OAuth app matches your configuration
- **"Client ID not found"**: Verify environment variables are correctly set and passed to Flutter
- **OAuth popup blocked**: Disable popup blockers for localhost during testing
- **Network issues**: OAuth requires internet access

## Example Environment Setup

**Development**:
```bash
GITHUB_CLIENT_ID=Iv1.a1b2c3d4e5f6g7h8
GITHUB_CLIENT_SECRET=abcdef1234567890abcdef1234567890abcdef12
GITHUB_REDIRECT_URI=http://localhost:3000/auth/callback
```

**Production**:
```bash
GITHUB_CLIENT_ID=Iv1.x9y8z7w6v5u4t3s2
GITHUB_CLIENT_SECRET=zyxwvu0987654321zyxwvu0987654321zyxwvu09
GITHUB_REDIRECT_URI=https://bu-scholar.vercel.app/auth/callback
```

## Rate Limits Reference

| Authentication | Requests per hour |
|----------------|------------------|
| No auth (per IP) | 60 |
| GitHub OAuth | 5,000 |

This is why OAuth authentication is crucial for college networks where many students might be accessing the app from the same IP address.

## Production Checklist

- [ ] Separate GitHub OAuth Apps created (dev + prod)
- [ ] Environment variables configured in hosting platform
- [ ] Production redirect URI matches deployed domain
- [ ] Client credentials never committed to version control
- [ ] SSL/HTTPS enabled for production domain
- [ ] Error handling tested for missing credentials