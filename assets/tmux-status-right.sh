#!/usr/bin/env bash

pane_pid="$1"

bg_base="#1a1b26"
bg_dark="#24283b"
bg_mid="#414868"
bg_soft="#3b4261"
blue="#7aa2f7"
cyan="#7dcfff"
green="#9ece6a"
yellow="#e0af68"
red="#f7768e"
fg="#c0caf5"

segment() {
  local left_bg="$1"
  local bg="$2"
  local fg_color="$3"
  local text="$4"

  printf '#[fg=%s,bg=%s]#[fg=%s,bg=%s] %s ' "$bg" "$left_bg" "$fg_color" "$bg" "$text"
}

resolve_ssh_target() {
  local ssh_args="$1"
  local target
  target=$(echo "$ssh_args" | awk '{ for (i=NF; i>0; i--) if ($i !~ /^-/) { print $i; break } }')

  local resolved
  resolved=$(ssh -G "$target" 2>/dev/null)
  local user
  user=$(echo "$resolved" | awk '/^user / {print $2}')
  local hostname
  hostname=$(echo "$resolved" | awk '/^hostname / {print $2}')

  if [[ -n "$user" && -n "$hostname" ]]; then
    echo "${user}@${hostname}"
  fi
}

get_children() {
  local parent=$1
  ps -eo ppid=,pid= 2>/dev/null | awk -v ppid="$parent" '$1 == ppid { print $2 }'
}

detect_context() {
  local queue=("$1")
  local remote_userhost=""
  local root_shell_found=""

  while [[ ${#queue[@]} -gt 0 ]]; do
    local pid="${queue[0]}"
    queue=("${queue[@]:1}")

    local proc_user
    proc_user=$(ps -p "$pid" -o user= 2>/dev/null | xargs)
    local cmd
    cmd=$(ps -p "$pid" -o command= 2>/dev/null)

    # Detect SSH session
    if [[ -z "$remote_userhost" && "$cmd" =~ ^ssh[[:space:]]+(.+) ]]; then
      remote_userhost=$(resolve_ssh_target "${BASH_REMATCH[1]}")
    fi

    # Detect root-owned interactive shell
    if [[ "$proc_user" == "root" && "$cmd" =~ (^|[ /])-?(zsh|bash|sh|fish|sh)$ ]]; then
      root_shell_found="yes"
    fi

    for child in $(get_children "$pid"); do
      queue+=("$child")
    done
  done

  if [[ "$root_shell_found" == "yes" ]]; then
    if [[ -n "$remote_userhost" ]]; then
      echo "root@${remote_userhost#*@}"
    else
      echo "root@$(hostname -s)"
    fi
  elif [[ -n "$remote_userhost" ]]; then
    echo "$remote_userhost"
  else
    local user
    user=$(ps -p "$1" -o user= 2>/dev/null | xargs)
    if [[ -z "$user" ]]; then
      user="${USER:-local}"
    fi
    echo "$user@$(hostname -s)"
  fi
}

identity_segment() {
  local userhost
  userhost=$(detect_context "$pane_pid")
  local user="${userhost%@*}"
  local host="${userhost#*@}"
  local local_host
  local_host=$(hostname -s)

  local location_icon="󰖟"
  local role_icon=""
  local color="$fg"

  if [[ "$host" != "$local_host" ]]; then
    location_icon="󰌘"
    color="$cyan"
  fi

  if [[ "$user" == "root" ]]; then
    role_icon="󰌾"
    color="$red"
  fi

  printf '%s %s %s' "$location_icon" "$role_icon" "$userhost"
}

vpn_segment() {
  local vpn_name=""

  if command -v wg >/dev/null 2>&1; then
    vpn_name=$(wg show interfaces 2>/dev/null | awk '{ print $1; exit }')
  fi

  if [[ -z "$vpn_name" ]] && command -v scutil >/dev/null 2>&1; then
    vpn_name=$(scutil --nc list 2>/dev/null | awk -F '"' '/\(Connected\)/ { print $2; exit }')
  fi

  if [[ -n "$vpn_name" ]]; then
    printf '󰖂 %s' "$vpn_name"
  else
    printf '󰖂 off'
  fi
}

kubernetes_segment() {
  if ! command -v kubectl >/dev/null 2>&1; then
    printf '󱃾 none'
    return
  fi

  local context
  context=$(kubectl config current-context 2>/dev/null)
  if [[ -z "$context" ]]; then
    printf '󱃾 none'
    return
  fi

  local namespace
  namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
  if [[ -z "$namespace" ]]; then
    namespace="default"
  fi

  printf '󱃾 %s/%s' "$context" "$namespace"
}

battery_segment() {
  if ! command -v pmset >/dev/null 2>&1; then
    printf '󰁹 --'
    return
  fi

  local raw
  raw=$(pmset -g batt 2>/dev/null | awk 'NR == 2 { print }')
  local percent
  percent=$(printf '%s\n' "$raw" | grep -Eo '[0-9]+%' | head -n 1)
  local charging=""

  case "$raw" in
    *charging*|*AC\ Power*) charging="󰂄 " ;;
    *) charging="󰁹 " ;;
  esac

  if [[ -n "$percent" ]]; then
    printf '%s%s' "$charging" "$percent"
  else
    printf '󰁹 --'
  fi
}

identity=$(identity_segment)
vpn=$(vpn_segment)
kubernetes=$(kubernetes_segment)
battery=$(battery_segment)
time_now=$(date '+%H:%M')

segment "$bg_base" "$bg_soft" "$fg" "$identity"
segment "$bg_soft" "$bg_mid" "$green" "$vpn"
segment "$bg_mid" "$bg_dark" "$cyan" "$kubernetes"
segment "$bg_dark" "$bg_soft" "$yellow" "$battery"
segment "$bg_soft" "$blue" "$bg_base" " $time_now"
