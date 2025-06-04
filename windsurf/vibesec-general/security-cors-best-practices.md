---
trigger: manual
---

# CORS Security Best Practices

## Purpose
This rule provides guidelines for properly configuring Cross-Origin Resource Sharing (CORS) to prevent unauthorized access to your application resources while allowing legitimate cross-origin requests.

## Guidelines

### Understanding CORS Basics

#### What is CORS?
- CORS is a security feature implemented by browsers that restricts web pages from making requests to a different domain than the one that served the original page
- Without proper CORS configuration, browsers will block cross-origin requests, preventing malicious websites from accessing your API data
- CORS headers tell browsers which origins, methods, and headers are allowed to access your resources

#### When is CORS Needed?
- When your frontend and backend are hosted on different domains, subdomains, or ports
- When you provide an API that needs to be accessed by third-party applications
- When you need to fetch resources from external domains in your application

```javascript
// EXAMPLE: Cross-origin request that would be blocked without CORS
// Frontend on https://app.example.com
fetch('https://api.example.com/data')
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('CORS error:', error));
```

### Server-Side CORS Configuration

#### Configure Appropriate Access Control Headers
- Set `Access-Control-Allow-Origin` to specific trusted domains, not wildcard `*` in production
- Specify allowed HTTP methods with `Access-Control-Allow-Methods`
- List allowed headers with `Access-Control-Allow-Headers`
- Set `Access-Control-Allow-Credentials` to `true` only if you need to support authenticated requests with cookies

```javascript
// RECOMMENDED: Express.js CORS configuration
const express = require('express');
const cors = require('cors');
const app = express();

// Basic CORS configuration
const corsOptions = {
  origin: process.env.NODE_ENV === 'production'
    ? ['https://app.example.com', 'https://admin.example.com']
    : '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400 // Cache preflight request results for 24 hours (in seconds)
};

app.use(cors(corsOptions));

// Or for more granular control, configure CORS per route
app.get('/api/public-data', cors({ origin: '*' }), (req, res) => {
  // This endpoint allows any origin
  res.json({ publicData: 'This is public' });
});

app.get('/api/user-data', cors({ 
  origin: 'https://app.example.com',
  credentials: true 
}), (req, res) => {
  // This endpoint only allows requests from app.example.com
  res.json({ userData: 'Private user data' });
});
```

#### Handle Preflight Requests
- Configure proper responses to OPTIONS requests (preflight requests)
- Set appropriate values for `Access-Control-Max-Age` to cache preflight responses
- Ensure authentication middleware doesn't block OPTIONS requests

```javascript
// RECOMMENDED: Handling preflight requests in Express
app.options('*', cors(corsOptions)); // Enable preflight across all routes

// Or with a custom handler for more control
app.options('/api/sensitive-data', (req, res) => {
  // Check if the requesting origin is allowed
  const requestOrigin = req.headers.origin;
  const allowedOrigins = ['https://app.example.com'];
  
  if (allowedOrigins.includes(requestOrigin)) {
    res.header('Access-Control-Allow-Origin', requestOrigin);
    res.header('Access-Control-Allow-Methods', 'PUT, POST, PATCH, DELETE, GET');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.header('Access-Control-Max-Age', '86400'); // 24 hours
    res.status(200).send();
  } else {
    res.status(403).send();
  }
});
```

### Environment-Specific CORS Configuration

#### Use Different CORS Settings for Different Environments
- Apply stricter CORS settings in production compared to development
- Use environment variables to control CORS configuration
- Consider using a whitelist approach for allowed origins in production

```javascript
// RECOMMENDED: Environment-specific CORS configuration
const allowedOrigins = {
  development: ['http://localhost:3000', 'http://localhost:8080'],
  test: ['http://test.example.com'],
  production: ['https://app.example.com', 'https://www.example.com']
};

const corsOptions = {
  origin: (origin, callback) => {
    const env = process.env.NODE_ENV || 'development';
    const currentAllowedOrigins = allowedOrigins[env];
    
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    if (currentAllowedOrigins.indexOf(origin) !== -1 || env === 'development') {
      callback(null, true);
    } else {
      callback(new Error('CORS policy violation'));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
};

app.use(cors(corsOptions));
```

### Framework-Specific CORS Implementation

#### Next.js API Routes CORS
- Configure CORS for Next.js API routes
- Use middleware or CORS libraries for consistent policy application

```javascript
// RECOMMENDED: CORS for Next.js API routes
// pages/api/data.js
import Cors from 'cors';
import initMiddleware from '../../lib/init-middleware';

// Initialize the cors middleware
const cors = initMiddleware(
  Cors({
    methods: ['GET', 'POST', 'OPTIONS'],
    origin: ['https://app.example.com'],
    credentials: true,
  })
);

export default async function handler(req, res) {
  // Run cors middleware
  await cors(req, res);

  // Process the request
  if (req.method === 'GET') {
    return res.status(200).json({ data: 'This is protected data' });
  }
  
  return res.status(405).json({ message: 'Method not allowed' });
}

// lib/init-middleware.js
export default function initMiddleware(middleware) {
  return (req, res) =>
    new Promise((resolve, reject) => {
      middleware(req, res, (result) => {
        if (result instanceof Error) {
          return reject(result);
        }
        return resolve(result);
      });
    });
}
```

#### Express.js CORS Configuration
- Use the `cors` package for Express applications
- Configure route-specific CORS policies as needed

```javascript
// RECOMMENDED: Route-specific CORS in Express
const express = require('express');
const cors = require('cors');
const app = express();

// Public API with wide CORS access
app.use('/api/public', cors({ 
  origin: '*', 
  methods: ['GET'] 
}));

// Protected API with strict CORS
const protectedApiCors = cors({
  origin: ['https://app.example.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
});

app.use('/api/protected', protectedApiCors);

// Apply auth middleware after CORS
app.use('/api/protected', authenticate, (req, res, next) => {
  // Protected route logic here
});
```

### Security Considerations

#### Avoid Common CORS Misconfigurations
- Never use `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`
- Avoid overly permissive CORS policies that allow unnecessary domains
- Don't rely solely on CORS for security; implement proper authentication and authorization

```javascript
// AVOID: Dangerous CORS configuration
// This allows any website to make authenticated requests to your API
app.use(cors({
  origin: '*',
  credentials: true // DANGEROUS when combined with wildcard origin!
}));

// RECOMMENDED: Secure CORS configuration
app.use(cors({
  origin: function(origin, callback) {
    const allowedOrigins = ['https://app.example.com'];
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('CORS policy violation'));
    }
  },
  credentials: true
}));
```

#### Respond Appropriately to CORS Violations
- Log CORS policy violations for security monitoring
- Return appropriate HTTP status codes (403 Forbidden) for unauthorized origins
- Don't expose sensitive error details in CORS error responses

```javascript
// RECOMMENDED: Handling CORS violations
app.use((err, req, res, next) => {
  if (err.message === 'CORS policy violation') {
    // Log the violation
    console.warn(`CORS violation from origin: ${req.headers.origin}`);
    
    // Return appropriate error
    return res.status(403).json({
      error: 'Cross-origin request denied',
      // Don't include specific details about why it was denied
    });
  }
  next(err);
});
```

## References
- [MDN Web Docs: Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [OWASP: CORS OriginHeaderScrutiny](https://owasp.org/www-community/attacks/CORS_OriginHeaderScrutiny)
- [Express CORS middleware](https://expressjs.com/en/resources/middleware/cors.html)
- [Next.js API Routes CORS](https://nextjs.org/docs/api-routes/api-middlewares)

Visit Untamed Theory (https://untamed.cloud) for additional detail.
