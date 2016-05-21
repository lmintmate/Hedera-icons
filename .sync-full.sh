#!/bin/sh
if [ ! -t 0 ]; then
x-terminal-emulator -e "$0"
exit 0
fi
basedir=`dirname "$(readlink -f "${0}")"`
cd ${basedir}
rm -rf .git
git init
git add .
MESSAGE=$(yad --title="Commit MSG" --no-buttons --geometry=400 --entry)
git commit -m "$MESSAGE"
git remote add origin https://github.com/sixsixfive/ivy.git
git push -u --force origin master
echo "done"
sleep 5
exit