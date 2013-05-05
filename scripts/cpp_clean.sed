# Mac OSX gcc specific constructs
s/typedef __builtin_va_list.*$/typedef int __builtin_va_list;\
&/
s/__builtin_va_arg.*;/__builtin_va_arg(argp, argp);/
s/__inline_*//
s/__attribute__.*;/;/
s/__asm(.*)//
s/(^)/(*)/g
# FIXME grammar problem?
s/const struct fd_set/const fd_set/
