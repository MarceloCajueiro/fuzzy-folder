# CLAUDE.md - fuzzy-folder (ff)

## What This Is

`ff` — a shell tool to quickly cd into project directories using fuzzy matching. Pure bash, no dependencies beyond coreutils (fzf optional for multi-match).

## Project Structure

```
ff.sh          — main script (fuzzy matching logic, outputs matched path)
ff-init.zsh    — shell function wrapper (sources in zsh, does the cd)
install.sh     — installer (patches paths, creates config, adds to .zshrc.local)
```

## Config

- Location: `~/.config/ff/config` (or `$FF_CONFIG`)
- Format: one search path per line, optional `depth=N` (default: 2)

## How It Works

1. Collects directories from configured search paths (via `find`)
2. Normalizes query and dir names: lowercase, strip `-_.`, strip accents
3. Substring match of normalized query against normalized dir names
4. 1 match → output path. Multiple → fzf. 0 → error.

## Key Design Decisions

- Script outputs path to stdout; shell function does `cd` (can't cd from subprocess)
- Normalization uses `sed` character classes (not `iconv`) for macOS compatibility
- Ignores hidden dirs, node_modules, .git, vendor, __pycache__, .venv, target, .build

## Testing

```bash
./ff.sh trans        # should output single path
./ff.sh -l           # should list all indexed dirs
./ff.sh nonexistent  # should exit 1 with error message
```

## Language

- Code: English
- Commits/PRs: English
