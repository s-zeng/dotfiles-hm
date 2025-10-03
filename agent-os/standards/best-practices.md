# Development Best Practices

## Context

Global development guidelines for Agent OS projects.

<conditional-block context-check="core-principles">
IF this Core Principles section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Core Principles already in context"
ELSE:
  READ: The following principles

## Core Principles

### Keep It Simple
- Implement code in the fewest lines possible
- Avoid over-engineering solutions
- Choose straightforward approaches over clever ones

### Optimize for Readability
- Prioritize code clarity over micro-optimizations
- Write self-documenting code with clear variable names
- Add comments for "why" not "what"

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Extract repeated UI markup to reusable components
- Create utility functions for common operations

### File Structure
- Keep files focused on a single responsibility
- Group related functionality together
- Use consistent naming conventions

### Error Handling
- Always handle errors explicitly; never ignore failure cases
- Provide contextual information in error messages (file paths, URLs, operation being performed)
- Use structured error types instead of plain strings
- Make error messages actionable for debugging
- Log errors at appropriate levels (error, warn, info)

### Testing Strategies
- Write tests for all non-trivial functionality
- Use deterministic test data to ensure reproducible results
- Design tests to work in both online and offline environments
- Test edge cases and error paths, not just happy paths
- Keep tests independent and isolated from each other

### Network Operations
- Always set timeouts for network requests
- Handle network failures gracefully with meaningful error messages
- Implement retry logic for transient failures
- Use connection pooling to reduce overhead
- Avoid blocking operations; prefer async where appropriate

### Performance Considerations
- Profile before optimizing; don't guess at bottlenecks
- Move expensive operations out of hot paths
- Pre-compile or cache expensive computations (regexes, parsers)
- Use concurrent operations where parallelism makes sense
- Consider memory allocations in performance-critical code

### Documentation
- Document public APIs with clear descriptions and examples
- Keep documentation close to code to ensure it stays updated
- Explain the "why" in comments, not just the "what"
- Document assumptions, invariants, and edge cases
- Update architectural documentation when making structural changes
</conditional-block>

<conditional-block context-check="dependencies" task-condition="choosing-external-library">
IF current task involves choosing an external library:
  IF Dependencies section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Dependencies guidelines already in context"
  ELSE:
    READ: The following guidelines
ELSE:
  SKIP: Dependencies section not relevant to current task

## Dependencies

### Choose Libraries Wisely
When adding third-party dependencies:
- Select the most popular and actively maintained option
- Check the library's GitHub repository for:
  - Recent commits (within last 6 months)
  - Active issue resolution
  - Number of stars/downloads
  - Clear documentation
</conditional-block>
