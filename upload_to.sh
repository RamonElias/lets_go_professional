#!/bin/bash

# commit_message='updated' ; dt=`date '+%d/%m/%Y_%H:%M:%S'` ; git add . ; git commit -m "$commit_message $dt"
# git push --set-upstream origin --all

COMMIT_MESSAGE='updated'
DT=`date '+%d/%m/%Y_%H:%M:%S'`
git add .
git commit -m "$COMMIT_MESSAGE $DT"
git push --set-upstream origin --all

# BODY1='{"title":"title1","year":year1,"runtime":"n mins","genres":["one","two","three"]}'
# BODY2='{"title":"title2","year":year2,"runtime":"n mins","genres":["one","two","three"]}'
# BODY3='{"title":"title3","year":year3,"runtime":"n mins","genres":["one","two","three"]}'
#
# declare -A movies=(
#   [BODY1]="$BODY1"
#   [BODY2]="$BODY2"
#   [BODY3]="$BODY3"
# )
#
# for movie in "${movies[@]}"; do
#   echo "$movie"
#   echo "# ========================================================================= #"
# done
