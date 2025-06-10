---
trigger: manual
title: Next.js Security Best Practices
description: Security rule for security-nextjs-best-practices
author: Untamed Theory
date: 2025-06-10
version: 1.0
---

# Next.js Security Best Practices

## Purpose
This rule provides specific security guidelines for Next.js applications to protect against common vulnerabilities and implement secure coding practices.

## Guidelines

### Server-Side Rendering (SSR) Security

#### Secure Data Fetching
- Avoid exposing credentials or sensitive API tokens in client-side code
- Use environment variables for sensitive configuration
- Implement proper error handling to prevent leaking sensitive information

```javascript
// AVOID: Exposing API keys in getStaticProps or getServerSideProps
export async function getServerSideProps() {
  const res = await fetch('https://api.example.com/data', {
    headers: {
      'Authorization': 'Bearer sk_live_1234567890abcdef' // API key exposed!
    }
  });
  const data = await res.json();
  return { props: { data } };
}

// RECOMMENDED: Using environment variables for sensitive data
export async function getServerSideProps() {
  const res = await fetch('https://api.example.com/data', {
    headers: {
      'Authorization': `Bearer ${process.env.API_KEY}` // API key protected
    }
  });
  const data = await res.json();
  
  // Error handling to prevent leaking sensitive information
  if (!res.ok) {
    return { 
      props: { 
        error: 'Failed to load data',
        // Do not return raw error details to the client
      } 
    };
  }
  
  return { props: { data } };
}
```

#### Secure API Routes
- Validate and sanitize all inputs
- Implement rate limiting on API routes
- Use proper authentication and authorization checks

```javascript
// RECOMMENDED: API route with validation, rate limiting, and auth check
import { getSession } from 'next-auth/client';
import { rateLimit } from '../../lib/rate-limit';

const limiter = rateLimit({
  interval: 60 * 1000, // 60 seconds
  uniqueTokenPerInterval: 500, // Max 500 users per interval
});

export default async function handler(req, res) {
  try {
    // Apply rate limiting
    await limiter.check(res, 10, 'CACHE_TOKEN'); // 10 requests per minute
    
    // Validate request method
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }
    
    // Get authenticated session
    const session = await getSession({ req });
    if (!session) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Validate input
    const { id } = req.body;
    if (!id || typeof id !== 'string') {
      return res.status(400).json({ error: 'Invalid request' });
    }
    
    // Process request with authenticated user
    const result = await processRequest(id, session.user);
    return res.status(200).json(result);
    
  } catch (error) {
    if (error.status === 429) {
      return res.status(429).json({ error: 'Rate limit exceeded' });
    }
    
    console.error('API error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
```

### Client-Side Security

#### Prevent XSS in Next.js
- Use `next/script` to safely load third-party scripts
- Avoid using `dangerouslySetInnerHTML` when possible
- When you must use `dangerouslySetInnerHTML`, sanitize the HTML first

```javascript
// AVOID: Unsanitized dangerouslySetInnerHTML
function Comment({ comment }) {
  return <div dangerouslySetInnerHTML={{ __html: comment }} />;
}

// RECOMMENDED: Sanitizing HTML before rendering
import DOMPurify from 'dompurify';

function Comment({ comment }) {
  const sanitizedComment = DOMPurify.sanitize(comment);
  return <div dangerouslySetInnerHTML={{ __html: sanitizedComment }} />;
}

// RECOMMENDED: Using next/script to load third-party scripts
import Script from 'next/script';

function Layout({ children }) {
  return (
    <>
      <Script
        src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"
        strategy="afterInteractive"
        onError={(e) => console.error('Script failed to load', e)}
      />
      <Script id="google-analytics" strategy="afterInteractive">
        {`
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', 'G-XXXXXXXXXX');
        `}
      </Script>
      <main>{children}</main>
    </>
  );
}
```

#### Secure Client-Side Data Fetching
- Implement proper error handling for client-side data fetching
- Use SWR or React Query for safe data handling and caching
- Avoid exposing sensitive information in client-side state

```javascript
// RECOMMENDED: Safe client-side data fetching with SWR
import useSWR from 'swr';

function fetcher(url) {
  return fetch(url).then((res) => {
    if (!res.ok) {
      throw new Error('API request failed');
    }
    return res.json();
  });
}

function Profile() {
  const { data, error } = useSWR('/api/user/profile', fetcher);

  if (error) return <div>Failed to load user profile</div>;
  if (!data) return <div>Loading...</div>;

  // Only show non-sensitive user data
  return (
    <div>
      <h1>Hello, {data.name}</h1>
      <p>Role: {data.role}</p>
      {/* Don't render sensitive information like tokens, full IDs, etc. */}
    </div>
  );
}
```

### Authentication Security

#### Secure Authentication Implementation
- Use established authentication libraries like NextAuth.js
- Implement proper session management
- Configure secure cookies and token handling

```javascript
// RECOMMENDED: NextAuth.js configuration
// pages/api/auth/[...nextauth].js
import NextAuth from 'next-auth';
import Providers from 'next-auth/providers';

export default NextAuth({
  providers: [
    // Your authentication providers
  ],
  session: {
    jwt: true,
    maxAge: 30 * 24 * 60 * 60, // 30 days
    updateAge: 24 * 60 * 60, // 24 hours
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    encryption: true,
  },
  cookies: {
    sessionToken: {
      name: `__Secure-next-auth.session-token`,
      options: {
        httpOnly: true,
        sameSite: 'lax',
        path: '/',
        secure: process.env.NODE_ENV === 'production',
      },
    },
  },
  callbacks: {
    // Custom callback functions
  },
});
```

#### Protect Routes and Pages
- Use getServerSideProps for authenticated pages
- Implement client-side route protection
- Consider using middleware for authentication in Next.js 12+

```javascript
// RECOMMENDED: Protected page with getServerSideProps
import { getSession } from 'next-auth/client';

export default function Dashboard({ user }) {
  return (
    <div>
      <h1>Dashboard</h1>
      <p>Welcome, {user.name}</p>
    </div>
  );
}

export async function getServerSideProps(context) {
  const session = await getSession(context);
  
  if (!session) {
    return {
      redirect: {
        destination: '/login',
        permanent: false,
      },
    };
  }
  
  return {
    props: { user: session.user },
  };
}

// RECOMMENDED: Next.js 12+ Middleware for Auth
// middleware.js
import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';

export async function middleware(req) {
  const token = await getToken({ req, secret: process.env.JWT_SECRET });
  const { pathname } = req.nextUrl;
  
  // Protect routes that start with /dashboard
  if (pathname.startsWith('/dashboard')) {
    if (!token) {
      return NextResponse.redirect(new URL('/login', req.url));
    }
  }
  
  return NextResponse.next();
}
```

### Deployment and Runtime Security

#### Security Headers Configuration
- Configure secure HTTP headers using Next.js config
- Set strict Content Security Policy (CSP) headers
- Enable other security headers like HSTS, X-Frame-Options, etc.

```javascript
// RECOMMENDED: Configure security headers in next.config.js
const securityHeaders = [
  {
    key: 'X-DNS-Prefetch-Control',
    value: 'on',
  },
  {
    key: 'Strict-Transport-Security',
    value: 'max-age=63072000; includeSubDomains; preload',
  },
  {
    key: 'X-XSS-Protection',
    value: '1; mode=block',
  },
  {
    key: 'X-Frame-Options',
    value: 'SAMEORIGIN',
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff',
  },
  {
    key: 'Referrer-Policy',
    value: 'origin-when-cross-origin',
  },
];

module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: securityHeaders,
      },
    ];
  },
};
```

#### Content Security Policy
- Implement CSP to prevent XSS and other code injection attacks
- Use nonces for inline scripts when necessary
- Configure appropriate CSP directives based on your application needs

```javascript
// RECOMMENDED: Implement CSP in custom _document.js
import Document, { Html, Head, Main, NextScript } from 'next/document';
import { nanoid } from 'nanoid';

class MyDocument extends Document {
  static async getInitialProps(ctx) {
    // Generate a new nonce for each request
    const nonce = nanoid();
    const initialProps = await Document.getInitialProps(ctx);
    
    // Add CSP header
    ctx.res.setHeader(
      'Content-Security-Policy',
      `default-src 'self';
       script-src 'self' 'nonce-${nonce}' https://trusted-cdn.com;
       style-src 'self' 'nonce-${nonce}' https://trusted-cdn.com;
       img-src 'self' data: https://trusted-cdn.com;
       font-src 'self' https://trusted-cdn.com;
       connect-src 'self' https://api.example.com;
       frame-src 'none';
       object-src 'none';
       base-uri 'self';`
    );
    
    return {
      ...initialProps,
      nonce,
    };
  }

  render() {
    return (
      <Html>
        <Head nonce={this.props.nonce} />
        <body>
          <Main />
          <NextScript nonce={this.props.nonce} />
        </body>
      </Html>
    );
  }
}

export default MyDocument;
```

## References
- [Next.js Security Documentation](https://nextjs.org/docs/authentication)
- [OWASP Top 10 for Web Applications](https://owasp.org/www-project-top-ten/)
- [Content Security Policy (CSP) Quick Reference](https://content-security-policy.com/)
- [NextAuth.js Security Best Practices](https://next-auth.js.org/getting-started/introduction)

Visit Untamed Theory (https://untamed.cloud) for additional detail.
