extern int yyparse();

int cpp(int, char **);


typedef double (*func_t) (double);


struct symrec {
  char *name;
  int type;
  union {
    double var;
    func_t fnctptr;
  } value;
  struct symrec *next;
};

typedef struct symrec symrec;


extern symrec *sym_table;

int sym_type(const char *);

symrec *put_sym(char const *, int);
symrec *get_sym(char const *);
