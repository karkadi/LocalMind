![Platform](https://img.shields.io/badge/Platform-iOS-blue) 
![Platform](https://img.shields.io/badge/Platform-iPadOs-blue) 
![Platform](https://img.shields.io/badge/Platform-macOS-blue) 
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![Architecture](https://img.shields.io/badge/Architecture-TCA-purple)
![Async/Await](https://img.shields.io/badge/Concurrency-Async%2FAwait-green)

# LocalMind

A SwiftUI app that allows you to chat with Apple Intelligence using the new [Foundation Models Framework](https://developer.apple.com/documentation/foundationmodels) and Liquid Glass UI on iOS 26+, built with The Composable Architecture (TCA).

## 📱 Screenshots

<div align="center">
  <img src="./ScreenShoots/light.png" width="80%" /> <br/>
  <img src="./ScreenShoots/dark.png" width="80%" /> <br/>
  <img src="./ScreenShoots/macos.png" width="80%" />
</div>

## Features

- **Offline AI Chat**: Chat with the Apple Intelligence model directly on device using Swift 6.0 async/await
- **Streaming Responses**: Real-time streaming text generation with haptic feedback
- **Modern Glass UI**: Liquid Glass UI design with interactive glass effects
- **TCA Architecture**: Built with The Composable Architecture for predictable state management
- **Mathematical Formula Support**: LaTeX rendering for complex mathematical expressions
- **Persistent Conversations**: SQLite data storage for message history and discussions
- **Cross-Device Sync**: **iCloud synchronization** keeps your conversations up to date across all your Apple devices
- **Smart Search**: **Search through conversation history** to quickly find specific topics, messages, or information
- **Customizable Settings**: Adjust temperature, system instructions, and streaming preferences
- **Multi-Platform Support**: Native iOS, iPadOS, and macOS experiences

## Architecture

LocalMind is built using **The Composable Architecture (TCA)** with Swift 6.0's enhanced concurrency features

## Technical Highlights

### Swift 6.0 Async/Await
- Full adoption of Swift 6.0's strict concurrency checking
- Structured concurrency for reliable async operations
- Async streams for real-time message streaming

### The Composable Architecture (TCA)
- Predictable state management
- Testable business logic
- Modular feature composition
- Side effect management

### LaTeX Formula Decoding
- Render mathematical expressions using LaTeX
- Support for complex equations and scientific notation
- Seamless integration with chat messages

### Cross-Device Synchronization
- **iCloud sync** automatically keeps your conversations synchronized across iPhone, iPad, and Mac
- Real-time updates when switching between devices
- Conflict resolution for seamless multi-device usage

### Intelligent Search
- **Full-text search** through entire conversation history
- Instant results with relevant context highlighting
- Search across multiple conversations simultaneously
- Optimized performance for large message databases

### SQLite Data Persistence
```swift
// Async database operations with iCloud sync
@Dependency(\.databaseClient) var databaseClient

func createSession(_ session: ChatSession) async throws {
    try await databaseClient.createSession(session)
}

func fetchAllSessions() async throws -> [ChatSession] {
    try await databaseClient.fetchAllSessions()
}

// Search through conversation history
func searchMessages(query: String) async throws -> [Message] {
    try await databaseClient.searchMessages(query: query)
}
```

## Requirements

- iOS/iPadOS/macOS 26.0+
- Device with Apple Intelligence support
- Xcode 26.0 beta or newer
- Swift 6.0
- iCloud account for cross-device synchronization

## Installation

1. Clone the repository:

```bash
git clone https://github.com/karkadi/LocalMind.git
```

2. Open the project in Xcode:

```bash
cd LocalMind
open LocalMind.xcodeproj
```

3. Select a development team with iCloud capabilities, then run on a compatible device or simulator

4. Install dependencies (if using Swift Package Manager):

The project includes dependencies for TCA, SQLite, and LaTeX rendering which will be automatically resolved by Xcode.

## Project Structure

```
LocalMind/
├── Sources/
│   ├── App/                           # App entry point and configuration
│   ├── Core/                          # Core application components
│   │   ├── Models/                    # Data models and entities
│   │   ├── Services/                  # Business logic services
│   │   │   ├── ChatClient.swift       # AI chat functionality
│   │   │   ├── DatabaseClient.swift   # SQLite persistence with iCloud sync
│   │   │   └── DeviceInfoClient.swift # Device Info
│   │   └── Utils/                     # Utilities and helpers
│   ├── Features/                      # Feature modules
│   │   ├── Root/                      # Root feature coordinator
│   │   ├── Chat/                      # Main chat interface
│   │   │   ├── Settings/              # Chat settings and preferences
│   │   │   └── Components/            # Chat-specific UI components
│   │   └── SideBar/                   # Navigation sidebar
│   │       ├── RenameDialog/          # Conversation management
│   │       └── Components/            # SideBar-specific UI components
│   │   
│   └── Resources/
│       └── Assets.xcassets/
│           ├── AccentColor.colorset
│           └── AppIcon.appiconset
│
└── Tests/                             # Unit and integration tests
     ├── LocalMindTests
     └── LocalMindUITests 
```

### Directory Overview

- **App**: Application lifecycle and main app structure
- **Core**: Foundation layer containing models, services, and utilities
- **Features**: Feature modules following TCA principles, each with:
  - Reducer (state management)
  - View (SwiftUI presentation)
  - Dependencies (service integration)
- **SharedUI**: Cross-platform UI components and modifiers
- **Resources**: Assets, colors, and app icons

## Usage

1. **First Launch**: Ensure Apple Intelligence is enabled in System Settings and sign in to iCloud for cross-device sync
2. **Start Chatting**: Launch the app - conversations are automatically persisted and synchronized via iCloud
3. **Search Conversations**: Use the search bar in the sidebar to **find specific messages or topics** across your entire conversation history
4. **Multi-Device Experience**: Continue conversations seamlessly across iPhone, iPad, and Mac with automatic **iCloud synchronization**
5. **Mathematical Expressions**: Use LaTeX syntax for formulas: `$E = mc^2$` or `$$\int_a^b f(x)dx$$`
6. **Customize Experience**: Access Settings to:
   - Toggle streaming responses with haptic feedback
   - Adjust temperature (0.0 - 2.0) for response creativity
   - Modify system instructions and behavior
   - Manage conversation history and search preferences
   - Monitor iCloud sync status
   - Clear cached data

## Database Schema & Synchronization

LocalMind uses SQLite with Swift 6.0 async/await enhanced with:
- **iCloud synchronization** for cross-device data consistency
- **Full-text search indexing** for fast conversation history search
- Message history with timestamps and conversation context
- Conversation metadata and organization
- User preferences and app settings
- Cached LaTeX renderings for performance

## TODO / Roadmap

- [ ] Adding Unit Tests
- [ ] Export conversations as PDF with LaTeX support
- [ ] Conversation folders and organization
- [ ] Voice input and output
- [ ] Image analysis and discussion
- [ ] Code syntax highlighting
- [ ] Siri shortcuts integration

## License

This project is available under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. When contributing, ensure:

## Acknowledgments

LocalMind is built upon several excellent open-source projects and frameworks:

### Core Dependencies
- **[Swift Composable Architecture](https://swiftpackageindex.com/pointfreeco/swift-composable-architecture)** - The foundational architecture pattern that enables predictable state management and testable business logic
- **[LaTeXSwiftUI](https://swiftpackageindex.com/colinc86/LaTeXSwiftUI)** - Powerful LaTeX rendering capabilities that bring mathematical expressions to life in our chat interface
- **[SQLite Data](https://swiftpackageindex.com/pointfreeco/sqlite-data)** - Robust SQLite integration with Swift 6.0 async/await support for reliable data persistence and search capabilities

### Apple Frameworks
- **Foundation Models Framework** - Apple's on-device AI capabilities that power our chat experience
- **SwiftUI** - Modern declarative UI framework with Liquid Glass design system
- **Swift 6.0** - Next-generation Swift with advanced concurrency features
- **CloudKit** - iCloud synchronization infrastructure for cross-device experiences

### Inspiration
- The open-source community for continuous innovation in Swift development
- Apple's Human Interface Guidelines for creating intuitive multi-platform experiences
- Modern AI assistants for inspiring conversational interfaces and search capabilities

We extend our gratitude to the maintainers and contributors of these projects for their excellent work that makes LocalMind possible.

---

Built with ❤️ using Swift 6.0, TCA, and Apple's latest technologies.
