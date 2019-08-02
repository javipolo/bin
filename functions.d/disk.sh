# Recursive du showing the top 20
function dumax {
  # Thanks for this function Manu :)
  du -mx $1 | sort -nr \
    | awk '{ if ($1 >= 1000) printf "%s => %0.2f G\n", $2, ($1/1024)
             else printf "%s => %s M\n", $2, $1 }\' \
    | head -20 
}
