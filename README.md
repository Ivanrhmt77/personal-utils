# personal-utils

A collection of personal scripts and utilities to improve daily workflow, such as an interactive Git commit & push helper, backup, cleanup, and more.

## ⚡ Installation & Usage

1. **Clone the repository**

```bash
git clone https://github.com/Ivanrhmt77/personal-utils.git
cd personal-utils
```

2. **Add aliases to your shell configuration**

```bash
sudo nano ~/.bashrc   # or ~/.zshrc if using Zsh
```

Add aliases for scripts you want to use. Example for the Git Helper:

```bash
alias push="/path/to/personal-utils/bash/git-push-helper.sh"

# Add new aliases as you add more scripts
```

3. **Reload the shell**

```bash
source ~/.bashrc      # or source ~/.zshrc
```

4. **Run your scripts via aliases**

For example:

```bash
push   # runs the interactive Git push helper
```

## 💡 Tip for Window Managers (Hyprland or others)

If your window manager supports automatically sourcing shell configuration files (like `~/.bashrc` or `~/.zshrc`) on startup, you can add:

```bash
exec-once = source ~/.bashrc   # or ~/.zshrc
```

This ensures all your aliases are available in every session without needing to manually run source each time.

## 🤝 How to Collaborate

This repository is primarily personal, but contributions or improvements are welcome. Here’s how you can collaborate:

1. **Fork the repository**

Click the Fork button on GitHub to create your own copy.

2. **Clone your fork**

```bash
git clone https://github.com/your-username/personal-utils.git
cd personal-utils
```

3. **Create a new branch for your changes**

```bash
git checkout -b feature/your-feature-name
```

4. **Make scripts executable**

You can make a specific script executable:

```bash
chmod +x your-script.sh
chmod +x your-script.py
```

Or make all scripts in the folder executable at once:

```bash
chmod +x *.sh
chmod +x *.py
```

5. **Commit your changes**

```bash
git add .
git commit -m "feat: add description of your changes"
```

6. **Push your branch**

```bash
git push origin feature/your-feature-name
```

> 💡 Tip: You can also use the Git Helper via the `push` alias (or whatever alias you set) to interactively commit and push your changes.

7. **Open a Pull Request (PR)**

- Go to the original repo on GitHub
- Click Compare & Pull Request
- Provide a clear description of your changes

## ✨ Notes

- Use descriptive commit messages, preferably following Conventional Commit style.
- Test your scripts before opening a PR to ensure they work as intended.
- Add aliases for new scripts in your shell configuration to make them easy to run.
