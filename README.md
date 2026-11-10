# subshell for Reddit

**An independent Android client for Reddit**, built for everyday Reddit use:
reading, writing, chatting and moderating, with no ads and no tracking.

**[Download the current public beta (1.0.0-rc.2)](https://github.com/brealorg/subshell/releases/tag/v1.0.0-rc.2)** ·
[Get started](https://brealorg.github.io/subshell/get-started/) ·
[Add to Obtainium](https://apps.obtainium.imranr.dev/redirect?r=obtainium://app/%7B%22id%22%3A%22io.github.brealorg.subshell%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2Fbrealorg%2Fsubshell%22%2C%22author%22%3A%22brealorg%22%2C%22name%22%3A%22subshell%22%2C%22additionalSettings%22%3A%22%7B%5C%22includePrereleases%5C%22%3Atrue%7D%22%7D) ·
[Website](https://brealorg.github.io/subshell/) ·
[FAQ](https://brealorg.github.io/subshell/faq/) ·
[r/subshell](https://www.reddit.com/r/subshell/)

<p align="center">
  <img src="site/assets/screenshots/home.webp"
       alt="subshell Home feed with a photo gallery post from r/norway."
       width="200">
  <img src="site/assets/screenshots/post.webp"
       alt="An open post with its comments, sort and comment box."
       width="200">
  <img src="site/assets/screenshots/community.webp"
       alt="The r/space community page with its banner, description and sort menu."
       width="200">
  <img src="site/assets/screenshots/settings.webp"
       alt="Settings, searchable and grouped by area."
       width="200">
</p>

## What subshell does

### It keeps your place.

Open a post, go back, switch accounts: the feed is where you left it. Pages load as you scroll, with no "load more" buttons.

- Optional: reopen at your place after the app was closed, as you left it or after loading new posts
- Unread markers, and hide the posts you have read
- Save your feed for offline reading: top 50 posts, their comments and images

### Threads you can read.

Replies load by themselves, and you can find your way around long threads.

- Find in thread, with a chip for the post author's comments
- Comments new since your last visit are highlighted and counted
- Thread colours and a jump between top-level comments (both optional)
- Reddit's suggested sort, used for you

### Moderate from your phone.

- The queue, Removed, Edited and Unmoderated lists, the mod log and Modmail with internal notes
- One Moderate menu on every post and comment: approve, remove with the community's removal reasons, spam, flair, lock, distinguish, reports
- Ban, mute and approve users; manage the moderator team; saved responses

### Keep the noise out, hear about what matters.

- Content filters for words, users, domains, communities and flair, everywhere or in one community
- Mute a community for an hour, a week or for good; hide a joined community without leaving it
- An on-device language filter for search and discovery (Android 10+, optional)
- Notifications for new posts in communities you watch, and Inbox notifications per type

### Photos and video.

- Galleries and a full-screen viewer with zoom, share and save
- Reddit video with a quality limit per network, subtitles and audio language; RedGIFs in NSFW posts
- Optional: playback speed, double-tap skip, hold for 2x, pinch zoom, picture-in-picture

### Private, portable, open.

- No ads, no analytics, no crash reporting; your sign-in is stored encrypted on the device
- Optional app lock, and device unlock before hidden communities show
- Back up your settings to a folder you own; export your Reddit data as JSON and CSV
- GPL-3.0-or-later; updates are checked against a published SHA-256 before Android installs them

### Make it yours.

- Light, dark or system theme, dynamic colour and pure black; text and UI size
- Left- or right-handed controls and navigation; tablets and foldables
- Drafts, saved searches, private notes on usernames, widgets and launcher shortcuts
- Searchable settings in ten areas; many extras are off until you turn them on

**Also in subshell:** Direct Chat, Several accounts, Share into subshell, Custom feeds, Crossposting, Mention suggestions from the thread.

**What it does not do:** no video download, no alt text, no voting in polls and no wiki editing.

**[Everything subshell does, and what it does not →](FEATURES.md)**

## Get started

1. **Install the APK.** Download the signed beta from [GitHub Releases](https://github.com/brealorg/subshell/releases/tag/v1.0.0-rc.2).
   Each release has a `.sha256` checksum and a release record, so a damaged download shows up.
   The checksum sits next to the APK, so it only catches a damaged download. To check that the APK
   is really signed by subshell, compare its signing certificate with this SHA-256 fingerprint:

   `52:E9:62:E7:41:2E:25:DA:80:1E:0A:39:06:E0:BF:B4:39:90:0A:1A:A1:5B:A9:F9:3C:95:B4:99:55:BA:F5:84`

   On a computer: `apksigner verify --print-certs Subshell-<version>.apk` (Android SDK build-tools)
   prints it as `Signer #1 certificate SHA-256 digest`. On the phone, the AppVerifier app checks it.
2. **Get a Client ID.** Once, through RedReader's Reddit sign-in. The app shows you how;
   the [guide](https://brealorg.github.io/subshell/get-started/) has the same steps.
3. **Sign in** on Reddit's own page. Add more accounts any time.

Android 8.0 or newer. subshell checks for new versions itself. Update in
Settings › Updates downloads the release APK from GitHub, checks it against the
published SHA-256 and hands it to Android, which asks you before it installs.

<!-- RELEASETOOL02_WHATS_NEW_START -->
## What's new in 1.0.0-rc.2

The Update button in the update dialog now updates the app

- The "subshell update available" dialog now has an Update button that downloads and installs the update inside the app. Before, it only led to the GitHub page.
- Everything else is the same as 1.0 release candidate 1 and 0.92. If Update or What's new does not work for you, tell us on r/subshell or GitHub.

[All release notes](https://brealorg.github.io/subshell/changelog/)
<!-- RELEASETOOL02_WHATS_NEW_END -->

## Privacy

No advertising, analytics, crash reporting or tracking. subshell talks to Reddit
for you; your sign-in and Client ID stay encrypted on your device, and backups go
to a folder you choose. See the [privacy notice](https://brealorg.github.io/subshell/privacy/).

## Feedback

- [Report a bug](https://github.com/brealorg/subshell/issues/new?template=bug_report.yml)
- [Request a feature](https://github.com/brealorg/subshell/issues/new?template=feature_request.yml)
- [Report a vulnerability privately](https://github.com/brealorg/subshell/security/advisories/new)
- [Discuss subshell on r/subshell](https://www.reddit.com/r/subshell/)

When reporting a problem, include the subshell version, Android version, device
model when relevant, and clear reproduction steps. Remove usernames, message
contents, tokens, cookies and other private account information from screenshots
and logs.

## Repository scope

This repository is the public project, release, documentation,
issue-tracking, and website home for subshell.

The Android application source code is published separately in [brealorg/subshell-source-public](https://github.com/brealorg/subshell-source-public),
one snapshot per release, under the GNU General Public License v3.0 or later.
That repository is read-only; report bugs and ideas here.

Public APKs are published only after passing the project's release
qualification and signing gates.

subshell is written by one developer with help from AI coding tools; every change
is reviewed and tested on a real phone before it ships.

## Independence

subshell is independent software and is not affiliated with, endorsed by,
or sponsored by Reddit.
