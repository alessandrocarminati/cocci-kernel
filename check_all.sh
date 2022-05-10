#!/bin/sh
rm -rf /tmp/log*
for i in $(find -type f | egrep -v "./tools/|./Documentation/|./scipts/|./samples/" | egrep "\.c$|\.h$"); do 
	for j in $(spatch  -sp_file  ../trash/global_julia3.cocci $i 2>/dev/null); do echo "${j}@${i}" >> /tmp/log_limited;  done &
	pid1=$!;
	for j in $(spatch  -sp_file  ../trash/global_ale.cocci $i 2>/dev/null); do echo "${j}@${i}" >> /tmp/log_global;  done &
	pid1=$!;
	wait $pid1
	wait $pid2
	done
