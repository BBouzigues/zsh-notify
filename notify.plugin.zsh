# vim: set nowrap filetype=zsh:
# 
# See README.md.
#
fpath=($fpath `dirname $0`)

# Default timeout is 30 seconds.
[[ $NOTIFY_COMMAND_COMPLETE_TIMEOUT == "" ]]  \
  && NOTIFY_COMMAND_COMPLETE_TIMEOUT=30

# Notify an error but only if it took at least $NOTIFY_COMMAND_COMPLETE_TIMEOUT or if terminal is in background
function notify-error {
  local display_mode now diff icon
  start_time=$1
  last_command="$2"
  now=`date "+%s"`
  # FIXME: Ugly 
  icon=${ZDOTDIR:-$HOME}/.zprezto/modules/notify/external/warning.png
  
  ((diff = $now - $start_time ))
  if (( $diff > $NOTIFY_COMMAND_COMPLETE_TIMEOUT )); then
	  display_mode=always	  
  else
	  display_mode=background
  fi
  notify-if-background -f "${display_mode}" -t "${last_command}" --icon "$icon" <<< "Failure after ${diff} sec"&!	  
}

# Notify of successful command termination, but only if it took at least
# $NOTIFY_COMMAND_COMPLETE_TIMEOUT seconds (and if the terminal is in background).
function notify-success() {
  local now diff start_time last_command

  start_time=$1
  last_command="$2"
  now=`date "+%s"`

  ((diff = $now - $start_time ))
  if (( $diff > $NOTIFY_COMMAND_COMPLETE_TIMEOUT )); then
    notify-if-background -f always -t "$last_command" <<< "Success in ${diff} sec"&!
  fi
}

# Notify about the last command's success or failure.
function notify-command-complete() {
  last_status=$?
  if [[ $last_status -gt "0" ]]; then
    notify-error "$start_time" "$last_command"
  elif [[ -n $start_time ]]; then
    notify-success "$start_time" "$last_command"
  fi
  unset last_command start_time last_status
}

function store-command-stats() {
  last_command=$1
  last_command_name=${1[(wr)^(*=*|sudo|ssh|-*)]}
  start_time=`date "+%s"`
}

if [[ -z "$PPID_FIRST" ]]; then
  export PPID_FIRST=$PPID
fi

autoload add-zsh-hook
autoload -U tell-terminal
autoload -U tell-iterm2
autoload -U notify-if-background
add-zsh-hook preexec store-command-stats
add-zsh-hook precmd notify-command-complete
