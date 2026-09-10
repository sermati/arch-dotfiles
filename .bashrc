#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

export PATH="$HOME/.local/bin:$PATH"

# ssh-agent de la sesion (arranca en el autostart de Hyprland, socket fijo).
# Solo para hoy: hasta el proximo login, hyprland.lua no reaplica el env.
export SSH_AUTH_SOCK="/run/user/1000/ssh-agent.sock"

# Starship prompt (Catppuccin Mocha)
eval "$(starship init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Dotfiles: repo git "bare" con --work-tree=$HOME (ver ~/install.sh y README.md)
# Sin argumentos hace push; con argumentos se comporta como git normal.
dotfiles() {
    if [ $# -eq 0 ]; then
        git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" push origin master
    elif [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        cat <<'EOF'
dotfiles — repo git bare con --work-tree=$HOME (ver README.md para mas detalle)

  dotfiles                    push a origin/master (asi sin nada mas)
  dotfiles status              que cambio desde el ultimo commit
  dotfiles diff [archivo]       ver el diff en detalle
  dotfiles add <archivo>...    empezar a trackear / stagear cambios
  dotfiles commit -m "..."     commitear lo stageado
  dotfiles log --oneline       ver el historial
  dotfiles rm --cached <arch>  dejar de trackear un archivo (sin borrarlo del disco)

  Flujo tipico para versionar un config nuevo:
    dotfiles add ~/.config/algo/config.toml
    dotfiles status
    dotfiles commit -m "feat: agrega config de algo"
    dotfiles
EOF
    else
        git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
    fi
}
