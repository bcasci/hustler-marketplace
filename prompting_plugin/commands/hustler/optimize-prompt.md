---
description: Optimizes prompts using prompt-writing skill. Accepts filepath (writes back), filepath with instructions, or free-form prompt text (returns optimized version).
argument-hint: [filepath-or-prompt-text] [additional-instructions]
allowed-tools: "Read, Write, Skill(prompt-writing)"
---

Optimize a prompt using your prompt-writing skill.

**Input handling:**

1. Parse $ARGUMENTS to determine context:
   - If first word is an existing file path → file optimization mode
   - Otherwise → free-form prompt optimization mode

**File optimization mode:**

1. Read the file at the specified path
2. Extract any additional instructions from remaining arguments
3. Use your prompt-writing skill to optimize the prompt with instruction: "Optimize this prompt: [file contents]. Additional context: [instructions if provided]"
4. Write the optimized prompt back to the original file path
5. Report what changed and why

**Free-form optimization mode:**

1. Treat all $ARGUMENTS as prompt text to optimize
2. Use your prompt-writing skill to optimize with instruction: "Optimize this prompt: $ARGUMENTS"
3. Output the optimized prompt
4. Include brief explanation of techniques applied

**Important:**

- Always invoke the prompt-writing skill explicitly
- In file mode, write the result back to the file
- In free-form mode, output the result for user review
- Preserve user's core intent while applying techniques and reducing bloat
