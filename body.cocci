@rr@
type T;
statement list sl;
parameter list pl;
@@


T fill_stats_for_tgid( pl ) {
sl
}


@script:python@
t << rr.T;
sl << rr.sl;
pl << rr.pl;
@@
print ("{0} fill_stats_for_tgid ({1}){{".format(t,pl))
print (sl)
print ('}')
