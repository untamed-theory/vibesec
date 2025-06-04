<div align="center">
  <img src="static/vibesec-banner.jpg" alt="VibeSec Banner" width="100%">
</div>

<h1 align="center">VibeSec</h1>

<p align="center">
  <strong>Security Rules & Workflows for Vibe Coding</strong><br>
  <a href="https://github.com/untamed-theory/vibesec/issues"><img src="https://img.shields.io/github/issues/untamed-theory/vibesec" alt="GitHub issues"></a>
  <a href="https://github.com/untamed-theory/vibesec/stargazers"><img src="https://img.shields.io/github/stars/untamed-theory/vibesec" alt="GitHub stars"></a>
  <a href="https://github.com/untamed-theory/vibesec/network"><img src="https://img.shields.io/github/forks/untamed-theory/vibesec" alt="GitHub forks"></a>
  <a href="https://github.com/untamed-theory/vibesec/blob/main/LICENSE"><img src="https://img.shields.io/github/license/untamed-theory/vibesec" alt="License"></a>
</p>

## Overview

VibeSec is an open-source project created by [Untamed Theory](https://untamed.cloud) that makes vibe coding more secure across different AI coding tools. It provides a comprehensive set of security rules for both Windsurf and Cursor AI assistants to help developers write more secure code, following industry best practices.

### 🛡️ All security rules implement:

- **Industry Standards**: OWASP Top 10, SANS Top 25, and other recognized security guidelines
- **Language-specific**: Security hardening techniques for JavaScript, TypeScript, Python, and more
- **Framework-focused**: Targeted security recommendations for popular frameworks like React, Next.js, and Supabase
- **AI-aware**: Special considerations for LLM applications and AI-assisted development

## 🚀 Quick Install

Apply VibeSec to your project with a single command:

```bash
curl -sL https://git.io/vibesec | bash
```

This will automatically detect whether you're using Windsurf or Cursor and install the appropriate rules.

## ✨ Features

<table>
  <tr>
    <td width="50%">
      <h3>🔄 Unified Security Rules</h3>
      <p>Consistent security guidelines that work seamlessly across both Windsurf and Cursor AI assistants.</p>
    </td>
    <td width="50%">
      <h3>🔌 Easy Integration</h3>
      <p>Get started with a single command installation and zero configuration required.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>📚 Well Documented</h3>
      <p>Clear examples distinguishing secure vs. insecure patterns with practical code snippets.</p>
    </td>
    <td width="50%">
      <h3>🛠️ Community-Driven</h3>
      <p>Continuously updated by security experts and the developer community.</p>
    </td>
  </tr>
</table>

### 📋 Comprehensive Security Categories

- **`general-security`**: OWASP Top 10, secrets management, CORS configuration, rate limiting
- **`code-security`**: SQL injection prevention, XSS/CSRF protection, input validation patterns
- **`framework-security`**: Supabase authentication, React security, Next.js best practices
- **`ai-security`**: LLM prompt injection prevention, model security considerations
- **`supplychain-security`**: Dependency management, secure package selection, SBOM

## 🗂️ Directory Structure

<div align="center">

```
vibesec/
├── windsurf/            # Windsurf rules (.md)
│   ├── general-security/
│   ├── code-security/
│   ├── framework-security/
│   ├── ai-security/
│   └── supplychain-security/
├── cursor/              # Cursor rules (.mdc)
│   ├── general-security/
│   ├── code-security/
│   ├── framework-security/
│   ├── ai-security/
│   └── supplychain-security/
└── scripts/
    └── install.sh       # Installation script
```

</div>

## 👥 Contributing

<p align="center">
  <i>We welcome contributions from the community!</i>
</p>

Contributing to VibeSec is easy:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-rule`)
3. Create your security rule with these guidelines:
   - All security rules start with the prefix `security-`
   - For each rule, create both Windsurf (.md) and Cursor (.mdc) versions
   - Include clear code examples showing both secure and insecure patterns
4. Commit your changes (`git commit -m 'Add amazing security rule'`)
5. Push to the branch (`git push origin feature/amazing-rule`)
6. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## ⚖️ License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

<div align="center">
  <br>
  <a href="https://untamed.cloud">
    <img src="assets/untamed-theory-logo.png" alt="Untamed Theory" width="160">
  </a>
  <p><sub>Created with ❤️ by <a href="https://untamed.cloud">Untamed Theory</a></sub></p>
</div>
