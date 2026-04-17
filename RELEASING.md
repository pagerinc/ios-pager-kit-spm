# Releasing `ios-pager-kit-spm`

This repo is a thin SwiftPM distribution wrapper around the PagerKit
xcframework that is built and published from
[`pagerinc/ios-pager-kit`](https://github.com/pagerinc/ios-pager-kit). It
exists so SwiftPM consumers can depend on PagerKit without cloning the
full development repo (example app, tests, Framework tooling, etc.).

Every time a new version of PagerKit is released from `ios-pager-kit`,
this repo needs a matching bump. The process is intentionally manual —
a handful of minutes per release, no CI secrets, no cron jobs. If that
ever becomes a real bottleneck, see the "Future automation" section at
the bottom.

---

## When to release

You should bump this repo whenever `ios-pager-kit` publishes a new
xcframework to JFrog (the `upload_framework_to_jfrog` fastlane lane).
The `version` in `Package.swift` here should always match the PagerKit
version number that was just published.

If the new PagerKit build links against a **new major version of
ZoomVideoSDK**, you may also need to bump the Zoom binary targets —
see "Updating Zoom" below.

---

## Release steps

### 1. Get the new version and checksum

The `upload_framework_to_jfrog` lane in `ios-pager-kit` prints a
ready-to-paste block at the end of its CI run:

```
===== ios-pager-kit-spm update =====
In ios-pager-kit-spm/Package.swift, set:
  let version  = "X.Y.Z"
  let checksum = "abc123..."
====================================
```

Grab those two values from the CI log for the release build.

If that lane hasn't run or you don't have access to the log, you can
compute the checksum manually:

```bash
curl -u "$JFROG_USER:$JFROG_API_KEY" -o PagerKit.zip \
  "https://pagerinc.jfrog.io/pagerinc/swift-release-local/PagerKit/PagerKit-X.Y.Z.xcframework.zip"
swift package compute-checksum PagerKit.zip
```

### 2. Update `Package.swift`

Edit the two constants near the top of `Package.swift`:

```swift
let version  = "X.Y.Z"          // new PagerKit version
let checksum = "abc123..."      // checksum from step 1
```

Nothing else in `Package.swift` should need changing for a normal
version bump. If PagerKit now builds against a new Zoom version, see
"Updating Zoom" below before committing.

### 3. Verify the package resolves

From the repo root:

```bash
rm -rf .build
swift package resolve
```

You should see SPM fetch the new PagerKit xcframework, the Zoom
binaries, and Pendo without error. If resolution fails, you have the
wrong checksum or the zip hasn't finished uploading to JFrog yet.

### 4. Open a PR

Branch protection on `master` requires a PR with two approvals.

```bash
git checkout -b release/X.Y.Z
git add Package.swift
git commit -m "Release X.Y.Z"
git push -u origin release/X.Y.Z
```

Open a PR titled `Release X.Y.Z` and get two approvals. Merge to
`master`.

### 5. Move the version tag

SwiftPM consumers resolve by tag, so the `X.Y.Z` tag must point at the
just-merged commit. If a tag with that name does not yet exist, create
it. If it does (as was the case during initial bring-up), delete and
recreate it:

```bash
git checkout master
git pull

# Delete the tag locally and remotely if it already exists
git tag -d X.Y.Z 2>/dev/null || true
git push origin :refs/tags/X.Y.Z 2>/dev/null || true

# Create and push the new tag
git tag X.Y.Z
git push origin X.Y.Z
```

After this, consumers declaring `.package(from: "X.Y.Z")` will resolve
the new release.

### 6. Smoke test

Point a test project at this repo at `X.Y.Z` and verify:

- SwiftPM resolves without error
- The app builds
- The app launches on a simulator without a `Library not loaded`
  dyld error — this is specifically the failure mode that
  misconfigured Zoom binary targets produce

If the app crashes on launch, read the "Zoom dyld dependencies" section
below.

---

## Updating Zoom

PagerKit links against `ZoomVideoSDK` at runtime, and `ZoomVideoSDK`
links against `ZoomTask`. Both are declared as direct `binaryTarget`s
in `Package.swift` (pinned to `v2.4.12` at time of writing). We do not
depend on Zoom's SwiftPM package because Zoom only ships SwiftPM
support on a branch, and SwiftPM forbids tagged/versioned packages
from depending on branch-based packages.

When PagerKit rebuilds against a new Zoom version, update:

1. `let zoomVersion = "vX.Y.Z"` in `Package.swift`
2. The `checksum:` value on the `ZoomVideoSDK` binary target
3. The `checksum:` value on the `ZoomTask` binary target

To compute Zoom checksums:

```bash
curl -L -o ZoomVideoSDK.zip \
  "https://github.com/zoom/videosdk-ios/releases/download/vX.Y.Z/ZoomVideoSDK.xcframework.zip"
swift package compute-checksum ZoomVideoSDK.zip

curl -L -o ZoomTask.zip \
  "https://github.com/zoom/videosdk-ios/releases/download/vX.Y.Z/ZoomTask.xcframework.zip"
swift package compute-checksum ZoomTask.zip
```

### Zoom dyld dependencies

If a future Zoom release adds new cross-framework dyld linkage, the
existing `ZoomVideoSDK + ZoomTask` pair may no longer be sufficient
and the app will crash on launch with:

```
dyld: Library not loaded: @rpath/<SomeFramework>.framework/<SomeFramework>
```

To diagnose, download the new `ZoomVideoSDK.xcframework.zip`, unzip,
and run:

```bash
otool -L ZoomVideoSDK.xcframework/ios-arm64_x86_64-simulator/ZoomVideoSDK.framework/ZoomVideoSDK | grep @rpath
```

Any `@rpath/<Name>.framework/<Name>` entry other than `ZoomVideoSDK`
itself must be added to `Package.swift` as a matching `binaryTarget`
(plus a dependency entry on `PagerKitWrapper`). Repeat transitively
for each new framework until the list is closed.

---

## Updating Pendo

Pendo is consumed as a normal versioned SwiftPM package dependency, so
there is usually nothing to do here — SwiftPM resolves the highest
compatible version per the `from: "3.9.1"` declaration. If a specific
Pendo pin ever becomes necessary, add a concrete version constraint in
the `dependencies:` block.

---

## Future automation

For today's release cadence, manual release is the cheapest option.
If the cadence picks up or a different team takes over releases, the
low-effort path forward would be:

- A GitHub Action in this repo triggered by a `repository_dispatch`
  webhook from `ios-pager-kit`'s release pipeline
- The webhook payload carries `version` and `checksum`
- The action opens the PR automatically

This avoids the pitfalls of a pull-based sync script (having to
re-download ~60 MB xcframeworks just to compute the checksum, and
maintaining JFrog credentials in two places).
