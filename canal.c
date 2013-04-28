#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "canal.h"
#include "parse.h" /* for symbol definitions */

/* The symbol table */
symrec *sym_table;

/* The identifier resolution stack */
ident *id_stack;

extern int yydebug;

int usage(register char *name) {
	fprintf(stderr, "usage: %s [source]\n", name);
	exit(1);
}

int main(int argc, char **argv) {

	char **argp;
	int cppflag = 0;

	int yyreturn;

	for (argp = argv; *++argp && **argp == '-'; )
		switch ((*argp)[1]) {
			case 'U':
				cppflag	= 1; break;
			case 'd':
				yydebug	= 1; break;
			default: 
				usage(argv[0]);
		}

	if (argp[0] && argp[1])
		usage(argv[0]);
	if (*argp && !freopen(*argp, "r", stdin))
		perror(*argp), exit(1);
	if (cppflag && cpp(*argp))
		perror("C preprocessor"), exit(1);

	yyreturn = yyparse();

	return yyreturn;
}

/*
 *		cpp() -- preprocess lex input() through C preprocessor
 */
#ifndef CPP /* filename of C preprocessor */
#define CPP "./cpp_clean"
#endif

int cpp(char *argv) {
	char *cmd;
	extern FILE *yyin;	/* for lex input() */
	extern FILE *popen();
	int i;

	cmd = (char*) calloc(sizeof(CPP)+strlen(argv)+1, sizeof(char));

	strcpy(cmd, CPP);
	strcat(cmd, " "); 
	strcat(cmd, argv);

	if ( (yyin = popen(cmd, "r")) )
		i = 0; /* all's well */
	else
		i = -1;
	free(cmd);

	return i;
}

int sym_type(const char *sym_name) {
	symrec *ptr;
	for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next)
		if (strcmp(ptr->name,sym_name) == 0)
			return ptr->type;
	return IDENTIFIER;
}

symrec* put_sym(const char *sym_name, int sym_type) {

	symrec *ptr = (symrec *) malloc (sizeof (symrec));
	ptr->name = (char *) malloc (strlen (sym_name) + 1);
	strcpy (ptr->name,sym_name);
	ptr->type = sym_type;
	ptr->value = 0;  
	ptr->next = (struct symrec *)sym_table;
	sym_table = ptr;

	/*fprintf(stderr, "+++++ +++ + sym_table: ");
	symrec *sym;
	for (sym = sym_table; sym != (symrec *) 0; sym = (symrec *)sym->next)
		fprintf(stderr, "%s, ", sym->name);
	fprintf(stderr, "\n");
	*/
	return ptr;
}

ident* push_ident(int sym_type) {
	//fprintf(stderr, "\t *pushing %d onto stack\n", sym_type);
	ident *id = (ident *) malloc (sizeof (ident));	
	id->type = sym_type;
	id->previous = (ident *)id_stack; 
	id_stack = id;
	return id;
}

void cur_ident(char const *name) {
	if ( id_stack != NULL ) {
		//fprintf(stderr, "\t swap cur name %s to %s\n", id_stack->name, name);
		id_stack->name = name;	
	}
}

void pop_ident() {
	ident *id = id_stack;
	if (id != NULL) {
		if (id->name != NULL & id->type != 0)
			put_sym(id->name, id->type);
		//else
		//	fprintf(stderr, "\t no cur name!\n");
		//fprintf(stderr, "\t *popping\n");
		if ( id->previous == NULL )
			id_stack = NULL;
		else
			id_stack = id->previous;	
		id->name = NULL;
		free(id);
	} 
}
