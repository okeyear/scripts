#!/bin/bash

tee -a ~/.bashrc <<EOF
# git branch: show in bash PS1

function git_branch {
  local branch=\$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ \$branch ]; then printf " [%s]" \$branch; fi
}
PS1="\u@\h: \[\033[0;36m\]\w\[\033[0m\]\[\033[0;32m\]\\\$(git_branch)\[\033[0m\] \$ "
EOF

source ~/.bashrc

# \$(git_branch )
# git_branch 是一个函数，因此PS1中要写成上面的； 如果转义， 那么就是\\\$(git_branch )
