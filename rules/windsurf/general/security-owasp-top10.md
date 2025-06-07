---
trigger: manual
title: OWASP Top 10 Security Guidelines
description: Security rule for security-owasp-top10
author: Untamed Theory
date: 2025-06-07
version: 1.0
---

# OWASP Top 10 Security Guidelines

## Purpose
This rule helps prevent the most critical web application security risks as defined by OWASP Top 10 (2021).

## Guidelines

### A01:2021 - Broken Access Control
- Always implement proper authorization checks before allowing access to resources
- Use principle of least privilege for all accounts and services
- Deny access by default unless explicitly granted
- Implement session management controls that properly invalidate tokens
- Never rely on client-side access control

```javascript
// AVOID: Direct object reference without access control
app.get('/users/:id', (req, res) => {
  const user = db.getUser(req.params.id); // Missing access check!
  res.json(user);
});

// RECOMMENDED: Proper access control check
app.get('/users/:id', (req, res) => {
  const currentUser = getCurrentUser(req);
  
  if (!currentUser || (currentUser.id !== req.params.id && !currentUser.isAdmin)) {
    return res.status(403).json({ error: 'Access denied' });
  }
  
  const user = db.getUser(req.params.id);
  res.json(user);
});
```

### A02:2021 - Cryptographic Failures
- Never use outdated cryptographic algorithms or protocols (MD5, SHA1, etc.)
- Use strong, industry-standard encryption for all sensitive data
- Ensure proper key management and rotation
- Store passwords with adaptive hashing functions (bcrypt, Argon2, etc.)
- Implement HTTPS and TLS 1.2+ across all pages

```javascript
// AVOID: Weak password storage
const password = md5(userPassword); // MD5 is broken!

// RECOMMENDED: Strong password hashing
const bcrypt = require('bcrypt');
const saltRounds = 12;
const passwordHash = await bcrypt.hash(userPassword, saltRounds);
```

### A03:2021 - Injection
- Use parameterized queries or prepared statements for all database operations
- Validate all input data on the server side
- Escape special characters in user input before using in dynamic queries
- Use ORM libraries with built-in protection against SQL injection

```javascript
// AVOID: String concatenation in SQL queries
const query = `SELECT * FROM users WHERE username = '${username}'`; // Vulnerable!

// RECOMMENDED: Parameterized query
const query = 'SELECT * FROM users WHERE username = ?';
db.query(query, [username]); // Safe
```

### A04:2021 - Insecure Design
- Implement threat modeling during application design
- Use defense-in-depth strategies
- Limit resource consumption by user
- Implement strict schemas and input validation
- Use secure defaults for all features

### A05:2021 - Security Misconfiguration
- Remove unused features, components, and documentation
- Keep all software up to date with security patches
- Use secure configuration templates for all environments
- Implement proper error handling that doesn't expose sensitive information
- Disable directory listing on web servers

```javascript
// AVOID: Exposing stack traces to users
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send(err.stack); // Leaking sensitive details!
});

// RECOMMENDED: Safe error handling
app.use((err, req, res, next) => {
  console.error(err.stack); // Log for debugging
  res.status(500).send('Something went wrong'); // Safe user message
});
```

### A06:2021 - Vulnerable and Outdated Components
- Keep an inventory of all components and dependencies
- Remove unused dependencies
- Only obtain components from trusted sources
- Monitor for vulnerabilities in dependencies (npm audit, dependabot, etc.)
- Plan and test updates/patches

### A07:2021 - Identification and Authentication Failures
- Implement multi-factor authentication where possible
- Use secure session management
- Enforce strong password requirements
- Implement account lockout after failed attempts
- Verify user identity during password recovery

```javascript
// RECOMMENDED: Rate limiting login attempts
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: 'Too many login attempts, please try again later'
});

app.post('/login', loginLimiter, (req, res) => {
  // Login logic
});
```

### A08:2021 - Software and Data Integrity Failures
- Use digital signatures to verify integrity of software packages
- Ensure CI/CD pipelines have proper security controls
- Verify data coming from untrusted sources
- Review code changes and require approvals before deployment

### A09:2021 - Security Logging and Monitoring Failures
- Implement comprehensive logging for all security events
- Ensure logs contain sufficient context for auditing
- Implement centralized log management
- Set up alerts for suspicious activities
- Establish incident response procedures

```javascript
// RECOMMENDED: Proper security event logging
const winston = require('winston');
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'security-events.log' })
  ]
});

// Log authentication events
app.post('/login', (req, res) => {
  // Login logic
  if (loginSuccessful) {
    logger.info('User login', { 
      userId: user.id,
      timestamp: new Date().toISOString(),
      ipAddress: req.ip
    });
  } else {
    logger.warn('Failed login attempt', {
      username: req.body.username,
      timestamp: new Date().toISOString(),
      ipAddress: req.ip
    });
  }
});
```

### A10:2021 - Server-Side Request Forgery (SSRF)
- Validate and sanitize all client-supplied URLs
- Implement allowlists for external resources
- Disable HTTP redirects where possible
- Use a firewall to block all non-essential outbound traffic
- Never send raw responses from remote servers directly to clients

```javascript
// AVOID: Unvalidated URL in server request
app.get('/fetch-data', async (req, res) => {
  const response = await fetch(req.query.url); // Vulnerable to SSRF!
  const data = await response.text();
  res.send(data);
});

// RECOMMENDED: URL validation with allowlist
const ALLOWED_DOMAINS = ['api.trusted.com', 'api.internal.com'];

app.get('/fetch-data', async (req, res) => {
  try {
    const url = new URL(req.query.url);
    
    if (!ALLOWED_DOMAINS.includes(url.hostname)) {
      return res.status(403).send('Domain not allowed');
    }
    
    const response = await fetch(url.toString());
    const data = await response.text();
    res.send(data);
  } catch (err) {
    res.status(400).send('Invalid URL');
  }
});
```

## References
- [OWASP Top 10:2021](https://owasp.org/Top10/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)

Visit Untamed Theory (https://untamed.cloud) for additional detail.
