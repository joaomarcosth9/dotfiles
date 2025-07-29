# 📁 Navegação
alias ..='cd ..'
alias ...='cd ../..'
alias mkcd='f() { mkdir -p "$1" && cd "$1"; }; f'
# alias cd="z "

# clip
alias clip='xclip -sel copy'

# 📄 Utilitários
#alias vim="nvim "
alias cls="clear"
alias cat="batcat -pp "
alias diff="colordiff "
alias exe="chmod +x"
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
# alias find='fd'
alias grep='rg'

# rmtrash
alias del='rmtrash'
alias deldir='rmdirtrash'

# 📂 Listagem de arquivos
alias ls="eza"
alias l="eza"
alias ll="eza -l"
alias la="eza -la"
alias dir="eza -lah"

# 🔐 sudo preservando aliases
alias sudo="sudo "

# Alias pra evitar Ghostscript
alias gs='git status'
