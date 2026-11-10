#!/usr/bin/env python3
"""Render FEATURES.md into the collapsible lists in README.md and site/index.html.

FEATURES.md is the one place the feature list is edited. Run this script from
the repository root afterwards:  python3 -I tools/render-features.py
It rewrites only what sits between the FEATURES_*_START / FEATURES_*_END
markers in README.md and site/index.html.
"""
import html
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent


def sections():
    out, cur = [], None
    for line in (ROOT / "FEATURES.md").read_text().splitlines():
        if line.startswith("## "):
            cur = (line[3:].strip(), [])
            out.append(cur)
        elif cur and line.startswith("- "):
            cur[1].append(line[2:].strip())
    if not out:
        sys.exit("FEATURES.md has no sections")
    return out


def inline_html(s):
    s = html.escape(s, quote=False)
    s = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", s)
    s = re.sub(r"`(.+?)`", r"<code>\1</code>", s)
    s = re.sub(r"\[(.+?)\]\((.+?)\)", r'<a href="\2">\1</a>', s)
    return s


def readme_block(secs):
    parts = ["## Everything it does", "",
             "Open a group to see every feature in it. **(off)** means it is off until you turn it on in Settings.", ""]
    for title, items in secs:
        parts += ["<details>", f"<summary><strong>{title}</strong></summary>", ""]
        parts += [f"- {i}" for i in items]
        parts += ["", "</details>", ""]
    return "\n".join(parts).rstrip("\n")


def site_block(secs):
    parts = ['<div class="feature-accordion" id="everything">',
             "  <h3>Everything it does</h3>",
             "  <p>Open a group to see every feature in it. <strong>(off)</strong> means it is off until you turn it on in Settings.</p>"]
    for title, items in secs:
        parts.append("  <details>")
        parts.append(f"    <summary>{html.escape(title)}</summary>")
        parts.append("    <ul>")
        parts += [f"      <li>{inline_html(i)}</li>" for i in items]
        parts += ["    </ul>", "  </details>"]
    parts.append("</div>")
    return "\n".join(parts)


def splice(path, tag, body):
    p = ROOT / path
    t = p.read_text()
    a, b = f"<!-- {tag}_START -->", f"<!-- {tag}_END -->"
    i, j = t.index(a) + len(a), t.index(b)
    p.write_text(t[:i] + "\n" + body + "\n" + t[j:])


if __name__ == "__main__":
    secs = sections()
    splice("README.md", "FEATURES_README", readme_block(secs))
    splice("site/index.html", "FEATURES_SITE", site_block(secs))
    print(f"rendered {len(secs)} groups, {sum(len(i) for _, i in secs)} features")
