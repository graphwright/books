#!/usr/bin/env python3
"""
Format raw browser AI chat markdown.

Transforms "Thought process:" sections into collapsible <details> blocks:

    Before:
        ```plaintext
        Thought process: One-line summary here.

        Body text...
        ```

    After:
        <details>
        <summary>Thought process</summary>

        ```plaintext
        Body text...
        ```

        </details>
"""

import re
import sys


THOUGHT_BLOCK_RE = re.compile(
    r"`{3,4}plaintext\n"
    r"Thought process:[ \t]*(?P<summary>[^\n]*)\n"
    r"\n"
    r"(?P<body>.*?)"
    r"`{3,4}",
    re.DOTALL,
)


def format_thought_block(m: re.Match) -> str:
    summary = m.group("summary").strip()
    body = m.group("body").rstrip()
    quoted = "\n".join(
        f"> {line}" if line.strip() else ">"
        for line in body.splitlines()
    )
    return (
        "<details>\n"
        f"<summary>Thought process</summary>\n"
        "\n"
        f"{quoted}\n"
        "\n"
        "</details>"
    )


def format_chat(text: str) -> str:
    return THOUGHT_BLOCK_RE.sub(format_thought_block, text)


def main() -> None:
    if len(sys.argv) == 1:
        text = sys.stdin.read()
    elif len(sys.argv) == 2:
        with open(sys.argv[1]) as f:
            text = f.read()
    else:
        print(f"Usage: {sys.argv[0]} [file]", file=sys.stderr)
        sys.exit(1)

    print(format_chat(text), end="")


if __name__ == "__main__":
    main()
