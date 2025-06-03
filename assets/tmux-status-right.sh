#!/usr/bin/env bash

pane_pid="$1"

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
  ps -eo ppid=,pid= | awk -v ppid="$parent" '$1 == ppid { print $2 }'
}

detect_context() {
  local queue=("$1")
  local remote_userhost=""
  local root_shell_found=""

  while [[ ${#queue[@]} -gt 0 ]]; do
    local pid="${queue[0]}"
    queue=("${queue[@]:1}")

    local proc_user
    proc_user=$(ps -p "$pid" -o user= | xargs)
    local cmd
    cmd=$(ps -p "$pid" -o command=)

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
    local user=$(ps -p "$1" -o user= | xargs)
    echo "$user@$(hostname -s)"
  fi
}

userhost=$(detect_context "$pane_pid")
user="${userhost%@*}"
host="${userhost#*@}"

local_host=$(hostname -s)

if [[ "$host" == "$local_host" ]]; then
  if [[ "$user" == "root" ]]; then
    echo "#[fg=yellow,bold]🧰 $user@$host#[default]"
  else
    echo "💻 $user@$host"
  fi
else
  if [[ "$user" == "root" ]]; then
    echo "#[fg=red,bold]🔥 $user@$host#[default]"
  else
    echo "🌐 $user@$host"
  fi
fi
