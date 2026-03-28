# **🚀 Alias Manager TUI**

A colourful, interactive terminal user interface (TUI) for managing your Bash and Zsh aliases with ease. No more manual editing of `.bashrc` or `.zshrc`—add, remove, backup, and restore aliases through a slick, color-coded interface.

## **✨ Features**

* **Interactive TUI**: A beautiful terminal interface with color-coded menus and status indicators.  
* **Smart Tagging**: Automatically tracks aliases added by the tool using the `#@managed_alias` tag, ensuring your system defaults remain untouched.  
* **Dynamic Placeholders**: Use keywords like `{localnet}` or `{git_branch}` in your commands; the tool automatically resolves them to their live values at runtime.  
* **Backup & Restore**: Export your managed aliases to a portable JSON file and restore them on any machine.  
* **Cross-Shell Support**: Works seamlessly with both **Bash** and **Zsh**.  
* **Safe Operations**: Automatically creates backups of your configuration files before making changes.

## **🚀 Quick Install**

You can install the Alias Manager TUI with a single command:  

```bash
sudo dpkg -i shell-alias-manager_1.1-1_all.deb
```

Or download the latest `.deb` release from GitHub.
```

## **🛠 Usage**

Once installed, restart your terminal or run `source ~/.bashrc` (or `~/.zshrc`). Simply type the following command to launch the manager:  

```bash
manage-aliases
```

### **Dynamic Placeholders**

The tool supports intelligent string replacement that evaluates at runtime. New placeholders can be added to `~/.alias_manager_placeholders.sh`.

**Available Placeholders:**

* **`{localnet}`**: Resolves to your current local subnet CIDR (e.g., `192.168.1.0/24`).
* **`{public_ip}`**: Resolves to your external public IP address.
* **`{git_branch}`**: Resolves to the current Git branch name (or "no-branch").
* **`{gateway}`**: Resolves to the default gateway IP.
* **`{iso_time}`**: Resolves to the current ISO 8601 timestamp.
* **`{timestamp}`**: Resolves to the current Unix timestamp.
* **`{kernel_ver}`**: Resolves to the running kernel version.
* **`{random_uuid}`**: Generates a new random UUID.
* **`{today}`**: Resolves to today's date (YYYY-MM-DD).

**Example:**  
Adding an alias named `scan` with command `nmap -sp {localnet}` will create an alias that always scans your *current* network, even if you switch Wi-Fi networks.

## **📂 Project Structure**

* `alias_manager.sh`: The core logic containing the TUI and alias management functions.
* `alias_manager_placeholders.sh`: Definitions for dynamic placeholders and their backing functions.
* `installer.sh`: An intelligent installer that handles dependencies, shell detection, and configuration sourcing.
* `README.md`: You are here!

## **🔧 Dependencies**

The script is designed to be lightweight and uses standard tools found on most Unix-like systems:

* `python3` (for JSON processing)
* `curl` (for installation and IP checks)
* `grep`, `sed`, `awk`, `ip`

## **🤝 Contributing**

Contributions are welcome! Feel free to fork the repo, add new placeholders, or improve the UI styling.  
*Created with ❤️ for the terminal power user.*
