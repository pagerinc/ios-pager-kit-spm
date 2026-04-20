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

> **The `chmod 600` is not optional.** `curl`, `git`, and Swift Package
> Manager all refuse to read a `.netrc` that is readable by other users
> on the system — they will silently fall back to unauthenticated
> requests and you will get a `401` on every resolve, with no hint
> anywhere that `.netrc` is the culprit. If you see a `401` from JFrog,
> check the permissions first.

> Contact your team lead or IT for JFrog credentials if you don't have them.

### Xcode vs Swift Package Manager CLI — known gotcha

On a fresh environment where SwiftPM's shared cache is empty, you may
hit a `badResponseStatusCode(401)` error when Xcode (or `xcodebuild
-resolvePackageDependencies`) tries to download the PagerKit
xcframework — **even when your `~/.netrc` is correctly configured**.

This is because `xcodebuild` does not honor `~/.netrc` for binary
target authentication the way the `swift package` CLI does. It's an
Xcode limitation that affects every SwiftPM package with authenticated
binary targets (ours, private Firebase distributions, etc.), not
something specific to this package.

**Workaround:** from a clone of this repo, run:

```bash
swift package resolve
```

The Swift CLI does honor `.netrc`, so it will successfully download and
cache the xcframework in SwiftPM's shared cache (`~/Library/Caches/
org.swift.swiftpm/`). Once cached, Xcode's subsequent resolve picks it
up from the shared cache without needing to re-authenticate.

You only need to do this once per machine (or any time the cache is
cleared).

## Requirements

- iOS 15.0+
- Swift 5.7+
- Xcode 14.0+
