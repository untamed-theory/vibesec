---
trigger: manual
description: Guidelines for creating and maintaining Cursor rules
---

# 🖊️ Cursor Rules – Best Practices

## Rule Creation & Structure

- **Directory Location**: Though normally we'd store cursor rules in the `.cursor` directory, because this is meant to be shared we will store the windsurf rules in a file called `cursor` (not hidden). the cursor directory will then contain the cursor rules.
- **Format**: Use MDC (Markdown with Code) format with YAML front-matter.
- **Essential Front-matter Fields**:
  ```yaml
  ---
  description: Brief description of rule purpose
  globs: ["path/to/files/**/*.ext"]  # Patterns of files this rule applies to
  alwaysApply: false  # Whether rule should be automatically applied
  ---
  ```

## Rule Management

- **Modularity**: Break complex logic into small, focused rules for better maintainability.
- **Reference Files**: Include reference files (e.g., `@config.yaml`, `@model.ts`) to help the AI learn structure.
- **Application Modes**: Choose appropriate rule modes:
  - `alwaysApply`: Applied to every matching file automatically
  - `auto-attach`: Attached when certain conditions are met
  - `agent-requested`: Used when AI agent determines it's needed
  - `manual`: Applied only when explicitly requested

- **Size Constraints**: Keep each rule under 500 lines and easily explainable by the AI.

## Naming & Documentation

- **Clear Names**: Use clear, imperative rule names (e.g., "Use company-wide logging format").
- **Version Control**: Store rules with version control and treat them like internal documentation.
- **Accessibility**: Ensure teammates can quickly pull a rule into AI context using `@Cursor Rules`.

## Directory Structure

```
/cursor/
  ├── vibesec-general/      # General security rules
  ├── vibesec-code/         # Code security rules
  ├── vibesec-framework/    # Framework security rules
  ├── vibesec-ai/           # AI security rules
  └── vibesec-supplychain/  # Supply chain security rules
```

## Implementation Guidelines

- **Specificity**: Make rules as specific as possible to avoid false positives.
- **Examples**: Include examples of both correct and incorrect implementations.
- **Error Messages**: Provide clear, actionable error messages.
- **Maintenance**: Regularly review and update rules to match evolving project standards.

## Best Practices for Rule Content

- **Context**: Provide sufficient context for the AI to understand the rule's purpose.
- **Clarity**: Use clear, concise language in explanations.
- **Examples**: Include concrete examples showing how the rule should be applied.
- **Exceptions**: Document any exceptions to the rule and how they should be handled.

## Additional Resources

- [Cursor Documentation](https://docs.example.com/cursor)
- [Rule Development Guide](https://docs.example.com/cursor/rule-development)