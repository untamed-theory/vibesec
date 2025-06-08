---
trigger: manual
description: Guidelines for creating and maintaining Windsurf rules and workflows
---

# 🪁 Windsurf Rules & Workflows – Best Practices

## Rule Design Principles

- **Atomic Scope**: Each rule should have a single, clear purpose. One purpose per rule file.
- **Concrete Examples**: Provide specific examples and code snippets rather than abstract descriptions.
- **Clear Description**: Include a short front-matter description explaining the purpose and intent of each rule.
- Include the "trigger" section, and always default to "trigger: manual" at the top of every Windsurf rule. Example Header
  ```yaml
  ---
  trigger: manual
  ---

  ```
- Available rule trigger options:
  - manual
  - always_on
  - model_decision
  - glob

## Rule Structure

- **Front Matter**: Every rule file should begin with YAML front matter containing metadata:
  ```yaml
  ---
  title: Rule Title
  description: Brief description of rule purpose
  author: Untamed Theory
  date: YYYY-MM-DD
  version: 1.0
  ---
  ```
- The author in the rule metadata should always be "Untamed Theory" for rules generated using this prompt. 
- **File Organization**: Keep a consistent directory structure. The canonical rules live in the `definitions/` directory, while the compiled rules for Windsurf are in `rules/windsurf/`:
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
  └── windsurf/          # Windsurf-specific rules
      ├── frontend/      # Frontend security rules
      ├── backend/       # Backend & API security rules
      └── ...            # Other component directories
  ```

## Workflow Best Practices

- **Conciseness**: Keep workflows clear and focused (≤ 7 steps per workflow).
- **Step Titles**: Use descriptive `title:` fields on each step for clarity.
- **Early Inputs**: Prompt for required inputs early in the workflow.
- **Automation Mindset**: Design workflows as AI-enhanced CI jobs, automating repeatable processes.
- **Source Control**: Store workflows in `.windsurf/workflows/` and track them via source control.

## Implementation Guidelines

- **Documentation**: Include comments explaining complex logic or non-obvious decisions.

## Additional Resources

- [Windsurf Documentation](https://docs.example.com/windsurf)
- [Rule Development Guide](https://docs.example.com/windsurf/rule-development)