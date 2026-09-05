#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

PACKAGE_ID='io.github.brealorg.subshell'

ANDROID_ROOT=''
EXPECTED_MAIN=''
VERSION_NAME=''
VERSION_CODE=''
EXPECTED_CERT_SHA256=''
CONTRACT_CMD=''
UNIT_CMD='./gradlew test'
BUILD_CMD='./gradlew assembleRelease'
APK_PATH='app/build/outputs/apk/release/app-release.apk'
VERSION_FILE='app/build.gradle.kts'
OUT_DIR=''

usage() {
    cat <<'USAGE'
Subshell Stable public beta preflight

Qualifies and packages an already-selected Android main candidate.
It does NOT create a git tag, push Android source, create a GitHub Release,
or publish anything.

Required:
  --android-root PATH
  --expected-main SHA
  --version-name VERSION
  --version-code INTEGER
  --expected-cert-sha256 SHA256
  --contract-cmd COMMAND

Optional:
  --unit-cmd COMMAND
  --build-cmd COMMAND
  --apk-path PATH
  --version-file PATH
  --out-dir PATH
USAGE
}

stop() {
    echo
    echo "STOP=$1"
    echo 'PUBLICATION=NO'
    echo 'GIT_TAG=NO'
    echo 'GIT_PUSH=NO'
    echo 'GITHUB_RELEASE=NO'
    exit 1
}

normalize_hex() {
    printf '%s' "$1" |
        tr -d ':[:space:]' |
        tr '[:lower:]' '[:upper:]'
}

find_sdk_tool() {
    local name="$1"
    local sdk found

    if command -v "$name" >/dev/null 2>&1; then
        command -v "$name"
        return 0
    fi

    for sdk in \
        "${ANDROID_SDK_ROOT:-}" \
        "${ANDROID_HOME:-}" \
        "$HOME/Android/Sdk"
    do
        [[ -n "$sdk" && -d "$sdk/build-tools" ]] || continue

        found="$(
            find "$sdk/build-tools" \
                -mindepth 2 \
                -maxdepth 2 \
                -type f \
                -name "$name" \
                -print 2>/dev/null |
            sort -V |
            tail -n1
        )"

        if [[ -n "$found" ]]; then
            printf '%s\n' "$found"
            return 0
        fi
    done

    return 1
}

run_gate() {
    local name="$1"
    local cmd="$2"
    local log="$3"
    local rc

    echo
    echo "===== GATE: $name ====="
    echo "COMMAND=$cmd"

    set +e
    (
        cd "$ANDROID_ROOT"
        bash -c "$cmd"
    ) 2>&1 | tee "$log"
    rc=${PIPESTATUS[0]}
    set -e

    echo "GATE_RC=$rc"
    [[ "$rc" -eq 0 ]] || stop "${name}_FAILED"
    echo "PASS=$name"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --android-root) ANDROID_ROOT="${2:-}"; shift 2 ;;
        --expected-main) EXPECTED_MAIN="${2:-}"; shift 2 ;;
        --version-name) VERSION_NAME="${2:-}"; shift 2 ;;
        --version-code) VERSION_CODE="${2:-}"; shift 2 ;;
        --expected-cert-sha256) EXPECTED_CERT_SHA256="${2:-}"; shift 2 ;;
        --contract-cmd) CONTRACT_CMD="${2:-}"; shift 2 ;;
        --unit-cmd) UNIT_CMD="${2:-}"; shift 2 ;;
        --build-cmd) BUILD_CMD="${2:-}"; shift 2 ;;
        --apk-path) APK_PATH="${2:-}"; shift 2 ;;
        --version-file) VERSION_FILE="${2:-}"; shift 2 ;;
        --out-dir) OUT_DIR="${2:-}"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

for cmd in git python3 sha256sum unzip grep sed awk stat tee; do
    command -v "$cmd" >/dev/null 2>&1 || stop "REQUIRED_COMMAND_MISSING:$cmd"
done

[[ -n "$ANDROID_ROOT" ]] || stop ANDROID_ROOT_REQUIRED
[[ -d "$ANDROID_ROOT/.git" ]] || stop ANDROID_ROOT_NOT_GIT_REPOSITORY
[[ "$EXPECTED_MAIN" =~ ^[0-9a-f]{40}$ ]] || stop EXPECTED_MAIN_MUST_BE_FULL_SHA
[[ -n "$VERSION_NAME" ]] || stop VERSION_NAME_REQUIRED
[[ "$VERSION_CODE" =~ ^[0-9]+$ ]] || stop VERSION_CODE_MUST_BE_INTEGER
[[ -n "$CONTRACT_CMD" ]] || stop CONTRACT_CMD_REQUIRED

EXPECTED_CERT_NORMALIZED="$(normalize_hex "$EXPECTED_CERT_SHA256")"
[[ "$EXPECTED_CERT_NORMALIZED" =~ ^[0-9A-F]{64}$ ]] || stop EXPECTED_CERT_SHA256_INVALID

[[ "$VERSION_FILE" == /* ]] || VERSION_FILE="$ANDROID_ROOT/$VERSION_FILE"
[[ "$APK_PATH" == /* ]] || APK_PATH="$ANDROID_ROOT/$APK_PATH"
[[ -f "$VERSION_FILE" ]] || stop VERSION_FILE_MISSING

if [[ -z "$OUT_DIR" ]]; then
    OUT_DIR="$HOME/Downloads/subshell-${VERSION_NAME}-preflight-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "$OUT_DIR"

MASTER_LOG="$OUT_DIR/preflight.log"
exec > >(tee "$MASTER_LOG") 2>&1

echo 'APPROVED_OPERATION=SUBSHELL_PUBLIC_BETA_PREFLIGHT'
echo 'RISK=R1_LOCAL_READ_BUILD_AND_RELEASE_ARTIFACT_PREPARATION_NO_PUBLICATION'
echo "ANDROID_ROOT=$ANDROID_ROOT"
echo "EXPECTED_MAIN=$EXPECTED_MAIN"
echo "VERSION_NAME=$VERSION_NAME"
echo "VERSION_CODE=$VERSION_CODE"
echo "PACKAGE_ID=$PACKAGE_ID"
echo 'ANDROID_SOURCE_MUTATION=NO'
echo 'GIT_COMMIT=NO'
echo 'GIT_TAG=NO'
echo 'GIT_PUSH=NO'
echo 'GITHUB_RELEASE=NO'
echo 'PUBLICATION=NO'

echo
echo '===== 1/9 SOURCE IDENTITY ====='
BRANCH="$(git -C "$ANDROID_ROOT" branch --show-current)"
HEAD="$(git -C "$ANDROID_ROOT" rev-parse HEAD)"
TREE="$(git -C "$ANDROID_ROOT" rev-parse HEAD^{tree})"
echo "BRANCH=$BRANCH"
echo "HEAD=$HEAD"
echo "TREE=$TREE"
[[ "$BRANCH" == main ]] || stop ANDROID_NOT_ON_MAIN
[[ "$HEAD" == "$EXPECTED_MAIN" ]] || stop ANDROID_MAIN_SHA_CHANGED
[[ -z "$(git -C "$ANDROID_ROOT" status --porcelain=v1)" ]] || stop ANDROID_MAIN_DIRTY
echo 'PASS=ANDROID_MAIN_IDENTITY'

echo
echo '===== 2/9 SOURCE VERSION CONTRACT ====='
python3 - "$VERSION_FILE" "$VERSION_NAME" "$VERSION_CODE" "$PACKAGE_ID" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
version_name, version_code, package_id = sys.argv[2:]
text = path.read_text(encoding="utf-8")

checks = {
    "versionName": rf'\bversionName\s*=\s*"{re.escape(version_name)}"',
    "versionCode": rf'\bversionCode\s*=\s*{re.escape(version_code)}\b',
    "applicationId": rf'\bapplicationId\s*=\s*"{re.escape(package_id)}"',
}
missing = [name for name, pattern in checks.items() if re.search(pattern, text) is None]
if missing:
    raise SystemExit("STOP=SOURCE_VERSION_CONTRACT_MISSING:" + ",".join(missing))
print("PASS=SOURCE_VERSION_NAME")
print("PASS=SOURCE_VERSION_CODE")
print("PASS=SOURCE_APPLICATION_ID")
PY

echo
echo '===== 3/9 RELEASE CONTRACT GATE ====='
CONTRACT_LOG="$OUT_DIR/contract-gate.log"
run_gate RELEASE_CONTRACT_GATE "$CONTRACT_CMD" "$CONTRACT_LOG"

echo
echo '===== 4/9 FULL UNIT GATE ====='
UNIT_LOG="$OUT_DIR/unit-gate.log"
run_gate FULL_UNIT_GATE "$UNIT_CMD" "$UNIT_LOG"

echo
echo '===== 5/9 RELEASE BUILD GATE ====='
BUILD_LOG="$OUT_DIR/release-build.log"
run_gate RELEASE_BUILD_GATE "$BUILD_CMD" "$BUILD_LOG"

echo
echo '===== 6/9 WARNING + SOURCE STABILITY ====='
WARNING_MATCHES="$OUT_DIR/kotlin-warning-matches.txt"
set +e
grep -Ein \
    '(^|[[:space:]])w:[[:space:]].*\.kt([:(]|$)|(^|[[:space:]])warning:[[:space:]].*kotlin' \
    "$CONTRACT_LOG" "$UNIT_LOG" "$BUILD_LOG" > "$WARNING_MATCHES"
WARN_RC=$?
set -e
if [[ "$WARN_RC" -eq 0 ]]; then
    cat "$WARNING_MATCHES"
    stop KOTLIN_COMPILER_WARNINGS_FOUND
fi
[[ "$WARN_RC" -eq 1 ]] || stop KOTLIN_WARNING_SCAN_FAILED
rm -f "$WARNING_MATCHES"
[[ "$(git -C "$ANDROID_ROOT" rev-parse HEAD)" == "$EXPECTED_MAIN" ]] || stop ANDROID_HEAD_CHANGED_DURING_PREFLIGHT
[[ -z "$(git -C "$ANDROID_ROOT" status --porcelain=v1)" ]] || stop ANDROID_SOURCE_CHANGED_DURING_PREFLIGHT
echo 'PASS=KOTLIN_COMPILER_WARNINGS_NONE'
echo 'PASS=ANDROID_SOURCE_REMAINS_CLEAN'

echo
echo '===== 7/9 APK IDENTITY + SIGNATURE ====='
[[ -f "$APK_PATH" ]] || stop FINAL_APK_MISSING
AAPT="$(find_sdk_tool aapt || true)"
APKSIGNER="$(find_sdk_tool apksigner || true)"
[[ -n "$AAPT" ]] || stop AAPT_NOT_FOUND
[[ -n "$APKSIGNER" ]] || stop APKSIGNER_NOT_FOUND
BADGING="$OUT_DIR/apk-badging.txt"
"$AAPT" dump badging "$APK_PATH" | tee "$BADGING"
PACKAGE_LINE="$(grep -m1 '^package:' "$BADGING" || true)"
ACTUAL_PACKAGE="$(printf '%s\n' "$PACKAGE_LINE" | sed -n "s/^package: name='\([^']*\)'.*/\1/p")"
ACTUAL_VERSION_CODE="$(printf '%s\n' "$PACKAGE_LINE" | sed -n "s/^package:.*versionCode='\([^']*\)'.*/\1/p")"
ACTUAL_VERSION_NAME="$(printf '%s\n' "$PACKAGE_LINE" | sed -n "s/^package:.*versionName='\([^']*\)'.*/\1/p")"
[[ "$ACTUAL_PACKAGE" == "$PACKAGE_ID" ]] || stop APK_PACKAGE_ID_MISMATCH
[[ "$ACTUAL_VERSION_CODE" == "$VERSION_CODE" ]] || stop APK_VERSION_CODE_MISMATCH
[[ "$ACTUAL_VERSION_NAME" == "$VERSION_NAME" ]] || stop APK_VERSION_NAME_MISMATCH
CERT_LOG="$OUT_DIR/apk-signature.txt"
"$APKSIGNER" verify --verbose --print-certs "$APK_PATH" | tee "$CERT_LOG"
ACTUAL_CERT="$(
    grep -m1 'Signer #1 certificate SHA-256 digest:' "$CERT_LOG" |
    sed 's/^.*digest:[[:space:]]*//' |
    tr -d ':[:space:]' |
    tr '[:lower:]' '[:upper:]'
)"
[[ "$ACTUAL_CERT" =~ ^[0-9A-F]{64}$ ]] || stop APK_CERT_SHA256_NOT_RESOLVED
[[ "$ACTUAL_CERT" == "$EXPECTED_CERT_NORMALIZED" ]] || stop APK_RELEASE_CERT_MISMATCH
echo "APK_RELEASE_CERT_SHA256=$ACTUAL_CERT"
echo 'PASS=APK_IDENTITY_AND_RELEASE_CERTIFICATE'

echo
echo '===== 8/9 APK LEAK GATE ====='
TMP="$(mktemp -d /tmp/subshell-beta-apk-check.XXXXXX)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT
mkdir -p "$TMP/apk"
unzip -qq "$APK_PATH" -d "$TMP/apk"
for forbidden in \
    'io.github.brealorg.subshell.debug.dev1' \
    'io.github.brealorg.subshell.debug.dev2' \
    'app.subshell.prototype'
do
    if grep -R -a -F -q -- "$forbidden" "$TMP/apk"; then
        echo "FORBIDDEN_IDENTITY=$forbidden"
        stop APK_DEBUG_IDENTITY_LEAK
    fi
done
SENSITIVE_FILE="$(
    find "$TMP/apk" -type f \
        \( -iname '*.jks' -o -iname '*.keystore' -o -iname 'keystore.properties' \
           -o -iname 'local.properties' -o -iname '.env' \) \
        -print -quit
)"
[[ -z "$SENSITIVE_FILE" ]] || stop APK_SIGNING_OR_LOCAL_FILE_PACKAGED
if grep -R -a -F -q -- 'BEGIN PRIVATE KEY' "$TMP/apk"; then
    stop APK_PRIVATE_KEY_MATERIAL_FOUND
fi
echo 'PASS=APK_LEAK_GATE'

echo
echo '===== 9/9 CANONICAL RELEASE ARTIFACTS ====='
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RECORD_TEMPLATE="$PUBLIC_ROOT/docs/release/release-record-template.txt"
SMOKE_TEMPLATE="$PUBLIC_ROOT/docs/release/runtime-smoke-matrix.md"
[[ -f "$RECORD_TEMPLATE" ]] || stop RELEASE_RECORD_TEMPLATE_MISSING
[[ -f "$SMOKE_TEMPLATE" ]] || stop RUNTIME_SMOKE_TEMPLATE_MISSING

APK_FILENAME="Subshell-${VERSION_NAME}.apk"
SHA_FILENAME="${APK_FILENAME}.sha256"
RECORD_FILENAME="Subshell-${VERSION_NAME}-release-record.txt"
SMOKE_FILENAME="Subshell-${VERSION_NAME}-runtime-smoke.md"
FINAL_APK="$OUT_DIR/$APK_FILENAME"
FINAL_SHA="$OUT_DIR/$SHA_FILENAME"
FINAL_RECORD="$OUT_DIR/$RECORD_FILENAME"
FINAL_SMOKE="$OUT_DIR/$SMOKE_FILENAME"
cp "$APK_PATH" "$FINAL_APK"
APK_SHA256="$(sha256sum "$FINAL_APK" | awk '{print $1}')"
APK_SIZE_BYTES="$(stat -c '%s' "$FINAL_APK")"
printf '%s  %s\n' "$APK_SHA256" "$APK_FILENAME" > "$FINAL_SHA"
cp "$SMOKE_TEMPLATE" "$FINAL_SMOKE"
SOURCE_TREE="$(git -C "$ANDROID_ROOT" rev-parse HEAD^{tree})"
BUILD_HOST="$(uname -srmo | sed 's/[[:space:]]*$//')"
JAVA_VERSION="$(java -version 2>&1 | head -n1 || true)"
GRADLE_VERSION="$(cd "$ANDROID_ROOT" && ./gradlew --version 2>/dev/null | awk '/^Gradle / { print; exit }' || true)"
[[ -n "$JAVA_VERSION" ]] || JAVA_VERSION='UNKNOWN'
[[ -n "$GRADLE_VERSION" ]] || GRADLE_VERSION='UNKNOWN'
GENERATED_UTC="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
TAG="v${VERSION_NAME}"

export RR_VERSION_NAME="$VERSION_NAME" RR_VERSION_CODE="$VERSION_CODE" RR_TAG="$TAG"
export RR_APPLICATION_ID="$PACKAGE_ID" RR_SOURCE_COMMIT="$EXPECTED_MAIN" RR_SOURCE_TREE="$SOURCE_TREE"
export RR_APK_FILENAME="$APK_FILENAME" RR_APK_SIZE_BYTES="$APK_SIZE_BYTES" RR_APK_SHA256="$APK_SHA256"
export RR_RELEASE_CERT_SHA256="$ACTUAL_CERT" RR_RUNTIME_SMOKE_FILENAME="$SMOKE_FILENAME"
export RR_BUILD_HOST="$BUILD_HOST" RR_JAVA_VERSION="$JAVA_VERSION" RR_GRADLE_VERSION="$GRADLE_VERSION"
export RR_GENERATED_UTC="$GENERATED_UTC"

python3 - "$RECORD_TEMPLATE" "$FINAL_RECORD" <<'PY'
from pathlib import Path
import os
import re
import sys

src, dst = map(Path, sys.argv[1:])
text = src.read_text(encoding="utf-8")
mapping = {
    "<VERSION_NAME>": os.environ["RR_VERSION_NAME"],
    "<VERSION_CODE>": os.environ["RR_VERSION_CODE"],
    "<TAG>": os.environ["RR_TAG"],
    "<APPLICATION_ID>": os.environ["RR_APPLICATION_ID"],
    "<SOURCE_COMMIT>": os.environ["RR_SOURCE_COMMIT"],
    "<SOURCE_TREE>": os.environ["RR_SOURCE_TREE"],
    "<APK_FILENAME>": os.environ["RR_APK_FILENAME"],
    "<APK_SIZE_BYTES>": os.environ["RR_APK_SIZE_BYTES"],
    "<APK_SHA256>": os.environ["RR_APK_SHA256"],
    "<RELEASE_CERT_SHA256>": os.environ["RR_RELEASE_CERT_SHA256"],
    "<RUNTIME_SMOKE_FILENAME>": os.environ["RR_RUNTIME_SMOKE_FILENAME"],
    "<BUILD_HOST>": os.environ["RR_BUILD_HOST"],
    "<JAVA_VERSION>": os.environ["RR_JAVA_VERSION"],
    "<GRADLE_VERSION>": os.environ["RR_GRADLE_VERSION"],
    "<GENERATED_UTC>": os.environ["RR_GENERATED_UTC"],
}
for key, value in mapping.items():
    text = text.replace(key, value)
unresolved = sorted(set(re.findall(r"<[A-Z0-9_]+>", text)))
if unresolved:
    raise SystemExit("STOP=UNRESOLVED_RELEASE_RECORD_TOKENS:" + ",".join(unresolved))
dst.write_text(text.rstrip() + "\n", encoding="utf-8")
PY

[[ "$(sha256sum "$FINAL_APK" | awk '{print $1}')" == "$APK_SHA256" ]] || stop FINAL_APK_HASH_CHANGED

echo
echo 'CANONICAL_ASSETS_BEGIN'
printf '%s\n' "$FINAL_APK" "$FINAL_SHA" "$FINAL_RECORD" "$FINAL_SMOKE"
echo 'CANONICAL_ASSETS_END'
echo "APK_SHA256=$APK_SHA256"
echo "TAG=$TAG"
echo 'RESULT=SUBSHELL_PUBLIC_BETA_PREFLIGHT_PASS'
echo 'RUNTIME_SMOKE=PENDING'
echo 'PUBLICATION=NO'
echo 'READY_FOR_RUNTIME_SMOKE=YES'
echo "OUTPUT_DIR=$OUT_DIR"
