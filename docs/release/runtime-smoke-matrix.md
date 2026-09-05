# Stable public beta runtime smoke matrix

Complete this matrix against the exact signed Stable APK intended for
publication. Every applicable blocking row must be `PASS`.

Use `N/A` only when a feature is genuinely unavailable for the account or
role being tested, and record the reason. Do not attach unsanitized logs,
Reddit tokens, cookies, private messages, credentials, or other sensitive
account data.

## Artifact identity

| Check | Result | Proof / notes |
| --- | --- | --- |
| Exact APK filename matches preflight record | PENDING | |
| APK SHA-256 matches preflight record | PENDING | |
| Stable package is `io.github.brealorg.subshell` | PENDING | |
| Release certificate matches established identity | PENDING | |
| Version name matches intended beta | PENDING | |
| Version code matches intended beta | PENDING | |

## Installation and startup

| Check | Result | Proof / notes |
| --- | --- | --- |
| Clean Stable install succeeds | PENDING | |
| First launch succeeds without crash | PENDING | |
| App identity/name/icon are Stable, not DEV1/DEV2 | PENDING | |
| Restart after force-stop succeeds | PENDING | |
| Intended state survives normal process restart | PENDING | |

## Account and OAuth

| Check | Result | Proof / notes |
| --- | --- | --- |
| Connect Reddit account succeeds | PENDING | |
| OAuth callback returns to Stable correctly | PENDING | |
| Authenticated session survives restart | PENDING | |
| Account switch works when multiple accounts are available | PENDING | |
| Account-scoped state does not bleed across accounts | PENDING | |

## Core reading

| Check | Result | Proof / notes |
| --- | --- | --- |
| Home opens and refreshes | PENDING | |
| Home paging / continued scrolling works | PENDING | |
| Community feed opens | PENDING | |
| Post detail opens | PENDING | |
| Comments hydrate and remain stable while scrolling | PENDING | |
| User profile opens from supported surfaces | PENDING | |
| Search opens and returns usable results | PENDING | |

## Core actions

| Check | Result | Proof / notes |
| --- | --- | --- |
| Upvote and remove upvote | PENDING | |
| Downvote and remove downvote | PENDING | |
| Save and unsave supported content | PENDING | |
| Hide and unhide supported content | PENDING | |
| Share action works | PENDING | |
| Join and leave a community | PENDING | |
| Post/comment reply write path works where enabled | PENDING | |

## You / Library

| Check | Result | Proof / notes |
| --- | --- | --- |
| Posts tab opens | PENDING | |
| Comments tab opens | PENDING | |
| Saved tab opens and pages | PENDING | |
| Upvotes tab opens | PENDING | |
| Downvotes tab opens | PENDING | |
| Hidden tab opens | PENDING | |
| Drafts workspace opens and expected draft actions work | PENDING | |

## Inbox, messages and moderation

| Check | Result | Proof / notes |
| --- | --- | --- |
| Inbox Activity opens and refreshes | PENDING | |
| Messages surface opens where available | PENDING | |
| Direct Chat thread opens where available | PENDING | |
| Direct Chat send works where enabled | PENDING | |
| Direct Chat live updates work where enabled | PENDING | |
| Modmail queue opens for moderator account | PENDING / N/A | |
| Modmail thread opens for moderator account | PENDING / N/A | |
| Modmail reply/internal-note paths work if included | PENDING / N/A | |

## Notifications

| Check | Result | Proof / notes |
| --- | --- | --- |
| Notification channel/permission behavior is sane | PENDING | |
| New supported notification is posted | PENDING | |
| Notification tap routes to intended content | PENDING | |
| Read-state reconciliation does not leave stale notification | PENDING | |
| Account-scoped notifications do not cross-cancel | PENDING | |

## Presentation and settings

| Check | Result | Proof / notes |
| --- | --- | --- |
| Native dark theme renders correctly | PENDING | |
| Native light theme renders correctly | PENDING | |
| Dynamic/device colour behavior works where supported | PENDING | |
| Large-text setting does not break critical navigation | PENDING | |
| Tablet-mode setting behaves as intended where applicable | PENDING / N/A | |

## Resilience

| Check | Result | Proof / notes |
| --- | --- | --- |
| Refresh failure produces recoverable UI | PENDING | |
| Temporary network loss does not corrupt account state | PENDING | |
| Cached content remains coherent after restart | PENDING | |
| No obvious crash loop after repeated open/close/refresh | PENDING | |

## Final runtime verdict

- APK SHA-256:
- Device:
- Android version:
- Reddit account role(s):
- Started:
- Completed:
- Blocking failures:
- Non-blocking observations:
- Final result: `PENDING`

A public beta may proceed only when the final result is `PASS`.
