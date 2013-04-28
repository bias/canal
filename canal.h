extern int yyparse();

int cpp(char *);


/*
 * File Context
 *
 * In order to resolve symbols we must first run the preprocessor which will expand macros viz #include.
 * However, we're not necessarily interested in the stats of the included files, so we'll track where symbols are
 * defined and allow a second pass that discardes macros and uses the previously discovered external definitions
 * but forgets the type/enum defs in that file.
 */

void file_context(char const *, int);

typedef struct fcontext {
  char *name;
  int line;
} file_context;

extern file_context f_context;


/*
 * Symbol table
 */

typedef struct symrec {
  char *name;
  int type;
  char *file;
  struct symrec *next;
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
