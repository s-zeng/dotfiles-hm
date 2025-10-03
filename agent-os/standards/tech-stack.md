# Tech Stack

## Core Language

### Rust
- **Version**: Modern stable Rust (2024 edition)
- **Purpose**: Core language for type-safe, performant CLI application
- **Features**: Strong type system, ownership model, zero-cost abstractions

## Runtime & Async

### Tokio
- **Purpose**: Async runtime with full feature set
- **Usage**: Powers all async operations including HTTP requests and concurrent source fetching
- **Features**: Multi-threaded runtime, async I/O, timers

### Futures
- **Purpose**: Additional async utilities
- **Usage**: `join_all()` for concurrent operations, stream processing

## CLI & Configuration

### Clap
- **Purpose**: Command-line argument parsing
- **Approach**: Derive macros for declarative CLI definition
- **Features**: Subcommands, flags, argument validation

### Serde & Serde JSON
- **Purpose**: Serialization/deserialization
- **Usage**:
  - Configuration file parsing (JSON)
  - AST export/import
  - Snapshot testing data structures

## Development & Testing

### Insta
- **Purpose**: Snapshot testing framework
- **Approach**: Deterministic test assertions with literal value snapshots
- **Strategy**:
  - Single assertion per test
  - Dual-snapshot pattern for network-dependent tests
  - Offline-resilient test suite
- **Commands**: `cargo insta review`, `cargo insta accept`

### Nix
- **Purpose**: Reproducible development environment
- **Features**: `flake.nix` provides all dependencies (OpenSSL, libiconv, pkg-config)
- **Usage**: `nix develop` for consistent dev shell. But as an agent, you are always running within a nix shell

### Just
- **Purpose**: Command runner (Make alternative)
- **Usage**: Development tasks (`just run`, `just watch`, `just fmt`)

### Treefmt
- **Purpose**: Code formatting
- **Usage**: Integrated via `just fmt`

### Cargo Watch
- **Purpose**: Auto-recompile on file changes
- **Usage**: `just watch` for rapid development

## Build & Deployment

### Cargo
- **Purpose**: Rust package manager and build system
- **Features**: Dependency management, build orchestration, test runner
