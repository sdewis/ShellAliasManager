# Shell Alias Manager

A terminal tool for managing Bash and Zsh aliases — interactive TUI or scriptable CLI. Managed aliases are tagged with `#@managed_alias` so your hand-written shell config stays separate.

## Features

- **TUI and CLI** — `manage-aliases` opens a menu; subcommands work in scripts and CI
- **Smart tagging** — only `#@managed_alias` entries are touched by the tool
- **Dynamic placeholders** — `{localnet}`, `{git_branch}`, `{public_ip}`, and more resolve at runtime
- **Backup before writes** — shell config is timestamped before each change
- **JSON export/import** — portable alias backups across machines
- **Shell functions** — optional toolkit (mkcd, extract, todo, gsnap, …) in `~/.alias_manager/functions`
- **Bash and Zsh** — auto-detects `~/.bashrc` or `~/.zshrc`

## Quick install

From a clone:

```bash
git clone https://github.com/sdewis/ShellAliasManager.git
cd ShellAliasManager
./install.sh
source ~/.bashrc   # or ~/.zshrc
```

Or build a `.deb`:

```bash
./packaging/build-deb.sh 2.0-1
sudo dpkg -i shell-alias-manager_2.0-1_all.deb
```

## Usage

```bash
manage-aliases              # interactive TUI
manage-aliases list
manage-aliases add scan "nmap -sn {localnet}"
manage-aliases edit scan "nmap -sn {localnet} -oG -"
manage-aliases remove scan
manage-aliases export ~/aliases-backup.json
manage-aliases import ~/aliases-backup.json
manage-aliases placeholders
manage-aliases help
```

### Dynamic placeholders

Edit `~/.alias_manager_placeholders.sh` to add custom placeholders.

| Placeholder     | Resolves to                    |
|-----------------|--------------------------------|
| `{localnet}`    | Current subnet CIDR            |
| `{public_ip}`   | External IP                    |
| `{git_branch}`  | Current git branch             |
| `{gateway}`     | Default gateway                |
| `{iso_time}`    | ISO 8601 timestamp             |
| `{timestamp}`   | Unix timestamp                 |
| `{kernel_ver}`  | Running kernel version         |
| `{random_uuid}` | Random UUID                    |
| `{today}`       | Today's date (YYYY-MM-DD)      |

### Shell functions

After install, these load automatically in new shells:

| Command       | Purpose                          |
|---------------|----------------------------------|
| `alias_help`  | Command reference                |
| `mkcd`        | mkdir -p and cd                  |
| `extract`     | Extract archives                 |
| `todo` / `fin`| Per-folder task list             |
| `gsnap`       | Git snapshot branch              |
| `snap_clean`  | Remove old gsnap branches        |
| `self_update` | Pull latest from git             |
| `sync_backup` | Commit and push repo changes     |

## Project layout

```
bin/manage-aliases          CLI/TUI entry point
lib/                        Core modules (aliases, backup, ui, …)
functions/                  Optional shell function toolkit
install.sh                  Local install + shell rc setup
packaging/build-deb.sh      Build Debian package
alias_manager.sh            Backward-compatible shim (v1.x)
alias_manager_placeholders.sh  Default placeholder definitions
tests/run.sh                Smoke tests
```

## Dependencies

`bash`, `python3`, `curl`, `grep`, `sed`, `awk`, `ip` (iproute2)

## Contributing

Fork, add placeholders or functions, open a PR. Run `./tests/run.sh` before submitting.