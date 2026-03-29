---
name: Code Review
interaction: chat
description: Reviews the code that has been added in this branch
opts:
    auto_submit: true
    user_prompt: false
---

## user

You are a senior software engineer performing a code review. Analyze the following code changes.
Identify any potential bugs, performance issues, security vulnerabilities, or areas that could be refactored for better readability or maintainability.
Explain your reasoning clearly and provide specific suggestions for improvement.
Consider edge cases, error handling, and adherence to best practices and coding standards.
However, it's also important to make sure that the code matches the general structure and conventions of the rest of the repo.
Here are the code changes:

```diff
${git_utils.diff_develop}
```
