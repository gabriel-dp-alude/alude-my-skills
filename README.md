# alude-my-skills

Personal collection of AI agent **skills** (`SKILL.md` folders) for VS Code Copilot,
Claude, and other agents that support the Agent Skills format.

This repo is the **source of truth** for my skills. They are authored and
version-controlled here, then installed into a personal agent skills location so
agents can discover and load them on demand.

&nbsp;

## Structure

```txt
alude-my-skills/
├── skills/                 # Each subfolder is one skill (folder name == skill name)
│   └── <skill-name>/
│       ├── SKILL.md        # Required. Frontmatter (name, description) + instructions
│       ├── references/     # Optional. Docs loaded on demand
│       ├── scripts/        # Optional. Executable helpers
│       └── assets/         # Optional. Templates / boilerplate
├── templates/
│   └── SKILL.md            # Starter template for new skills
├── scripts/
│   └── install.sh          # Symlinks skills/* into ~/.agents/skills/
└── README.md
```

&nbsp;

## Personal skill locations

Agents discover personal skills from any of these (pick one to install into):

| Path | Used by |
| ---- | ------- |
| `~/.agents/skills/<name>/` | VS Code Copilot, generic agents |
| `~/.copilot/skills/<name>/` | Copilot |
| `~/.claude/skills/<name>/` | Claude |

&nbsp;

## Add a new skill

1. Copy the template into a new folder:

   ```bash
   mkdir -p skills/my-new-skill
   cp templates/SKILL.md skills/my-new-skill/SKILL.md
   ```

2. Edit the frontmatter `name` (match the folder) and `description`.
3. Write the body: what it does, when to use, step-by-step procedure.
4. Install / refresh links:

   ```bash
   ./scripts/install.sh
   ```

&nbsp;

## Install

`install.sh` symlinks skills under `skills/` into `~/.agents/skills/` so edits in
this repo are reflected immediately. Any existing entry at the target (symlink,
file, or real folder) is replaced with a symlink to this repo.

```bash
./scripts/install.sh                              # install all skills
./scripts/install.sh sql-formatting               # install only the named skill(s)
./scripts/install.sh --target ~/.claude/skills    # custom target dir
```
