extern int yyparse();

int cpp(char *);

/*
 * Symbol table
 */

/* Data type for links in the chain of symbols.  */
typedef struct symrec {
  char *name;  /* name of symbol */
  int type;    /* type of symbol: ident, type_def_name, enumeration constant */
  int value;   /* incase we want to save cont values */
  struct symrec *next;  /* link field */
} symrec;

/* The symbol table: a chain of `struct symrec'.  */
extern symrec *sym_table;

symrec *put_sym(char const *, int);
int sym_type(const char *);


/*
 * Identifier stack
 * 
 * typedef_name will always resolve as either 
 *  - the last ident before a semicolon 
 *  - the ident previous to a struct/union block
 *
 *  enumeration_constant can be directly put in the table
 */

typedef struct ident {
  int type;
  char const *name;
  struct ident *previous; 
} ident;

extern ident *id_stack;

/* push new typedef onto stack */
ident *push_ident(int);

/* use most current ident for the top's name */
void cur_ident(char const *);

/* resolve the typedef as the current name */
void pop_ident();
