
# Secrets Management Security Guidelines

## Purpose
This rule helps prevent exposing sensitive information such as API keys, credentials, and other secrets in your codebase, preventing unauthorized access and potential data breaches.

## Guidelines

### Environment Variables

#### Use Environment Variables for Secrets
- Never hardcode secrets directly in your application code
- Store all sensitive information in environment variables
- Use appropriate environment variable naming conventions

```javascript
// AVOID: Hardcoded secrets in application code
const apiKey = "sk_live_abcdef123456789";
const dbPassword = "super_secret_password";

// RECOMMENDED: Using environment variables
const apiKey = process.env.API_KEY;
const dbPassword = process.env.DB_PASSWORD;
```

#### Different Environment Variables per Environment
- Use different secrets for development, testing, and production
- Never use production secrets in development environments
- Consider using environment-specific .env files

```javascript
// RECOMMENDED: Environment-specific configuration
// In an initialization file:
const config = {
  apiKey: process.env.NODE_ENV === 'production' 
    ? process.env.PROD_API_KEY 
    : process.env.DEV_API_KEY,
  dbConfig: {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  }
};
```

### .env Files

#### Secure .env File Handling
- Always add .env files to .gitignore
- Use .env.example files with dummy values to document required variables
- Never commit .env files with real secrets to version control

```bash
# RECOMMENDED: Example .gitignore entry
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
```

```bash
# RECOMMENDED: Example .env.example file
# API Keys
API_KEY=your_api_key_here
STRIPE_SECRET_KEY=your_stripe_key_here

# Database
DB_HOST=localhost
DB_USER=username
DB_PASSWORD=password
DB_NAME=database_name
```

#### Loading Environment Variables
- Use established libraries for loading environment variables
- Validate that required environment variables are present at startup
- Consider using typed environment variables

```javascript
// RECOMMENDED: Using dotenv with validation
require('dotenv').config();

const requiredEnvVars = [
  'API_KEY',
  'DB_PASSWORD',
  'JWT_SECRET'
];

const missingEnvVars = requiredEnvVars.filter(
  varName => !process.env[varName]
);

if (missingEnvVars.length > 0) {
  throw new Error(
    `Missing required environment variables: ${missingEnvVars.join(', ')}`
  );
}
```

### Secrets in CI/CD

#### Secure CI/CD Secret Management
- Use the secret management features of your CI/CD platform
- Never print secrets in build logs
- Rotate secrets used in CI/CD regularly

```yaml
# RECOMMENDED: GitHub Actions secrets example
name: Deploy Application

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
```

### Secret Storage Solutions

#### Use Dedicated Secret Management Tools
- Consider using dedicated secret management services:
  - AWS Secrets Manager
  - HashiCorp Vault
  - Azure Key Vault
  - Google Secret Manager
- Implement proper access controls for secret access
- Enable audit logging for secret access

```javascript
// RECOMMENDED: Using AWS Secrets Manager
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager();

async function getSecret(secretName) {
  try {
    const data = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
    if ('SecretString' in data) {
      return JSON.parse(data.SecretString);
    }
  } catch (err) {
    console.error(`Error retrieving secret ${secretName}:`, err);
    throw err;
  }
}

// Usage
async function initDatabase() {
  try {
    const dbCredentials = await getSecret('prod/db/credentials');
    // Connect to database using the secret credentials
    return connectToDatabase(dbCredentials);
  } catch (err) {
    console.error('Failed to initialize database:', err);
    process.exit(1);
  }
}
```

### Key Rotation

#### Implement Regular Secret Rotation
- Rotate secrets regularly according to your security policy
- Implement zero-downtime secret rotation where possible
- Have processes to quickly rotate compromised secrets

```javascript
// RECOMMENDED: Implementing secret rotation in an application
class SecretManager {
  constructor(secretProvider) {
    this.secretProvider = secretProvider;
    this.secrets = {};
    this.lastRefresh = 0;
    this.refreshIntervalMs = 24 * 60 * 60 * 1000; // 24 hours
  }

  async getSecret(secretName) {
    // Check if we need to refresh secrets
    const now = Date.now();
    if (now - this.lastRefresh > this.refreshIntervalMs) {
      await this.refreshSecrets();
    }
    
    return this.secrets[secretName];
  }

  async refreshSecrets() {
    try {
      // Get all required secrets from the provider
      const newSecrets = await this.secretProvider.getAllSecrets();
      
      // Update our local cache
      this.secrets = newSecrets;
      this.lastRefresh = Date.now();
      
      console.log('Secrets refreshed successfully');
    } catch (err) {
      console.error('Failed to refresh secrets:', err);
      // Don't update lastRefresh, so we'll try again soon
    }
  }
}
```

### Handling Secrets in Frontend Applications

#### Avoid Exposing Secrets in Frontend Code
- Never include API keys or secrets in client-side code
- Use server-side proxies or backend services to make authenticated API requests
- Use short-lived tokens for frontend authentication

```javascript
// AVOID: Exposing API keys in frontend code
// In a React component:
function WeatherWidget() {
  const [weather, setWeather] = useState(null);
  
  useEffect(() => {
    fetch(`https://api.weather.com/forecast?key=abcd1234`) // API key exposed!
      .then(res => res.json())
      .then(data => setWeather(data));
  }, []);
  
  return <div>{weather?.temperature}</div>;
}

// RECOMMENDED: Using a backend proxy
// In a React component:
function WeatherWidget() {
  const [weather, setWeather] = useState(null);
  
  useEffect(() => {
    fetch(`/api/weather`) // Backend proxy endpoint, no exposed secrets
      .then(res => res.json())
      .then(data => setWeather(data));
  }, []);
  
  return <div>{weather?.temperature}</div>;
}

// On the backend:
app.get('/api/weather', async (req, res) => {
  try {
    // API key safely stored in environment variable
    const response = await fetch(`https://api.weather.com/forecast?key=${process.env.WEATHER_API_KEY}`);
    const data = await response.json();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch weather data' });
  }
});
```

### Detecting and Preventing Secret Leaks

#### Implement Git Hooks for Secret Detection
- Use pre-commit hooks to prevent committing secrets
- Implement automated scanning in your CI/CD pipeline
- Consider using tools like GitGuardian, TruffleHog, or Gitleaks

```bash
# RECOMMENDED: Example pre-commit hook using Gitleaks
#!/bin/sh

# Check for secrets using gitleaks
gitleaks protect --staged

# If secrets are detected, prevent commit
if [ $? -ne 0 ]; then
  echo "Error: Potential secrets detected in your commit!"
  echo "Please remove sensitive information before committing."
  exit 1
fi
```

## References
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [NIST Guidelines for Password Management](https://pages.nist.gov/800-63-3/sp800-63b.html)
- [12 Factor App - Config](https://12factor.net/config)

Visit Untamed Theory (https://untamed.cloud) for additional detail.
