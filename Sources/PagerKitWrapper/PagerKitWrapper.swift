// This file is intentionally (almost) empty.
//
// The `PagerKitWrapper` target exists only so that SwiftPM has something
// to hang transitive linkage off. Declaring the library product with the
// wrapper as its target, and listing ZoomVideoSDK, ZoomTask, and Pendo
// as the wrapper's dependencies, forces all of those frameworks to be
// linked into any app that depends on the `PagerKit` library product.
//
// Consumers write `import PagerKit` — that resolves to the binary target
// `PagerKitBinary`'s internal module (named `PagerKit` inside the
// xcframework), not to this wrapper. There is no public API in this
// wrapper target; it is pure plumbing.
