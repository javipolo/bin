#!/bin/bash

tmpfile=$(mktemp)
udafile=~/.task/conf/uda
debug=false

[ "$1" == "debug" ] && debug=true
[ "$debug" == "true" ] && tmpfile=/tmp/task.log
_cleanup(){
    [ "$debug" != "true" ] && rm -f $tmpfile
}
trap _cleanup exit

bugwarrior pull > $tmpfile 2>&1
bugwarrior uda > $udafile

updated_tasks=$(grep "Updating task" $tmpfile | cut -d"," -f1 | cut -d" " -f3)

# Used to convert string to exact matching regex, escaping special characters
do_regex(){
    # Escapes []*()/" characters
    local escaped=$(sed -E 's/([]\[\*\(\)\"\/])/\\\1/g' <<< $1);
    # And print with regex delimiters, adding beggining and end of line for exact matching
    printf "/^${escaped}\$/"
}

# Tag new tasks
grep 'Adding task' $tmpfile | cut -d' ' -f 3- | while read -r line; do
    echo all | task "$(do_regex "$line")" mod +n &> /dev/null
done

# Tag updated tasks
updated_tasks=$(grep "Updating task" $tmpfile | cut -d"," -f1 | cut -d" " -f3)
if [[ ! -z $updated_tasks ]]; then
    echo all | task $updated_tasks mod +u -w &> /dev/null
fi
