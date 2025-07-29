# Redefine o curl para usar seu script Python
alias curl='python3 ~/python_tools/curl_proxy.py'

# Copiar arquivos selecionados com fzf
fzfcopy() {
  local dir="."
  local ext=""

  # Argumentos posicionais
  if [[ -n "$1" && -d "$1" ]]; then
    dir="$1"
    shift
  fi

  if [[ -n "$1" ]]; then
    ext="$1"
  fi

  # Monta padrão de busca
  local pattern="*"
  [[ -n "$ext" ]] && pattern="*.$ext"

  # Define preview (usa bat se tiver, senão cat)
  local preview_cmd="cat {}"
  if command -v bat &>/dev/null; then
    preview_cmd="bat --style=numbers --color=always {}"
  fi

  # Busca com preview + múltiplos arquivos
  find "$dir" -type f -name "$pattern" 2>/dev/null \
    | fzf --multi --preview="$preview_cmd" --preview-window=right:60% \
    | while IFS= read -r file; do
        echo "<$file>"
        cat "$file"
        echo "</$file>"
        echo
      done | xclip -sel copy
}

# Fuzzy search + abrir com Neovim
fvim() {
  local dir="."
  local ext=""

  # Argumentos posicionais
  if [[ -n "$1" && -d "$1" ]]; then
    dir="$1"
    shift
  fi

  if [[ -n "$1" ]]; then
    ext="$1"
  fi

  # Monta padrão de busca
  local pattern="*"
  [[ -n "$ext" ]] && pattern="*.$ext"

  # Define preview (usa bat se disponível)
  local preview_cmd="cat {}"
  if command -v bat &>/dev/null; then
    preview_cmd="bat --style=numbers --color=always {}"
  fi

  # Busca com preview
  local file
  file=$(find "$dir" -type f -name "$pattern" 2>/dev/null \
    | fzf --preview="$preview_cmd" --preview-window=right:60%) || return

  [[ -n "$file" ]] && nvim "$file"
}

timer() {
  local dcmd=$(command -v gdate || command -v date)
  local start=$($dcmd +%s%3N)
  "$@"
  local end=$($dcmd +%s%3N)
  local duration_ms=$((end - start))
  echo "⏱️ Tempo: ${duration_ms}ms"
}

zcd() {
  local dir
  dir=$(zoxide query -l | fzf --reverse)
  [[ -n "$dir" ]] && cd "$dir"
}
