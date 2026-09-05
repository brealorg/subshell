# Public beta release checklist

A public beta is not created until all applicable gates are satisfied.

## Source and version

- [ ] Canonical Android `main` is clean.
- [ ] DEV lanes required for the release have landed.
- [ ] `versionName` is the intended public version.
- [ ] `versionCode` is greater than every previously distributed build.
- [ ] Stable application ID is `io.github.brealorg.subshell`.

## Qualification

- [ ] Release contracts pass according to the canonical baseline policy.
- [ ] Full unit suite passes.
- [ ] Release build succeeds.
- [ ] Kotlin compiler warnings meet the release gate.
- [ ] No DEV1/DEV2/debug identity leaks into the Stable artifact.
- [ ] No credentials or local signing material are packaged.

## Signing and APK identity

- [ ] APK is signed with the established release certificate.
- [ ] Package identity is verified from the final APK.
- [ ] Release certificate digest is verified.
- [ ] SHA-256 is calculated from the exact final APK.

## Runtime

- [ ] Clean Stable install is tested.
- [ ] Reddit account connection works with Stable identity.
- [ ] Core read flows are smoke-tested.
- [ ] Core write flows intended for the beta are smoke-tested.
- [ ] Upgrade from the previous public beta is tested when applicable.

## Publication

- [ ] Git tag matches `versionName`.
- [ ] GitHub Release is marked **Pre-release** for beta versions.
- [ ] APK asset uploaded.
- [ ] SHA-256 sidecar uploaded.
- [ ] Release record uploaded.
- [ ] Release notes include known limitations.
- [ ] Website download target points at the published release.
