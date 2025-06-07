---
trigger: manual
title: Rate Limiting and Throttling Security Guidelines
description: Security rule for security-rate-limiting
author: Untamed Theory
date: 2025-06-07
version: 1.0
---

# Rate Limiting and Throttling Security Guidelines

## Purpose
This rule helps prevent abuse, denial-of-service attacks, and resource exhaustion by implementing proper rate limiting and throttling strategies in your applications.

## Guidelines

### API Rate Limiting

#### Implement Rate Limiting on All APIs
- Apply rate limits to all public-facing API endpoints
- Consider different rate limits for authenticated vs. unauthenticated users
- Include rate limit information in API responses

```javascript
// RECOMMENDED: Express rate limiting middleware
const rateLimit = require('express-rate-limit');

// Create a rate limiter for general API endpoints
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  message: 'Too many requests from this IP, please try again after 15 minutes'
});

// Apply the rate limiter to all API routes
app.use('/api/', apiLimiter);

// Create a stricter rate limiter for authentication endpoints
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5, // limit each IP to 5 login attempts per hour
  message: 'Too many login attempts, please try again after an hour'
});

// Apply the stricter limiter to auth endpoints
app.use('/api/auth/', authLimiter);
```

#### Implement Different Tiers of Rate Limiting
- Use progressive rate limiting strategies
- Implement tiered rate limits based on user roles or subscription plans
- Consider implementing burst limits vs. sustained limits

```javascript
// RECOMMENDED: Tiered rate limiting based on user role
function tierBasedRateLimit(req, res, next) {
  // Get user info from request (after auth middleware)
  const user = req.user;
  
  // Default limits for unauthenticated users
  let rateLimit = {
    maxRequests: 10,
    windowMs: 60 * 1000 // 1 minute
  };
  
  // Adjust limits based on user tier if authenticated
  if (user) {
    switch (user.tier) {
      case 'premium':
        rateLimit.maxRequests = 600;
        rateLimit.windowMs = 60 * 1000;
        break;
      case 'standard':
        rateLimit.maxRequests = 120;
        rateLimit.windowMs = 60 * 1000;
        break;
      case 'free':
        rateLimit.maxRequests = 30;
        rateLimit.windowMs = 60 * 1000;
        break;
    }
  }
  
  // Store the limit in the request for logging/headers
  req.rateLimit = rateLimit;
  
  // Continue to the actual limiter implementation
  next();
}

// Middleware to apply the tier-based limits
app.use('/api/', tierBasedRateLimit, actualRateLimiter);
```

### Backend Protection

#### Protect Critical Backend Resources
- Apply rate limiting to database connections and queries
- Limit concurrent requests to external services
- Implement timeouts for all external calls

```javascript
// RECOMMENDED: Database connection pooling with limits
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  max: 20, // Maximum number of connections in the pool
  idleTimeoutMillis: 30000, // Close idle connections after 30 seconds
  connectionTimeoutMillis: 2000, // Return an error after 2 seconds if connection not established
});

// Queries will now automatically queue if all connections are in use
async function executeQuery(query, params) {
  const client = await pool.connect();
  try {
    return await client.query(query, params);
  } finally {
    client.release();
  }
}

// RECOMMENDED: External API request with timeout and retry logic
const axios = require('axios');
const axiosRetry = require('axios-retry');

// Configure axios with retry logic
axiosRetry(axios, {
  retries: 3, // Number of retry attempts
  retryDelay: axiosRetry.exponentialDelay, // Exponential backoff
  retryCondition: (error) => {
    // Only retry on network errors or 5xx server errors
    return axiosRetry.isNetworkOrIdempotentRequestError(error) || 
           (error.response && error.response.status >= 500);
  }
});

// Make API call with timeout
async function callExternalApi(endpoint, data) {
  try {
    const response = await axios({
      method: 'post',
      url: endpoint,
      data: data,
      timeout: 5000 // 5 second timeout
    });
    return response.data;
  } catch (error) {
    console.error(`API call failed: ${error.message}`);
    throw error;
  }
}
```

#### Implement Queuing for Resource-Intensive Operations
- Use job queues for long-running or resource-intensive tasks
- Implement rate limiting on job processing
- Consider using distributed rate limiting for multi-server setups

```javascript
// RECOMMENDED: Job queue with rate limiting using Bull
const Queue = require('bull');

// Create a queue with concurrency limits
const processQueue = new Queue('data-processing', {
  redis: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT
  },
  limiter: {
    max: 10, // Max number of jobs processed
    duration: 1000 // Per second (10 jobs per second)
  }
});

// Add a job to the queue
app.post('/api/process-data', async (req, res) => {
  try {
    // Add the job to the queue instead of processing immediately
    const job = await processQueue.add(req.body, {
      attempts: 3, // Retry up to 3 times
      backoff: {
        type: 'exponential',
        delay: 1000 // Starting delay of 1 second
      }
    });
    
    res.json({ 
      success: true, 
      jobId: job.id,
      message: 'Your request has been queued for processing'
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to queue job'
    });
  }
});

// Process jobs with controlled concurrency
processQueue.process(5, async (job) => { // Process 5 jobs concurrently
  // Process the job data
  return await processData(job.data);
});
```

### Browser and Client Protection

#### Implement Client-Side Request Throttling
- Throttle user actions like form submissions and button clicks
- Implement debouncing for search inputs and filters
- Prevent duplicate API requests

```javascript
// RECOMMENDED: Button click throttling in React
import { useState } from 'react';
import { throttle } from 'lodash';

function SubmitButton({ onSubmit }) {
  const [isLoading, setIsLoading] = useState(false);
  
  // Throttle the submit function to once per second
  const throttledSubmit = throttle(async () => {
    setIsLoading(true);
    try {
      await onSubmit();
    } finally {
      setIsLoading(false);
    }
  }, 1000, { trailing: false });
  
  return (
    <button 
      onClick={throttledSubmit}
      disabled={isLoading}
    >
      {isLoading ? 'Submitting...' : 'Submit'}
    </button>
  );
}

// RECOMMENDED: Debounced search input
import { useState } from 'react';
import { debounce } from 'lodash';

function SearchInput({ onSearch }) {
  const [query, setQuery] = useState('');
  
  // Debounce the search function to avoid excessive API calls
  const debouncedSearch = debounce((searchTerm) => {
    onSearch(searchTerm);
  }, 300);
  
  const handleChange = (e) => {
    const value = e.target.value;
    setQuery(value);
    debouncedSearch(value);
  };
  
  return (
    <input 
      type="text"
      value={query}
      onChange={handleChange}
      placeholder="Search..."
    />
  );
}
```

### Monitoring and Response

#### Monitor Rate Limit Events
- Log all rate limit breaches for analysis
- Set up alerts for unusual rate limit violations
- Review rate limit configurations based on real usage patterns

```javascript
// RECOMMENDED: Enhanced express-rate-limit with logging
const rateLimit = require('express-rate-limit');
const winston = require('winston');

// Set up logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'rate-limit-events.log' })
  ]
});

// Create rate limiter with custom handler
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  handler: (req, res, next, options) => {
    // Log the rate limit breach
    logger.warn('Rate limit exceeded', {
      ip: req.ip,
      path: req.path,
      method: req.method,
      userAgent: req.headers['user-agent'],
      timestamp: new Date().toISOString()
    });
    
    // Send standard response
    res.status(options.statusCode).send(options.message);
  }
});

app.use('/api/', apiLimiter);
```

#### Implement Adaptive Rate Limiting
- Dynamically adjust rate limits based on server load
- Implement circuit breakers for services under heavy load
- Use automated IP blocking for detected attack patterns

```javascript
// RECOMMENDED: Adaptive rate limiting based on server load
const os = require('os');
const rateLimit = require('express-rate-limit');

// Create a middleware to check server load
function adaptiveRateLimit(req, res, next) {
  // Get current CPU usage
  const cpuLoad = os.loadavg()[0];
  
  // Adjust rate limit based on CPU load
  let maxRequests = 100;
  
  if (cpuLoad > 2.0) {
    // Server under heavy load - restrict to 10 requests
    maxRequests = 10;
  } else if (cpuLoad > 1.0) {
    // Server under moderate load - restrict to 50 requests
    maxRequests = 50;
  }
  
  // Apply rate limit for this request
  const limiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: maxRequests,
    message: `Server is experiencing high load. Please try again later.`
  });
  
  // Call the limiter as a middleware
  limiter(req, res, next);
}

// Apply adaptive rate limit to all API routes
app.use('/api/', adaptiveRateLimit);

// RECOMMENDED: Circuit breaker for external service
const CircuitBreaker = require('opossum');

const serviceCall = (url) => {
  return axios.get(url);
};

const breaker = new CircuitBreaker(serviceCall, {
  timeout: 3000, // If function takes longer than 3 seconds, trigger failure
  resetTimeout: 30000, // After 30 seconds, try again
  errorThresholdPercentage: 50 // Open circuit if 50% of requests fail
});

breaker.fallback(() => {
  return { data: 'Service unavailable, using fallback data' };
});

breaker.on('open', () => {
  console.log('Circuit breaker opened - service appears to be down');
});

breaker.on('close', () => {
  console.log('Circuit breaker closed - service appears to be working again');
});

// Use the circuit breaker
app.get('/api/external-data', async (req, res) => {
  try {
    const response = await breaker.fire('https://external-api.com/data');
    res.json(response.data);
  } catch (error) {
    res.status(503).json({ error: 'Service temporarily unavailable' });
  }
});
```

## References
- [OWASP API Security - API4:2023 Unrestricted Resource Consumption](https://owasp.org/API-Security/editions/2023/en/0xa4-unrestricted-resource-consumption/)
- [Express Rate Limit Documentation](https://github.com/nfriedly/express-rate-limit)
- [Cloudflare Rate Limiting Best Practices](https://www.cloudflare.com/learning/bots/what-is-rate-limiting/)

Visit Untamed Theory (https://untamed.cloud) for additional detail.
