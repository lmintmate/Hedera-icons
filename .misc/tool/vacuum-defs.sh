#/bin/sh
_basedir="$(dirname "$(readlink -f "${0}")")"
set -e
cd "$_basedir"
	#for _svg in $(find . -mindepth 1 -maxdepth 3 -path "*/pool/*" -wholename "*.svg"); do
		#inkscape -T --vacuum-defs  $_svg -l $_svg
	#done
	for _dir in $(find . -mindepth 1 -maxdepth 3 -type d -name "img");do
		cd "$_dir"
		parallel --no-notice -j "$(expr $(nproc) \* 4)" inkscape -T --vacuum-defs -l {} {} ::: *.svg
		cd "$_basedir"
	done
