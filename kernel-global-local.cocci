@excluded@
type T;
identifier i;
position p;
@@

(
 T i@p(...);
|
 extern T i@p;
|
 T i@p(...,......);
)

@r@
type T;
identifier i;
position q != excluded.p;
position p : script:python(i) { p[0].current_element == i};
attribute name __randomize_layout;
@@

(
 T i@q@p;
|
 T i@q@p=...;
)

@script:python@
i << r.i;
@@
print (i)
