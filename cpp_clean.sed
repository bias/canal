# Mac OSX gcc specific constructs
s/^.*__builtin_va_list.*$/typedef int __builtin_va_list;\
&/
# XXX grammar problem
s/const struct fd_set/const fd_set/
s/__inline_*//
s/__attribute__.*;/;/
s/__asm(.*)//
s/(^)/(*)/g
