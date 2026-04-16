# Pager iOS SDK (SPM)

Swift Package Manager distribution for [PagerKit](https://github.com/pagerinc/ios-pager-kit).

## Installation

### Swift Package Manager (Xcode)

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/pagerinc/ios-pager-kit-spm.git
   ```
3. Select a version rule (e.g. **Up to Next Major** from `4.3.0`)
4. Add `PagerKit` to your target

### Swift Package Manager (Package.swift)

```swift
dependencies: [
    .package(url: "https://github.com/pagerinc/ios-pager-kit-spm.git", from: "4.3.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "PagerKit", package: "ios-pager-kit-spm"),
        ]
    ),
]
```

### Usage

```swift
import PagerKit
```

## JFrog Authentication (.netrc)

PagerKit's xcframework is hosted on JFrog. SPM needs credentials to download it.

Add the following to `~/.netrc`:

```
machine pagerinc.jfrog.io
login <JFROG_USER>
password <JFROG_API_KEY>
```

Then set permissions:

```bash
chmod 600 ~/.netrc
```

> Contact your team lead or IT for JFrog credentials if you don't have them.

## Requirements

- iOS 15.0+
- Swift 5.7+
- Xcode 14.0+
