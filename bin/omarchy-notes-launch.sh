#!/usr/bin/env bash
# Runs inside the notes terminal before nvim starts (new note only).
set -euo pipefail

NOTES_DIR="${HOME}/notes"
STATE_DIR="${HOME}/.local/state/omarchy"
LISTEN_SOCK="${STATE_DIR}/notes-nvim.sock"
LAST_NOTE="${STATE_DIR}/last-note"

mkdir -p "${NOTES_DIR}" "${STATE_DIR}"

sanitize_name() {
  local s="${1:-}"
  s="${s%.md}"
  s="$(printf '%s' "$s" | tr -d '/\\:*?"<>|\n\r\t')"
  s="$(printf '%s' "$s" | tr ' ' '-')"
  s="$(printf '%s' "$s" | sed -e 's/-\+/-/g' -e 's/^-\+//' -e 's/-\+$//')"
  printf '%s' "$s"
}

default="$(date +note-%Y%m%d-%H%M%S)"
name=""

prompt_name() {
  # Ctrl+C / SIGINT cancel the new note (close the panel).
  trap 'printf "\nCanceled.\n"; exit 130' INT

  printf '\n'
  printf '  New note\n'
  printf '  ────────\n'
  printf '  Enter a name, or press Enter for %s\n' "${default}"
  printf '  Ctrl+C to cancel\n'
  printf '\n'
  printf '  Name: '
  if ! read -e -r name </dev/tty; then
    printf '\nCanceled.\n'
    exit 130
  fi
  trap - INT
}

if [[ -t 0 ]] || [[ -r /dev/tty ]]; then
  prompt_name
fi

name="${name:-${default}}"
name="$(sanitize_name "${name}")"
[[ -z "${name}" ]] && name="${default}"

note_path="${NOTES_DIR}/${name}.md"
printf '%s\n' "${note_path}" > "${LAST_NOTE}"

exec nvim --listen "${LISTEN_SOCK}" \
  -c 'autocmd VimEnter * startinsert' \
  -c "autocmd BufWritePost * silent! writefile([expand('%:p')], '${LAST_NOTE}')" \
  "${note_path}"
