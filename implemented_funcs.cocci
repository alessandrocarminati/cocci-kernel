@rr@
type T;
identifier i;
@@


T i( ... ) {
...
}


@script:python@
i << rr.i;
@@
print (i)

