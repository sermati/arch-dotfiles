# arch-dotfiles

Rice de **Arch Linux + Hyprland** pensado para trabajar como dev con un flujo asistido por IA: escribir features, revisar el diff, probarlo en el navegador y comittear con un mensaje generado por IA que respeta la convención de [dai](https://github.com/dforce2055/dai) — todo sin salir de la terminal.

Tema: **Catppuccin Mocha** en todos lados (Hyprland, waybar, kitty, wofi).

## Stack

| Capa | Herramienta |
|---|---|
| Compositor | [Hyprland](https://hyprland.org) (config nativa en **Lua**, no `.conf`) |
| Barra | [waybar](https://github.com/Alexays/Waybar) |
| Terminal | [kitty](https://sw.kovidgoyal.net/kitty/) |
| Multiplexor | [zellij](https://zellij.dev) |
| Lanzador | [wofi](https://hg.sr.ht/~scoopta/wofi) |
| Lock / idle | hyprlock + hypridle |
| Wallpaper | hyprpaper |
| Notificaciones | [mako](https://github.com/emersion/mako) |
| Prompt | [starship](https://starship.rs) |
| Password manager | [rbw](https://github.com/doy/rbw) (cliente no oficial de Bitwarden/Vaultwarden) + rofi-rbw |
| VPN mesh | [Tailscale](https://tailscale.com) |
| Firewall | ufw |
| Git UI | [lazygit](https://github.com/jesseduffield/lazygit) + generación de mensajes de commit por IA |
| Metodología IA | [dai](https://github.com/dforce2055/dai) |
| Node | [nvm](https://github.com/nvm-sh/nvm) (multi-version por proyecto) |

## Instalación

Instala primero los paquetes (ver [Prerrequisitos](#prerrequisitos)), después restaura los dotfiles con un solo comando:

```sh
curl -fsSL https://raw.githubusercontent.com/sermati/arch-dotfiles/master/install.sh | bash
```

Qué hace `install.sh`:
1. Clona este repo como **bare repo** en `~/.dotfiles`.
2. Si ya hay archivos en el home que chocan con los del repo (ej. un `.bashrc` default recién instalado), los mueve a `~/.dotfiles-backup-<fecha>/` antes de pisarlos — no se pierde nada.
3. Hace `checkout` para que los archivos queden en su ruta real (`~/.config/waybar/config.jsonc`, etc.) — **sin symlinks**.

Es idempotente: correrlo de nuevo en una máquina que ya tiene `~/.dotfiles` simplemente actualiza (`pull`) en vez de clonar.

### Cómo funciona el versionado (sin herramientas extra)

Este repo **no** vive en una carpeta separada — es un [bare repo](https://www.atlassian.com/git/tutorials/dotfiles) que usa `$HOME` directamente como working tree. Los archivos están en su ubicación real, no hay symlinks que gestionar. Para trabajar con él día a día (después de correr `install.sh` una vez), usá el alias que ya viene en `.bashrc`:

```sh
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

dotfiles status
dotfiles add ~/.config/algo
dotfiles commit -m "..."
dotfiles push
```

## Prerrequisitos

Paquetes de los repos oficiales (`pacman -S`):

```
hyprland hypridle hyprlock hyprpaper hyprpolkitagent xdg-desktop-portal-hyprland
waybar kitty wofi mako zellij lazygit starship
rbw rofi-rbw
networkmanager network-manager-applet bluez blueman
tailscale ufw pacman-contrib
cliphist wl-clipboard grim slurp
pipewire pipewire-pulse wireplumber pavucontrol
playerctl brightnessctl
thunar xfconf gsettings-desktop-schemas
adw-gtk-theme papirus-icon-theme ttf-jetbrains-mono-nerd
```

Aparte, por fuera de pacman:

- **[nvm](https://github.com/nvm-sh/nvm)** — se instala con su script oficial, no está en los repos:
  ```sh
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
  nvm install --lts
  ```
- **[Claude Code](https://claude.com/claude-code)** (`claude`) — el agente de IA que corre en el panel izquierdo del layout de zellij y genera los mensajes de commit.
- **[dai](https://github.com/dforce2055/dai)** — `npm i -g @dforce2055/dai`, y después `dai install --global --for claude` para instalar sus skills en `~/.claude/skills`.

Habilitá los servicios de sistema que lo necesitan:
```sh
sudo systemctl enable --now tailscaled bluetooth ufw
```

## Estructura del repo

```
.
├── install.sh                          # bootstrap (clone bare + checkout + backup de conflictos)
├── .bashrc, .bash_profile              # PATH, starship, nvm, alias `dotfiles`
├── .gitignore                          # excluye secretos y estado especifico de la maquina
└── .config/
    ├── hypr/
    │   ├── hyprland.lua                # config nativa en Lua: binds, autostart, monitores, theming
    │   ├── hyprlock.conf / hypridle.conf / hyprpaper.conf
    │   └── scripts/auto-brightness.sh
    ├── waybar/
    │   ├── config.jsonc / style.css
    │   ├── scripts/                    # modulos custom (ver abajo)
    │   └── icons/                      # logo oficial de Tailscale (Simple Icons, en 3 colores segun estado)
    ├── zellij/
    │   ├── config.kdl
    │   ├── layouts/dev.kdl             # el layout del flujo de trabajo con IA
    │   └── scripts/start-dev-server.sh
    ├── lazygit/
    │   ├── config.yml                  # bind Ctrl+A -> commit generado por IA
    │   └── scripts/                    # ai-commit.sh, ai-commit-msg.sh
    ├── kitty/, wofi/, starship.toml
    └── git/ignore                      # gitignore global (para repos normales, no este)
```

## Waybar: módulos custom

Además de los módulos estándar (red, bluetooth, batería, etc.), la barra tiene 4 indicadores hechos a medida, todos con script propio en `waybar/scripts/`:

| Módulo | Qué muestra | Click | Click derecho |
|---|---|---|---|
| **Tailscale** (`image#tailscale`) | Logo oficial de Tailscale, coloreado según estado (verde=conectado, gris=detenido/desconectado) — vive pegado al `tray`, junto a los íconos de apps como Discord | Notificación con `tailscale status` completo | Abre la admin console |
| **UFW** (`custom/ufw`) | Firewall activo/inactivo, leído vía `systemctl is-active` (no requiere root) | — | — |
| **Actualizaciones pacman** (`custom/pacman-updates`) | Cantidad de paquetes pendientes (`checkupdates`, de `pacman-contrib`) — se oculta solo si no hay nada pendiente | Abre `sudo pacman -Syu` en kitty | — |
| **rbw** (`custom/rbw`) | Estado del vault (bloqueado/desbloqueado) | `rbw unlock` en kitty | `rbw lock` |

El módulo `network` tiene además `on-click` a `nm-connection-editor` (compensa haber sacado `nm-applet` del autostart, que quedaba duplicado con el módulo nativo de waybar).

## El flujo de trabajo con IA

El corazón de todo esto es `zellij/layouts/dev.kdl`. Desde la carpeta de un proyecto:

```sh
zellij --layout dev
```

Levanta 4 paneles:

```
┌─────────────────────────────┬──────────────┐
│                              │              │
│   lazygit (60%)              │  claude (40%)│
│   revisar diff, stagear,     │  el agente   │
│   Ctrl+A = commit con IA     │  escribiendo │
│                              │  el feature  │
├──────────────────┬───────────┴──────────────┤
│  dev server        │  terminal para dai       │
│  (npm/pnpm/yarn/    │  (dai check, dai pr,     │
│   bun run dev,       │   dai stamp, etc)        │
│   detecta nvmrc y    │                          │
│   package manager)   │                          │
└──────────────────┴──────────────────────────┘
```

El ciclo completo:

1. El agente (`claude`, con las skills de `dai` ya instaladas) hace `explore → propose → apply` sobre una user story.
2. Mientras tanto el dev server ya está corriendo abajo a la izquierda — se abre el navegador en otro workspace de Hyprland para ver el feature en vivo.
3. En `lazygit` se revisa el diff generado, se stagea lo que corresponde.
4. `Ctrl+A` en `lazygit` → corre `ai-commit.sh`, que le pide a Claude un mensaje de commit siguiendo **al pie de la letra** la convención de `dai` (`<tipo>(<scope>)!: <resumen>`, español, imperativo, sin mencionar IA ni agregar `Co-authored-by`) y abre el editor para revisarlo/editarlo antes de confirmar — el commit lo firma la persona, no el agente.
5. En el panel de la derecha abajo: `dai check` (verifica que el código quedó linkeado a la user story) y `dai pr` (crea la PR).

### `start-dev-server.sh`

No asume nada del proyecto: lee `.nvmrc` (o `engines.node` en `package.json`) y hace `nvm use`, instalando la versión si todavía no está descargada. Para el package manager, detecta por lockfile (`pnpm-lock.yaml`, `yarn.lock`, `bun.lockb`) o por el campo `"packageManager"`, y si el binario no está instalado lo activa al vuelo vía `corepack` — nunca asume `npm` a ciegas.

## Créditos

- Tema Catppuccin Mocha.
- Metodología de desarrollo asistido por IA: [dai](https://github.com/dforce2055/dai)
