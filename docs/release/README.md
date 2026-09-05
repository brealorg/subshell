# Public release model

GitHub Releases is the canonical distribution channel for public subshell
APK builds.

## Version scheme

Public pre-releases use semantic-style version names such as:

`0.77.0-beta.1`

Subsequent public beta builds increment both the human-visible beta
revision and Android `versionCode`.

A final build may later use:

`0.77.0`

## Release tag

Tags use a leading `v`:

`v0.77.0-beta.1`

## Canonical public assets

A public Android beta should normally contain:

- `Subshell-<version>.apk`
- `Subshell-<version>.apk.sha256`
- `Subshell-<version>-release-record.txt`

Only the Stable application identity is distributed publicly:

`io.github.brealorg.subshell`

DEV1 and DEV2 packages are never public release artifacts.

## Signing

Every public APK must use the established subshell release signing
identity.

A beta must be upgrade-compatible with subsequent public builds using
that same identity.

## Release preparation

The public repository also contains preparation material for Stable beta
builds:

- [`release-record-template.txt`](release-record-template.txt) defines the
  provenance record shipped alongside a public APK.
- [`runtime-smoke-matrix.md`](runtime-smoke-matrix.md) defines the final
  runtime verification performed against the exact signed Stable APK.
- [`../../tools/release/beta-release-preflight.sh`](../../tools/release/beta-release-preflight.sh)
  performs fail-closed source, build, APK identity, signing, and packaging
  qualification.

The preflight tool intentionally does **not** create tags, push Android
source, create a GitHub Release, or publish an APK. It requires the exact
final Android `main` SHA and established release-certificate SHA-256 to be
supplied explicitly.

For `0.77.0-beta.1`, a typical invocation after all required development
lanes have landed is:

```bash
tools/release/beta-release-preflight.sh \
  --android-root "$HOME/dev/subshell/subshell-repo" \
  --expected-main <FINAL_MAIN_SHA> \
  --version-name 0.77.0-beta.1 \
  --version-code <FINAL_VERSION_CODE> \
  --expected-cert-sha256 <ESTABLISHED_RELEASE_CERT_SHA256> \
  --contract-cmd './gradlew <canonical-release-contract-gate>'
```

The exact contract command and final version code are resolved from the
qualified Android release candidate; they are not guessed in advance.
