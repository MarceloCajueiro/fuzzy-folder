# ff - fuzzy folder finder

A fast terminal command to jump into project directories using fuzzy matching.

Type `ff trans` to jump into `~/Code/empreendimentos/transmuta`. If multiple directories match, pick one with fzf.

## Features

- Fuzzy matching with accent, hyphen, underscore, and dot removal (`idi` matches `i-diário`)
- Configurable search paths with depth control
- fzf integration for multiple matches (falls back to numbered list)
- Zero dependencies beyond bash and coreutils (fzf optional)

## Install

```bash
git clone https://github.com/MarceloCajueiro/fuzzy-folder.git
cd fuzzy-folder
./install.sh
```

This will:
1. Create a default config at `~/.config/ff/config`
2. Add the `ff` function to your shell

Restart your shell or run `source ~/.zshrc.local`.

## Usage

```bash
ff trans       # cd into ~/Code/empreendimentos/transmuta
ff idi         # matches i-diário (removes hyphens + accents)
ff ninho       # cd into ~/Code/empreendimentos/ninho
ff -l          # list all indexed directories
ff -e          # edit config file
```

## Configuration

Edit `~/.config/ff/config`:

```
# search paths - one per line
# optional: depth=N (default: 2)
~/Code depth=2
~/projects
```

Each line defines a root to search. `depth=2` means it searches `~/Code/*` and `~/Code/*/*`.

## How it works

1. Collects all directories from configured search paths
2. Normalizes both the query and directory names (lowercase, strip accents/hyphens/underscores)
3. Checks if the normalized query is a substring of any normalized directory name
4. One match → cd directly. Multiple matches → fzf picker. No match → error.

## Requirements

- bash 4+
- macOS or Linux
- [fzf](https://github.com/junegunn/fzf) (optional, for multi-match selection)

## License

MIT
