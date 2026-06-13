**OIDC** stands for **OpenID Connect**. It's an authentication and identity protocol built on top of OAuth 2.0.

## In Simple Terms

OIDC lets applications verify who you are without storing passwords. Instead of hardcoding credentials, you use a trusted third party to confirm identity.

## In Your Cloudmart Context

Your GitHub Actions workflows use OIDC to access AWS without storing AWS access keys. Here's how it works:

1. **GitHub acts as the identity provider** - It says "I verified this code is running in our repository"
2. **GitHub generates a token** - A temporary, signed credential with limited scope
3. **AWS trusts GitHub** - You've configured an IAM role to accept GitHub's tokens
4. **Workflow authenticates** - The workflow exchanges GitHub's token for AWS credentials automatically

```yaml
permissions:
  id-token: write    # Allows GitHub to create OIDC tokens
```

## Why It's Better Than Access Keys

| Aspect | API Keys | OIDC |
|--------|----------|------|
| **Expiration** | Never expires | Expires after ~1 hour |
| **Scope** | Can do everything | Limited to specific actions |
| **Storage** | Must be kept secret | No secrets stored |
| **Rotation** | Manual & risky | Automatic per run |
| **Audit Trail** | Generic "access key" | Tied to specific workflow/repository |

## Your AWS Configuration

In your workflows, you see:
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
    aws-region: ${{ env.AWS_REGION }}
```

This exchanges the GitHub OIDC token for temporary AWS credentials on-the-fly—no permanent keys stored anywhere.