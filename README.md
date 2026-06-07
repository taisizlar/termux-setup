# Termux Auto Setup

**One script. Full setup. Zero headache.**

![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Termux-black?style=flat-square&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-GPL--3.0-blue?style=flat-square)

A single Bash script that fully configures a fresh Termux installation — packages, Python libraries, aliases, storage access, and shell settings — all in one run.

---

## Usage

**Option 1 — Clone & run**

```bash
git clone https://github.com/taisizlar/termux-setup.git
cd termux-setup
bash setup.sh
```

**Option 2 — One-liner**

```bash
curl -sL https://raw.githubusercontent.com/taisizlar/termux-setup/main/setup.sh | bash
```

---

## What gets installed

<details>
<summary>Essential Tools</summary>

| Package | Purpose |
|---------|---------|
| `git` | Version control |
| `wget` | File downloader |
| `zip` / `unzip` / `tar` | Archive tools |
| `vim` / `nano` | Text editors |

</details>

<details>
<summary>Development Environment</summary>

| Package | Purpose |
|---------|---------|
| `python` / `python2` | Python interpreters |
| `clang` | C/C++ compiler |
| `nodejs` | JavaScript runtime |
| `ruby` | Ruby interpreter |
| `php` | PHP interpreter |

</details>

<details>
<summary>Network & System Tools</summary>

| Package | Purpose |
|---------|---------|
| `openssh` | SSH client/server |
| `curl` | HTTP client |
| `proot` | Chroot emulation |
| `dnsutils` | DNS lookup tools |
| `htop` | Process monitor |
| `nmap` | Network scanner |
| `termux-api` | Android API bridge |
| `termux-tools` | Termux utilities |

</details>

<details>
<summary>Fun Tools</summary>

| Package | Purpose |
|---------|---------|
| `cmatrix` | Matrix rain in your terminal |
| `cowsay` | ASCII cow messages |
| `figlet` / `toilet` | Big ASCII text banners |
| `tor` | Tor anonymity network |
| `lolcat` *(gem)* | Rainbow-colored output |

</details>

<details>
<summary>Python Libraries (pip)</summary>

| Package | Purpose |
|---------|---------|
| `colorama` | Terminal colors |
| `Flask` | Web framework |
| `mnemonic` | BIP39 mnemonic generation |
| `python-dotenv` | Load `.env` files |
| `requests` | HTTP library |
| `setuptools` | Python packaging |
| `Telethon` | Telegram MTProto API client |
| `wheel` | Wheel build support |

</details>

---

## What gets configured

**Aliases** added to `~/.bashrc`:

```bash
alias cls='clear'
alias py='python'
alias update='pkg update && pkg upgrade'
alias serve='python -m http.server 8000'
```

**`~/.hushlogin`** — suppresses Termux's login messages.

**Storage permission** — prompts `termux-setup-storage` automatically. Tap **Allow** when the dialog appears.

**`~/.bashrc` is sourced** at the end so aliases are active immediately.

---

## Requirements

- [Termux](https://termux.dev) from F-Droid (not Play Store)
- Active internet connection
- Android 7.0+

---

## License

GPL-3.0 — see [LICENSE](LICENSE).
