# 🌀 Framework Oh My Zsh e Plugins
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
source $HOME/.zsh_plugins
source $ZSH/oh-my-zsh.sh

# 🗂️ PATHs customizados
export PATH="$PATH:/home/joao/.local/bin"
# export PATH="$PATH:/home/joao/.dotnet/tools"
export PATH="$PATH:/home/joao/python_tools"
export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"

# ✏️ Editor padrão
export EDITOR="vim "
export VISUAL="$EDITOR"

# ⚙️ Pyenv (gerenciador de versões Python)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

# ASDF
. ${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# 🚀 Zoxide (cd inteligente)
eval "$(zoxide init zsh)"
cd() {
  local oldpwd="$PWD"

  if [[ "$#" -eq 0 ]]; then
    builtin cd ~
  elif [[ "$1" == "-" ]]; then
    builtin cd "$OLDPWD"
  elif [[ "$1" == "." || "$1" == ".." || "$1" == /* || "$1" == ./* || "$1" == ../* || -e "$1" ]]; then
    builtin cd "$@" && export OLDPWD="$oldpwd"
  else
    if command -v z >/dev/null 2>&1 && z "$@" 2>/dev/null; then
      export OLDPWD="$oldpwd"
    elif [ -d "$1" ]; then
      builtin cd "$@" && export OLDPWD="$oldpwd"
    else
      echo "cd: nenhum caminho válido encontrado para '$1'" >&2
      return 1
    fi
  fi
}

# 🔌 Atalhos do GitHub Copilot CLI
# bindkey '»' zsh_gh_copilot_explain  # Option+Shift+\
# bindkey '«' zsh_gh_copilot_suggest  # Option+\
# bindkey '^[|' zsh_gh_copilot_explain  # bind Alt+shift+\ to explain
# bindkey '^[\' zsh_gh_copilot_suggest  # bind Alt+\ to suggest

# 🧼 Zsh options
# unsetopt no_match      # evita erros ao expandir padrões que não combinam com arquivos
# unsetopt autocd        # desativa mudança automática de diretório

# 💾 Dotfiles: carregando arquivos modulares
DOTFILES="$HOME/dotfiles"
for file in $DOTFILES/zsh/**/*.zsh; do
  source "$file"
done

