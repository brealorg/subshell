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
