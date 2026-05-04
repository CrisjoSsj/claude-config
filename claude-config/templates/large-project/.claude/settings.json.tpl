{
  "permissions": {
    "allow": [
      "Bash({{TEST_CMD}})",
      "Bash({{LINT_CMD}})",
      "Bash({{BUILD_CMD}})",
      "Bash({{TYPECHECK_CMD}})",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git status:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(git reset --hard origin:*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "{{LINT_FIX_CMD}}"
          }
        ]
      }
    ]
  }
}
