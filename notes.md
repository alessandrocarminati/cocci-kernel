#collect implemented function
```
for i in $(find -type f| grep "\.[ch]"; ); do psql -h dbs.hqhome163.com kernel -c "select * from symbols  where file='$i'"| grep -q "(0 rows)" && for j in $(spatch  -sp_file  ~/src/implemented_funcs.cocci $i 2>/dev/null); do psql -h dbs.hqhome163.com kernel -c "insert into symbols (symbol, file, exported) values ('$j', '$i', false);"; echo "$i  -- $j"; done; done
```

#continue interrupted functio collection
```
for i in $(psql -t -A -F"," -h dbs.hqhome163.com kernel -c "select id,symbol,file from symbols;"); do id=$(echo $i | cut -d, -f1); s=$(echo $i | cut -d, -f2); f=$(echo $i | cut -d, -f3); grep -qE "EXPORT_SYMBOL[_A-Z]+\($s\)" $f && sql="update symbols set exported=true where id=$id" && psql -h dbs.hqhome163.com kernel -c "$sql" && echo "$sql"; done
```

#example test symbol exported
```
fn="./fs/char_dev.c";for i in $(psql -h dbs.hqhome163.com kernel -t -A -F","  -c "select symbol from symbols  where file='${fn}'"); do grep -E "EXPORT_SYMBOL[_A-Z]*\($i\)" ${fn}; done
```

#indent - awk function body extraction
abbandoned since distribution binary is bugged (double free), and the git version fails to indent a couple of kernel files e.g. `./mm/slab.c`
```
indent -st -orig "./fs/char_dev.c" | awk 'BEGIN { state = 0; last = ""; } $0 ~ /^'register_chrdev_region'\(/ { print last; state = 1; } { if (state == 1) print; } $0 ~ /^}/ { if (state) state = 2; } { last = $0; }' | spatch  -sp_file  ../called_funcs.cocci  --opt-c /dev/stdin 2>/dev/null
```

#example test symbol is a macro 
```
grep -rE "^#define +DEFINE_DYNAMIC_DEBUG_METADATA[ \t]+.*$" arch block certs crypto drivers fs include init ipc kernel lib mm net security sound usr virt
```

#test sql query to insert a cross reference
```
insert into calls (caller, callee) select (select id from symbols where symbol ='register_chrdev_region'), id from symbols where symbol ='IS_ERR';
```

# collect cross referencies in the mm directory
```
for j in $(psql -t -A -F"," -h dbs.hqhome163.com kernel -c "select symbol,file from symbols  where file~'^./mm/*'"); do symb=$(echo $j| cut -d, -f1); fn=$(echo $j| cut -d, -f2); echo "$j -- symb=$symb, file=$fn"; for i in $(indent -st -orig "$fn" | awk 'BEGIN { state = 0; last = ""; } $0 ~ /^'$symb'\(/ { print last; state = 1; } { if (state == 1) print; } $0 ~ /^}/ { if (state) state = 2; } { last = $0; }' | spatch  -sp_file  ../called_funcs.cocci  --opt-c /dev/stdin 2>/dev/null); do  psql -h dbs.hqhome163.com kernel -c "insert into calls (caller, callee) select (select id from symbols where symbol ='${symb}' and file='${fn}'), id from symbols where symbol ='$i';"; done; done
```

# update the symbol table schema to host macros
ALTER TABLE symbols ADD COLUMN type VARCHAR (15);
update symbols set type='func';


# collect for macros
```
for i in $(find -type f | grep "\.[ch]$"); do for j in $(grep -E "^#define +[a-zA-Z_]+\(" $i | sed -r 's/^#define +([a-zA-Z_]+)\(.*/\1/'|sort|uniq); do psql -h dbs.hqhome163.com kernel -c  "insert into symbols (symbol, file, exported, type) values ('$j', '$i', false, 'macro')"; done; done
```

# test coccinelle based function body extraction
```
i="fixup_slab_list" && cat ../body.cocci.template | sed -e "s/##name##/$i/g" >/tmp/x.cocci && spatch -sp_file  /tmp/x.cocci ./mm/slab.c 
```


