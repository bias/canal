typedef int thor;

typedef double (*func_t) (double test);

typedef struct tnode *Tptr;

typedef Tptr *TPptr;

typedef union YYSTYPE {
  int fn;
  char *a;
} YYSTYPE;

extern YYSTYPE yylval;

typedef union {
 char __mbstate8[128];
 long long _mbstateL;
} __mbstate_t;

typedef __mbstate_t __darwin_mbstate_t;
