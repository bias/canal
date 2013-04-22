extern int yyparse();

int cpp(int, char **);

/* Data type for links in the chain of symbols.  */
struct symrec {
  char *name;  /* name of symbol */
  int type;    /* type of symbol: ident, type_def_name, enumeration constant */
  int value;   /* incase we want to save cont values */
  struct symrec *next;  /* link field */
};

typedef struct symrec symrec;

/* The symbol table: a chain of `struct symrec'.  */
extern symrec *sym_table;

int sym_type(const char *);
symrec *put_sym(char const *, int);
