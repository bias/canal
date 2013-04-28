# Mac OSX gcc specific constructs
s/^.*__builtin_va_list.*$/typedef void * __builtin_va_list;\
&/
s/__inline_*//
s/__attribute__.*;/;/
s/__asm.*;/;/
s/(^)/(*)/
