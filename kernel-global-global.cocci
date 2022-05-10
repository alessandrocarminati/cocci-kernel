@r@
identifier i;
declarer name EXPORT_SYMBOL;
declarer name EXPORT_SYMBOL_GPL;
@@

(
 EXPORT_SYMBOL(i);
|
 EXPORT_SYMBOL_GPL(i);
)



@rr@
type T;
identifier i = r.i;
expression E;
@@

(
 T i;
|
 T i=E;
)



@script:python@
i << rr.i;
@@
print (i)
