Quick test for the scripts:
This following oneliner scans the kernel sources and reports global variables list in two files:
* /tmp/log_global
* /tmp/log_limited

```
rm -rf /tmp/log* && for i in $(find -type f | egrep -v "./tools/|./Documentation/|./scipts/|./samples/" | egrep "\.c$|\.h$"); do for j in $(spatch  -sp_file  ../trash/global_julia3.cocci $i 2>/dev/null); do echo "${j}@${i}" >> /tmp/log_limited;  done; for j in $(spatch  -sp_file  ../trash/global_ale.cocci $i 2>/dev/null); do echo "${j}@${i}" >> /tmp/log_global;  done; done
```
count numbers by
```
l=$(cat /tmp/log_limited | wc -l); g=$(cat /tmp/log_global | wc -l);echo "local=${l} Global=${g}"
```
example outoput
```
local=187293 Global=2167
```
