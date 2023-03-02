#!/bin/bash

tmpfile=$(mktemp)
# udafile=~/.task/conf/uda
debugfile=~/.task/debug.log
debug=false
do_not_update=_PLACEHOLDER_
debugheader="


====================
       NEW RUN
====================
"

[ "$1" == "debug" ] && shift && debug=true

# Used to convert string to exact matching regex, escaping special characters
do_regex(){
    # Escapes []*()/" characters
    local escaped
    escaped=$(sed -E 's/([]\[\*\(\)\"\/])/\\\1/g' <<< "$1");
    # And print with regex delimiters, adding beggining and end of line for exact matching
    printf "/^%s\$/" "$escaped"
}

_cleanup(){
    if [[ "$debug" == "true" ]]; then
        echo "$debugheader" >> $debugfile
        cat "$tmpfile" >> $debugfile
    else
        rm -f "$tmpfile" $debugfile
    fi
}
trap _cleanup exit

do_pull(){
  local updated_tasks
  [ -n "$1" ] && export BUGWARRIORRC=$HOME/.bugwarriorrc.$1

  bugwarrior pull > "$tmpfile" 2>&1
  # bugwarrior uda > $udafile

  # Check if taskrc is locked, and create a flag file for it
  if grep -q 'Your taskrc repository is currently locked. Remove the file' "$tmpfile"; then
    touch $HOME/.task/lockedtask
  fi
  updated_tasks=$(grep "Updating task" "$tmpfile" | cut -d"," -f1 | cut -d" " -f3)

  # Tag new tasks
  grep 'Adding task' "$tmpfile" | cut -d' ' -f 3- | while read -r line; do
      echo all | task "$(do_regex "$line")" mod +n -noshow &> /dev/null
  done

  # Tag updated tasks
  tmp_updated_tasks=$(grep "Updating task" "$tmpfile" | cut -d"," -f1 | cut -d" " -f3)

  # Hack to allow excluding tasks
  updated_tasks=$(echo $tmp_updated_tasks | xargs -n1 | grep -vE $do_not_update | xargs)
  if [[ -n $updated_tasks ]]; then
      echo all | task $updated_tasks mod +u -w -noshow &> /dev/null
  fi
}

do_pull "$@"
