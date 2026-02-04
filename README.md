# iOS Development Plugin for Claude Code

Professional iOS development toolkit with VIP+W Clean Architecture, UIKit horizontal-first layouting, comprehensive code review, and performance optimization.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **VIP+W Clean Architecture** - View-Interactor-Presenter-Worker pattern with unidirectional data flow
- **Legacy Code Migration** - Step-by-step migration from spaghetti/MVC to VIP+W
- **UIKit Horizontal-First Layouting** - Mandatory ASCII previews before any UI code
- **Pure UIKit Patterns** - No SwiftUI bridging, delegate/closure-based state management
- **Interview-First Approach** - Structured requirements gathering before action using `AskUserQuestion`
- **9 Specialized Agents** - Architecture, migration, code review, performance, memory, security, testing, accessibility, App Store
- **7 Commands** - Build, test, review, lint, deploy, archive, migrate workflows
- **11 Skills** - Architecture, migration, layouting, patterns, performance, testing, security, concurrency, code review, interview patterns
- **7 Analysis Scripts** - Code quality, memory leaks, accessibility, legacy analysis

---

## Installation

### Step 1: Add the Marketplace

Open Claude Code and run:

```
/plugin marketplace add arimunandar/claude-code-ios-plugin
```

### Step 2: Install the Plugin

```
/plugin install ios-development
```

### Step 3: Verify Installation

```
/plugin list
```

---

### Alternative: Manual Installation

```bash
git clone https://github.com/arimunandar/claude-code-ios-plugin.git ~/.claude-plugins/ios-development
~/.claude-plugins/ios-development/install.sh --global
```

---

## Interview-First Behavior

All agents and key skills use a **structured interview approach** before taking action. This ensures Claude gathers proper context instead of making assumptions.

### How It Works

When you ask an agent to perform a task, it will first ask clarifying questions using the `AskUserQuestion` tool:

```
User: Create a product detail screen

Claude: Before I create this screen, let me understand your requirements:

[AskUserQuestion tool]
1. What's the main purpose? (Display data / Form input / Navigation hub / Settings)
2. What components needed? (Text labels, Buttons, Images, Lists)
3. Data source? (API / Local / User input / Multiple sources)
4. Navigation pattern? (Push to detail / Modal / Tab switching / Back only)

User: [Selects options]

Claude: Got it! I'll create a product detail screen with:
- Image gallery, title, price, description
- Buy button with purchase flow
- Data from your REST API
- Push navigation to checkout

[Shows ASCII preview]
[Then generates VIP+W code]
```

### Skip the Interview

If you want to skip questions, you can:

1. Say **"skip questions"** or **"just do it"** in your prompt
2. Provide **detailed specifications** upfront
3. Share **wireframes or designs** with exact requirements

### Agents with Interview Behavior

| Agent | Interview Focus |
|-------|-----------------|
| `uikit-architect` | Screen purpose, components, data source, navigation |
| `legacy-migrator` | Migration scope, pain points, test status, timeline |
| `ios-code-reviewer` | Review focus, severity threshold, code context |
| `performance-optimizer` | Symptoms, target area, performance goals |
| `memory-leak-detector` | Scan scope, known issues, closure patterns |
| `accessibility-auditor` | Audit scope, WCAG level, priority features |
| `ios-security-auditor` | Security focus, data types, compliance |
| `test-coverage-analyzer` | Analysis scope, test types, coverage target |
| `appstore-reviewer` | Review focus, submission timeline, app category |

---

## Quick Start

After installation, try these prompts to verify the plugin is working:

### Architecture (VIP+W)

| Prompt | Expected Behavior |
|--------|-------------------|
| "What architecture should I use for iOS?" | Recommends **VIP+W** (not MVVM, not VIPER) |
| "Create a Product detail screen" | Generates VIP+W structure with all 7 files |
| "How should I structure my iOS project?" | Explains VIP+W with Worker pattern |
| "Show me the data flow for a fetch request" | View → Interactor → Worker → Presenter → View |

### UIKit Layouting (Horizontal-First + ASCII)

| Prompt | Expected Behavior |
|--------|-------------------|
| "Create a login screen with email, password, and submit button" | Shows **ASCII preview FIRST**, then UIKit code |
| "Build a profile card with avatar, name, and bio" | ASCII diagram before any Swift code |
| "Design a settings row with icon, title, and chevron" | Horizontal slicing explanation + ASCII |
| "Layout a product cell with image, title, price, and buy button" | Row-by-row ASCII breakdown |

### Legacy Migration

| Prompt | Expected Behavior |
|--------|-------------------|
| "I have a massive ViewController with 800 lines" | Suggests VIP+W migration with phased plan |
| "How do I refactor this spaghetti code?" | Step-by-step extraction guide |
| "Migrate HomeViewController to clean architecture" | Worker → Presenter → Interactor → Router extraction |
| "Analyze my legacy codebase" | Runs analysis, prioritizes files for migration |

### Code Review

| Prompt | Expected Behavior |
|--------|-------------------|
| "Review this Swift file" | Comprehensive review with severity levels |
| "Check this code for best practices" | Architecture, memory, concurrency checks |
| "Is this code safe to merge?" | Blocker/warning/info categorization |

### Performance & Memory

| Prompt | Expected Behavior |
|--------|-------------------|
| "Check for memory leaks in this code" | Scans for retain cycles, weak self |
| "Is there a retain cycle here?" | Identifies closure capture issues |
| "Optimize this TableView" | Cell reuse, image caching, prefetching |
| "Why is my app slow?" | Main thread, collection, image analysis |

### Pure UIKit (No SwiftUI)

| Prompt | Expected Behavior |
|--------|-------------------|
| "How do I add a SwiftUI view?" | **Discourages SwiftUI**, suggests UIKit equivalent |
| "Should I use UIHostingController?" | **No** - use native UIKit |
| "What's the UIKit equivalent of @State?" | Delegate/closure patterns |

---

## Architecture: VIP+W Clean Architecture

```
View → Interactor → Worker → Interactor → Presenter → View
```

| Component | Responsibility | Protocol |
|-----------|---------------|----------|
| **View** (ViewController) | Display logic only | `DisplayLogic` |
| **Interactor** | Business logic orchestration | `BusinessLogic` |
| **Presenter** | Format data for display | `PresentationLogic` |
| **Worker** | Async operations (API, DB) | `WorkerLogic` |
| **Router** | Navigation between scenes | `RoutingLogic` |

---

## Legacy Code Migration

Refactor spaghetti/MVC code to VIP+W Clean Architecture:

```bash
# Analyze legacy codebase
~/.claude-plugins/ios-development/scripts/analyze-legacy.sh /path/to/project

# Or use the command
/migrate-legacy
```

**Migration Process:**
1. **Analyze** - Identify files needing migration
2. **Document** - Capture current behavior
3. **Test** - Write characterization tests
4. **Extract** - Worker → Presenter → Interactor → Router
5. **Verify** - Ensure tests pass
6. **Clean** - Remove legacy code

See `skills/legacy-migration/SKILL.md` for detailed guide.

---

## Agents

| Agent | Purpose | Model |
|-------|---------|-------|
| `uikit-architect` | VIP+W architecture, horizontal-first layouting | sonnet |
| `legacy-migrator` | Analyze and migrate legacy code to VIP+W | opus |
| `ios-code-reviewer` | Swift best practices, SOLID principles | opus |
| `performance-optimizer` | Performance analysis and optimization | opus |
| `memory-leak-detector` | Retain cycles and memory issues | sonnet |
| `accessibility-auditor` | VoiceOver, Dynamic Type, WCAG compliance | sonnet |
| `ios-security-auditor` | Keychain, encryption, OWASP Mobile Top 10 | opus |
| `test-coverage-analyzer` | Test gaps, coverage analysis | sonnet |
| `appstore-reviewer` | App Store guidelines, privacy manifests | sonnet |

---

## Skills

| Skill | Topics |
|-------|--------|
| `vip-architecture` | VIP+W components, protocols, data flow, code templates |
| `legacy-migration` | Step-by-step migration from MVC/spaghetti to VIP+W |
| `uikit-layouting` | Horizontal-first slicing, ASCII preview, constraints |
| `uikit-patterns` | Pure UIKit state management, delegates, closures |
| `ios-performance` | Memory management, profiling, optimization, Instruments |
| `ios-testing` | Unit tests, UI tests, TDD, mocking for VIP+W |
| `code-review-checklist` | Comprehensive review guidelines for iOS/Swift |
| `ios-security` | Keychain, biometrics, data protection, App Attest |
| `swift-concurrency` | async/await, actors, TaskGroup, Sendable |
| `swiftui-patterns` | Reference only (not for new code) |
| `interview-patterns` | Requirements gathering, AskUserQuestion best practices |

---

## Commands

| Command | Description |
|---------|-------------|
| `/ios-build` | Build for simulator or device |
| `/ios-test` | Run unit and UI tests |
| `/ios-review` | Comprehensive code review with agents |
| `/ios-lint` | Run SwiftLint with fix suggestions |
| `/ios-deploy` | Deploy to simulator or device |
| `/ios-archive` | Archive for App Store distribution |
| `/migrate-legacy` | Analyze legacy code and create migration plan |

---

## Analysis Scripts

Run these from your project directory:

```bash
# Legacy code analysis for migration
~/.claude-plugins/ios-development/scripts/analyze-legacy.sh .

# Code quality analysis
~/.claude-plugins/ios-development/scripts/analyze-code-quality.sh .

# Memory leak detection
~/.claude-plugins/ios-development/scripts/check-memory-leaks.sh .

# Accessibility audit
~/.claude-plugins/ios-development/scripts/check-accessibility.sh .
```

---

## Code Review Features

### Comprehensive Review Checklist

The plugin includes detailed review guidelines covering:

- **Architecture Compliance** - VIP+W pattern verification
- **Memory Management** - Retain cycles, weak references
- **Concurrency** - Thread safety, main thread UI
- **Error Handling** - Proper error propagation
- **Optionals & Safety** - No force unwraps
- **Naming Conventions** - Swift guidelines
- **Performance** - Collection operations, image handling
- **Security** - Sensitive data, HTTPS
- **Testing** - Coverage and quality

### Review Comment Severity

| Level | Icon | Meaning |
|-------|------|---------|
| Blocker | 🔴 | Must fix before merge |
| Warning | 🟡 | Should fix |
| Info | 🔵 | Discussion/question |
| Praise | 🟢 | Good work |

---

## Performance Features

### Memory Leak Detection

Automatically detects:
- Closures without `[weak self]`
- Strong delegate references
- Timer retain cycles
- NotificationCenter leaks
- Circular references

### Performance Analysis

Scans for:
- Main thread blocking
- Inefficient collection operations
- Large image handling
- UI hierarchy complexity

---

## Pure UIKit Policy

| ❌ DO NOT USE | ✅ USE INSTEAD |
|---------------|----------------|
| `UIHostingController` | Native UIKit controllers |
| `UIViewRepresentable` | UIKit components directly |
| `@Observable` | Delegate/closure patterns |
| SwiftUI views | `UIStackView` for layout |

---

## Requirements

- Claude Code CLI
- Xcode 16.0+ (for Swift 6 features)
- SwiftLint (optional)
- Xcode MCP server (optional)

---

## Updating

```
/plugin update ios-development
```

Or:

```bash
cd ~/.claude-plugins/ios-development && git pull
```

---

## Team Setup

```
/plugin marketplace add arimunandar/claude-code-ios-plugin
/plugin install ios-development
```

All team members get consistent:
- VIP+W architecture enforcement
- Code review standards
- Performance guidelines
- Memory management checks

---

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing`)
5. Open Pull Request

## License

MIT License - see [LICENSE](LICENSE)

---

## Author

**Ari Munandar**
- Email: arimunandar.dev@gmail.com
- GitHub: [@arimunandar](https://github.com/arimunandar)
