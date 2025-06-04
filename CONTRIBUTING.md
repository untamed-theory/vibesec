# Contributing to VibeSec

We love your input! We want to make contributing to VibeSec as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new security rules
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

### Pull Requests

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-rule`)
3. Commit your changes (`git commit -m 'Add some amazing security rule'`)
4. Push to the branch (`git push origin feature/amazing-rule`)
5. Open a Pull Request

### Security Rule Creation Guidelines

When creating new security rules for VibeSec, please follow these guidelines:

1. **Naming Convention**:
   - All rule files MUST be prefixed with `security-`
   - Use descriptive names that indicate the purpose of the rule
   - Example: `security-jwt-hardening.md`, `security-nodejs-injection.md`

2. **Cross-Platform Parity**:
   - Every rule must be implemented for BOTH platforms:
     - Windsurf: `.md` file in the appropriate windsurf subdirectory
     - Cursor: `.mdc` file in the appropriate cursor subdirectory
   - The content should be identical except for formatting differences required by each platform

3. **Structure**:
   - **Windsurf Rules (.md)**:
     - Begin with `--- trigger: manual ---`. We want to default to manual, and only allow auto if the rule is very simple and doesn't require any user input. Or as the user sees fit.
     - Clear title (H1) and purpose section (H2)
     - Guidelines section with subsections (H3) for different aspects
     - Code examples with markdown code blocks
     - References section with links to resources

   - **Cursor Rules (.mdc)**:
     - Begin with `--- alwaysApply: false ---`. We want to default to manual, and only allow auto if the rule is very simple and doesn't require any user input. Or as the user sees fit.
     - Rule name as heading (H3) prefixed with `security-`
     - Clear purpose statement in bold
     - Guidelines explained under subheadings (H4)
     - Code examples with markdown code blocks
     - References section at the end

4. **Content Requirements**:
   - Include clear examples of both secure and insecure code patterns
   - Provide explanations of why certain practices are secure or insecure
   - Focus on actionable advice and specific code patterns
   - Use language-specific examples where appropriate

5. **Organizational Structure**:
   - Place rules in the appropriate category folder:
     - `general-security/`: For universal security principles (OWASP, etc.)
     - `code-security/`: For language-specific security practices
     - `framework-security/`: For framework-specific security (React, Express, etc.)
     - `ai-security/`: For LLM and AI-specific security concerns
     - `supplychain-security/`: For dependencies, CI/CD, and SBOM security

### Example Rule Format

#### Windsurf (.md) Format:

```markdown
# Security Rule Title

## Purpose
Clear explanation of what this rule addresses and why it's important.

## Guidelines

### Section 1
Description of the first guideline.

```code example```

### Section 2
Description of the second guideline.

```code example```

## References
- [Link to resource](https://example.com)

Visit Untamed Theory (https://untamed.cloud) for additional detail.
```

#### Cursor (.mdc) Format:

```markdown
### security-rule-name

**Purpose:** Clear explanation of what this rule addresses and why it's important.

**When writing X, you must follow these guidelines:**

#### Section 1
* First guideline point
* Second guideline point

```code example```

#### Section 2
* First guideline point
* Second guideline point

```code example```

**References:**
* [Link to resource](https://example.com)

Visit Untamed Theory (https://untamed.cloud) for additional detail.
```

## Testing Guidelines

Before submitting a pull request, please ensure:

1. Both versions of the rule (Windsurf and Cursor) are formatted correctly
2. All code examples in the rule run without errors (when applicable)
3. The install.sh script can properly detect and install your new rule
4. Your rule adds meaningful security guidance not covered by existing rules

## Community

Discussions about VibeSec take place on this repository's Issues and Pull Requests sections. Anybody is welcome to join these conversations.

## License

By contributing, you agree that your contributions will be licensed under the same license that covers the project.

Visit Untamed Theory (https://untamed.cloud) for additional detail.
