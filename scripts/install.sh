#!/usr/bin/env bash
#
# Symlink skills under ./skills into a personal agent skills directory.
#
# Usage:
#   ./scripts/install.sh                          # install ALL skills
#   ./scripts/install.sh sql-formatting           # install only the named skill(s)
#   ./scripts/install.sh sql-formatting other-one # install several named skills
#   ./scripts/install.sh --target ~/.claude/skills sql-formatting
#
# Positional arguments are skill names (folder names under ./skills). When none
# are given, every skill is installed. An existing entry at the target (symlink,
# file, or real directory) is replaced with a symlink to this repo.
#
# Options:
#   -t, --target DIR   Target skills directory (default: ~/.agents/skills).
#
set -euo pipefail

TARGET_DIR=""
SKILLS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      if [[ $# -lt 2 ]]; then
        echo "error: $1 requires a directory argument" >&2
        exit 1
      fi
      TARGET_DIR="$2"
      shift
      ;;
    --) shift; SKILLS+=("$@"); break ;;
    -*)
      echo "error: unknown option: $1" >&2
      exit 1
      ;;
    *) SKILLS+=("$1") ;;
  esac
  shift
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$REPO_ROOT/skills"
TARGET_DIR="${TARGET_DIR:-$HOME/.agents/skills}"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "error: skills directory not found: $SRC_DIR" >&2
  exit 1
fi

# Build the list of skill paths to install.
declare -a skill_paths=()
if [[ ${#SKILLS[@]} -eq 0 ]]; then
  for skill_path in "$SRC_DIR"/*/; do
    [[ -d "$skill_path" ]] && skill_paths+=("$skill_path")
  done
else
  for name in "${SKILLS[@]}"; do
    skill_path="$SRC_DIR/$name"
    if [[ ! -d "$skill_path" ]]; then
      echo "error: skill not found: $name (expected $skill_path)" >&2
      exit 1
    fi
    skill_paths+=("$skill_path")
  done
fi

mkdir -p "$TARGET_DIR"

linked=0
for skill_path in "${skill_paths[@]}"; do
  skill_name="$(basename "$skill_path")"

  if [[ ! -f "$skill_path/SKILL.md" ]]; then
    echo "skip: $skill_name (no SKILL.md)" >&2
    continue
  fi

  link="$TARGET_DIR/$skill_name"

  # Replace whatever is already there (symlink, file, or real directory).
  rm -rf "$link"

  ln -s "${skill_path%/}" "$link"
  echo "linked: $skill_name -> $link"
  linked=$((linked + 1))
done

echo "done: $linked skill(s) linked into $TARGET_DIR"
