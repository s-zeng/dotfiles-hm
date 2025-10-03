## Rust-Specific Style

### Functional Orientation
- Write Rust in a functional style: "OCaml with manual garbage collection"
- Prefer iterators and combinators (`.map()`, `.filter()`, `.and_then()`) over imperative loops
- Use algebraic data types (`enum`) liberally to model domain concepts
- Design trait-based abstractions with an algebra-oriented mindset

### Type-Driven Design
- Use Rust's type system to enforce invariants at compile time
- Leverage the type system to make illegal states unrepresentable
- Define custom types (newtypes, enums) instead of using primitives directly
- Use traits to define interfaces and enable polymorphism

### Pattern Matching
- Use `match` expressions over `if let` when handling multiple variants
- Prefer exhaustive matching; avoid catch-all patterns unless necessary
- Destructure complex types inline in match arms
- Use guards (`if` conditions) in match arms for additional constraints

### Module Structure
- Keep modules focused on specific domain concepts
- Use `mod.rs` or single-file modules based on complexity
- Re-export public APIs through parent modules
- Prefer explicit imports over glob imports (`use foo::*`)

### Error Handling Style
- Use `Result` and `Option` types exclusively; never panic in production
- Chain error handling operations using `?`, `.map()`, `.and_then()`
- Return errors rather than handling them at every call site
- Let errors bubble up to natural handling boundaries

### Expression-Oriented Idioms
- Leverage Rust's expression-oriented syntax:
  ```rust
  let value = if condition {
      compute_a()
  } else {
      compute_b()
  };
  ```
- Use `match` as an expression to return values
- Prefer single-expression function bodies when possible

### Iterator Chains
- Favor iterator chains over explicit loops:
  ```rust
  // Prefer this
  items.iter()
      .filter(|x| x.is_valid())
      .map(|x| x.process())
      .collect()

  // Over this
  let mut results = Vec::new();
  for item in &items {
      if item.is_valid() {
          results.push(item.process());
      }
  }
  ```

### Builder Patterns
- Use method chaining for configuration and construction
- Leverage Rust's ownership system to prevent misuse of builders
- Return `Self` from builder methods for fluent APIs

### Trait Implementation
- Implement traits to integrate with Rust ecosystem patterns
- Derive standard traits when possible (`Debug`, `Clone`, `Default`)
- Use trait objects (`dyn Trait`) for runtime polymorphism when needed
- Prefer static dispatch (generics) over dynamic dispatch for performance
