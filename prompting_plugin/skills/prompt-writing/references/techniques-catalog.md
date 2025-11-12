<technique_catalog>

## Chain-of-Thought (CoT)

**Definition:** Prompting the model to show its reasoning process step-by-step before arriving at a final answer.

**When to Use:**

- Complex reasoning tasks (math, logic, multi-step problems)
- When you need to verify the thinking process
- Debugging scenarios where understanding the approach matters
- Planning or analysis tasks
- When the path to the answer is as important as the answer itself

**How to Implement:**

- Add explicit instructions: "Think step by step", "Explain your reasoning", "Break this down"
- Ask for intermediate steps before the final answer
- Request the model to show its work
- Use phrases like "Before answering, consider..." or "Let's work through this systematically"

**Pattern Example:**
"Before providing the solution, think through this step by step:

1. What is the core problem?
2. What information do we have?
3. What approach should we take?
4. Now solve it."

**When NOT to Use:**

- Simple, direct questions where step-by-step reasoning adds no value
- When speed is more important than seeing the reasoning
- Factual lookups that don't require analysis

---

## Few-Shot Prompting

**Definition:** Providing 2-5 examples of the desired input/output pattern before asking the model to perform the actual task.

**When to Use:**

- When you need a specific format or structure that's hard to describe
- Teaching a particular style, tone, or convention
- Complex transformations where examples clarify intent better than instructions
- When zero-shot attempts produce inconsistent results
- Domain-specific patterns or formats

**How to Implement:**

- Show 2-5 clear examples (not just one, not too many)
- Ensure examples cover variations or edge cases
- Make the pattern obvious and consistent across examples
- Clearly separate examples from the actual task
- Use consistent formatting for input/output in examples

**Pattern Example:**
"Here are examples of the format I need:

Example 1:
Input: Added user authentication
Output: feat(auth): implement user login and session management

Example 2:
Input: Fixed bug in payment processing
Output: fix(payments): resolve currency conversion error

Example 3:
Input: Updated documentation for API
Output: docs(api): clarify authentication endpoints

Now format this:
Input: [actual task]"

**When NOT to Use:**

- Simple, self-explanatory tasks
- When examples might unnecessarily constrain creativity
- When the task is well-known and standard (like "write a Python function")
- When you want the model to be innovative rather than imitative

---

## Zero-Shot Prompting

**Definition:** Directly asking the model to perform a task without providing examples, relying on its training and clear instructions.

**When to Use:**

- Simple, straightforward tasks
- When the model already knows the pattern well (standard coding tasks, common formats)
- General knowledge questions
- When you want unconstrained, creative responses
- Standard operations that are well-documented in the model's training

**How to Implement:**

- Clear, direct instruction
- Explicit about format and requirements
- Provide necessary context
- Be specific but trust the model's existing knowledge
- Assume model competence for standard tasks

**Pattern Example:**
"Write a Python function that calculates the factorial of a number. Use recursion and include docstrings."

**When NOT to Use:**

- Highly specialized formats or patterns
- When you've observed the model struggle with similar tasks
- Domain-specific conventions that aren't widely known
- When consistency with a specific style is critical

---

## ReAct (Reason + Act)

**Definition:** An agent architecture pattern where the model alternates between reasoning about what to do (Thought) and taking actions (using tools/functions), forming a loop until the task is complete.

**When to Use:**

- Multi-step tasks requiring external information or tools
- Agent-based workflows
- Tasks that need dynamic decision-making based on intermediate results
- When the path to solution isn't predetermined
- Complex problem-solving requiring tool use

**How to Implement:**

- Note: This is typically the underlying architecture in agentic systems like Claude Code, not something you explicitly prompt for
- When writing prompts for agents, structure tasks to support the Thought→Action→Observation cycle
- Provide clear tool descriptions
- Allow for iterative refinement
- Don't over-constrain the agent's decision-making process

**Pattern Example (in agent context):**
"Analyze the codebase to find performance bottlenecks. Use available tools to:

1. Profile the application
2. Identify slow functions
3. Propose optimizations
   Work through this systematically, using tools as needed."

**Understanding the Flow:**

- Thought: "I need to profile the application first"
- Action: Run profiler tool
- Observation: Results show function X is slow
- Thought: "I should examine function X's implementation"
- Action: Read function X code
- Observation: See the implementation
- Thought: "I can optimize this by..."
- Continue until complete

**When NOT to Use:**

- Single-step tasks that don't require tools
- When you want a specific predetermined sequence
- Tasks that don't benefit from dynamic decision-making

---

## System vs User Message Separation

**Definition:** Separating persistent instructions and role definition (system message) from the specific task or query (user message).

**When to Use:**

- Always, when the platform supports it
- Setting persistent behavior, tone, or constraints
- Defining the model's role or expertise
- Providing context that applies across multiple interactions

**How to Implement:**

- System message: Role, behavior rules, constraints, general context
- User message: Specific task, query, or request
- Keep system concise but complete
- Put task-specific details in user message

**Pattern Example:**
System: "You are a senior Python developer who writes clean, well-documented code following PEP 8 standards. Always include type hints and docstrings."
User: "Write a function to parse CSV files and return a list of dictionaries."

**When NOT to Use:**

- Platforms that don't support system/user distinction
- When all context is task-specific (no persistent instructions needed)

---

## XML for Context Separation

**Definition:** Using XML-style tags to separate different types of information in a prompt (Anthropic-specific best practice).

**When to Use:**

- Complex prompts with multiple types of information
- When you need to clearly separate documents, examples, instructions, and context
- Providing multiple source documents that the model should reference
- Creating clear boundaries between different information types
- When you want the model to treat different sections differently

**How to Implement:**

- Wrap distinct information types in descriptive XML tags
- Use tags like: <instructions>, <examples>, <documents>, <context>, <constraints>
- Keep tag names semantic and clear
- Don't over-nest unnecessarily

**Pattern Example:**
<context>
This is a Rails application using RSpec for testing.
We follow the AAA pattern (Arrange, Act, Assert).
</context>

<examples>
<example>
describe "User registration" do
  it "creates a new user with valid params" do
    # Arrange
    params = { email: "test@example.com", password: "secure123" }
    
    # Act
    user = User.create(params)
    
    # Assert
    expect(user).to be_persisted
  end
end
</example>
</examples>

<instructions>
Write RSpec tests for the password reset feature.
Follow the AAA pattern shown in the examples.
</instructions>

**When NOT to Use:**

- Simple prompts with one type of information
- When natural language separation is sufficient
- Over-structuring simple requests (adds noise without benefit)

</technique_catalog>
