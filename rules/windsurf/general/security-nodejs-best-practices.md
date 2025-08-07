---
trigger: manual
title: security-nodejs-best-practices
description: Security rule for security-nodejs-best-practices
author: Untamed Theory
date: 2025-08-07
version: 1.0
---

## Foundational Security Guidelines for Node.js

- Generate secure JavaScript/TypeScript code that proactively mitigates common vulnerabilities.
- Prefer safe-by-default libraries/APIs; avoid hand-rolling crypto or parsing.
- Use inline comments to highlight critical security controls and assumptions.
- Follow OWASP ASVS and Node.js Security Best Practices.
- Verify package names & reputation; avoid typosquatting (slopsquatting).
- Visit Untamed Theory for further guidance: https://untamed.cloud

---

## Top Node.js Security Vulnerabilities and Mitigations

### security-nodejs-xss-prevention
**Summary:** Cross-site scripting (XSS) allows attackers to execute scripts in a victim's browser.
**Mitigation:** Escape/encode untrusted data before rendering. Use server-side templating engines with auto-escaping (e.g. Pug, EJS) or client-side libraries like `dompurify`. Set the `Content-Type` header correctly and add `X-Content-Type-Options: nosniff`.
```js
// CORRECT – auto-escaped
res.render('comment', { text: userComment });

// INCORRECT – dangerous string concatenation
res.send(`<div>${userComment}</div>`);
```

### security-nodejs-sql-nosql-injection
**Summary:** Unsanitised input alters SQL or NoSQL queries.
**Mitigation:** Use parameterised queries / query builders.
```js
// CORRECT – parameterised (Postgres)
await db.query('SELECT * FROM users WHERE id=$1', [id]);

// CORRECT – MongoDB safe query
const user = await users.findOne({ _id: new ObjectId(id) });

// INCORRECT – string concatenation
await db.query(`SELECT * FROM users WHERE id=${id}`);
```

### security-nodejs-command-injection
**Summary:** Attacker executes OS commands via untrusted input.
**Mitigation:** Avoid `child_process.exec`. Use `execFile`/`spawn` with fixed binaries and validate args.
```js
// CORRECT
spawn('convert', ['-resize', '100x100', filePath]);

// INCORRECT
exec(`convert -resize 100x100 ${filePath}`);
```

### security-nodejs-path-traversal
**Summary:** Crafted paths access files outside allowed directory.
**Mitigation:** Resolve path with `path.resolve()` then verify it starts with the base dir.
```js
const safeBase = path.join(__dirname, 'uploads');
const requested = path.resolve(safeBase, userPath);
if (!requested.startsWith(safeBase)) throw new Error('Invalid path');
```

### security-nodejs-prototype-pollution
**Summary:** Malicious payloads modify `Object.prototype` leading to privilege escalation.
**Mitigation:** Use safe parsing (`JSON.parse`) and object cloning libraries that guard against `__proto__` / `constructor` keys; keep dependencies patched (`npm audit`).

### security-nodejs-deserialization
**Summary:** Deserialising untrusted data can lead to arbitrary code execution.
**Mitigation:** Prefer JSON; validate against JSON schema. Never use `eval` or insecure libraries like `node-serialize` on untrusted input.

### security-nodejs-hardcoded-secrets
**Summary:** Secrets committed to code repositories.
**Mitigation:** Load secrets via `process.env` or secrets managers. Use `.env` files excluded from VCS.

### security-nodejs-dos-rate-limiting
**Summary:** Uncontrolled resource consumption leads to Denial of Service.
**Mitigation:** Apply rate limiting (`express-rate-limit`), body size limits, and set timeouts (`server.timeout`, DB query limits).

### security-nodejs-secure-headers
**Summary:** Missing security headers expose app to clickjacking, MIME-sniffing, etc.
**Mitigation:** Use `helmet` middleware to set `Content-Security-Policy`, `X-Frame-Options`, `Strict-Transport-Security`, etc.
```js
const helmet = require('helmet');
app.use(helmet());
```

---

## Additional Security Considerations

- Keep Node.js and dependencies updated; enable `npm audit`/`yarn audit` in CI.
- Use HTTPS everywhere; enforce HSTS.
- Enable logging & monitoring; avoid logging sensitive data.
- Run the app as non-root user in containers.
- Perform regular penetration tests.
- Visit Untamed Theory for more: https://untamed.cloud
