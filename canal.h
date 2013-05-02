/*  ***** ***** ***** ***** ***** ***** *****
 *  Preprocess 
 */

/* filename of C preprocessor */
#ifndef CPP 
#define CPP "./cpp_clean"
#endif

int cpp(char *);


/*  ***** ***** ***** ***** ***** ***** *****
 *  File Context
 *
 * In order to resolve symbols we must first run the preprocessor which will expand macros viz #include.
 * However, we're not necessarily interested in the stats of the included files, 
 * so we'll switch on and off output depending on the file which is something demarcated by the preprocessor.
 */

char *file_name;
int fd_swap, fd_null;
int in_file;

/* Tokenize preprocessor file statements */
void tok_cpp_file(char const *);

/* If it's not our file redirect to /dev/null */
void file_context(char const *);


/*  ***** ***** ***** ***** ***** ***** *****
 *  Symbol table
 */

typedef struct symrec {
  char *name;
  int type;
  struct symrec *next;
} symrec;

symrec *sym_table;

/* put symbol in table */
symrec *put_sym(char const *, int);

/* resolve ident/sym/enum for lexer */
int sym_type(const char *);


/*  ***** ***** ***** ***** ***** ***** *****
 * Identifier stack
 * 
 * typedef_name will always resolve as either 
 *  - the last ident before a semicolon 
 *  - the ident previous to a struct/union block
 *
 *  enumeration_constant can be directly put in the table 
 *  it reduces immediately after shifting
 */

typedef struct ident {
  int type;
  char const *name;
  struct ident *previous; 
} ident;

ident *id_stack;

/* push new typedef onto stack */
ident *push_ident(int);

/* use most current ident for the top's name */
void cur_ident(char const *);

/* resolve the typedef as the current name */
void pop_ident();


/*  ***** ***** ***** ***** ***** ***** *****
 *  Syntax Tree
 */


/* nodes in the abstract syntax tree */
typedef struct ast {
  char *type;
  char *value;
  int num;
  struct ast **children;
} ast;

ast *tree;

/* build and AST, va_list on (struct ast *) */
ast *new_ast(char const *, int, ...);

/* free an AST */
//void treefree(ast *);

int cur_ast_num;
void print_ast(ast *);
