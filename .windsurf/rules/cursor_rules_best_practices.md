---
trigger: manual
description: Guidelines for creating and maintaining Cursor rules
---

# 🖊️ Cursor Rules – Best Practices

## Rule Creation & Structure

- **Directory Location**: The canonical rules live in the `definitions/` directory, while the Cursor-specific rules are automatically generated in the `rules/cursor/` directory.
- **Format**: Use MDC (Markdown with Code) format with YAML front-matter for Cursor rules.
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
definitions/
├── frontend/           # Frontend security rules
├── backend/            # Backend & API security rules
├── database/           # Database security rules
├── infrastructure/     # Infrastructure & DevOps security rules
├── ai/                 # AI & LLM security rules
├── supply-chain/       # Supply chain security rules
└── general/            # Cross-cutting security principles
```

```
rules/
└── cursor/             # Cursor-specific rules
    ├── frontend/        # Frontend security rules
    ├── backend/         # Backend & API security rules
    └── ...             # Other component directories
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