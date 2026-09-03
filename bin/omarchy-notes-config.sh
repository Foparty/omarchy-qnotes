# Shared config loader. Source from the notes scripts; call omarchy_notes_load_config.
# Sets NOTES_DIR, EXIT_INSERT_ON_HIDE (0/1), SAVE_ON_HIDE (0/1).

omarchy_notes_config_path() {
  printf '%s/omarchy-notes/config' "${XDG_CONFIG_HOME:-${HOME}/.config}"
}

omarchy_notes_trim() {
  local s="${1-}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "${s}"
}

omarchy_notes_strip_quotes() {
  local s="${1-}"
  if (( ${#s} >= 2 )); then
    local first="${s:0:1}" last="${s: -1}"
    if [[ "${first}" == "${last}" && ( "${first}" == '"' || "${first}" == "'" ) ]]; then
      s="${s:1:${#s}-2}"
    fi
  fi
  printf '%s' "${s}"
}

omarchy_notes_expand_dir() {
  local s="${1-}"
  if [[ "${s}" == "~" ]]; then
    s="${HOME}"
  elif [[ "${s}" == "~/"* ]]; then
    s="${HOME}/${s:2}"
  fi
  s="${s//\$\{HOME\}/${HOME}}"
  s="${s//\$HOME/${HOME}}"
  printf '%s' "${s}"
}

omarchy_notes_parse_bool() {
  local v fallback="${2:-1}"
  v="$(printf '%s' "${1-}" | tr '[:upper:]' '[:lower:]')"
  case "${v}" in
    1|true|yes|on) printf '1' ;;
    0|false|no|off) printf '0' ;;
    *) printf '%s' "${fallback}" ;;
  esac
}

omarchy_notes_load_config() {
  NOTES_DIR="${HOME}/notes"
  EXIT_INSERT_ON_HIDE=1
  SAVE_ON_HIDE=1

  local file line key val
  file="$(omarchy_notes_config_path)"
  if [[ -f "${file}" ]]; then
    while IFS= read -r line || [[ -n "${line}" ]]; do
      line="$(omarchy_notes_trim "${line}")"
      [[ -z "${line}" || "${line}" == \#* ]] && continue
      [[ "${line}" != *=* ]] && continue
      key="$(omarchy_notes_trim "${line%%=*}")"
      val="$(omarchy_notes_trim "${line#*=}")"
      val="$(omarchy_notes_strip_quotes "${val}")"
      case "${key}" in
        notes_dir)
          NOTES_DIR="$(omarchy_notes_expand_dir "${val}")"
          ;;
        exit_insert_on_hide)
          EXIT_INSERT_ON_HIDE="$(omarchy_notes_parse_bool "${val}" 1)"
          ;;
        save_on_hide)
          SAVE_ON_HIDE="$(omarchy_notes_parse_bool "${val}" 1)"
          ;;
      esac
    done < "${file}"
  fi

  if [[ -n "${OMARCHY_NOTES_DIR:-}" ]]; then
    NOTES_DIR="$(omarchy_notes_expand_dir "${OMARCHY_NOTES_DIR}")"
  fi
  if [[ -n "${OMARCHY_NOTES_EXIT_INSERT_ON_HIDE:-}" ]]; then
    EXIT_INSERT_ON_HIDE="$(omarchy_notes_parse_bool "${OMARCHY_NOTES_EXIT_INSERT_ON_HIDE}" "${EXIT_INSERT_ON_HIDE}")"
  fi
  if [[ -n "${OMARCHY_NOTES_SAVE_ON_HIDE:-}" ]]; then
    SAVE_ON_HIDE="$(omarchy_notes_parse_bool "${OMARCHY_NOTES_SAVE_ON_HIDE}" "${SAVE_ON_HIDE}")"
  fi
}
