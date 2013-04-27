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
	fputs("usage: ", stderr);
	fputs(name, stderr);
	fputs(" [C preprocessor options] [source]\n", stderr);
	exit(1);
}

int main(int argc, char **argv) {

	setbuf(stderr, NULL);

	char **argp;
	int cppflag = 0;

	for (argp = argv; *++argp && **argp == '-'; )
		switch ((*argp)[1]) {
			case 'U':
				cppflag = 1; break;
			case 'd':
				yydebug	= 1; break;
			default: 
				usage(argv[0]);
		}

	if (argp[0] && argp[1])
		usage(argv[0]);
	if (*argp && !freopen(*argp, "r", stdin))
		perror(*argp), exit(1);
	if (cppflag && cpp(argc, argv))
		perror("C preprocessor"), exit(1);

	exit(yyparse());
}

/*
 *		cpp() -- preprocess lex input() through C preprocessor
 */

#ifndef CPP /* filename of C preprocessor */
#define CPP "/usr/bin/cpp"
#endif

int cpp(int argc, char **argv) {
	char **argp, *cmd;
	extern FILE *yyin;	/* for lex input() */
	extern FILE *popen();
	int i;

	for (i=0, argp = argv; *++argp; )
		if (**argp == '-' && index("CDEIUP", (*argp)[1]))
			i += strlen(*argp) + 1;

	if (!(cmd = (char*) calloc(i + sizeof(CPP), sizeof(char))))
		return -1; /* no room */

	strcpy(cmd, CPP);
	for (argp = argv; *++argp; )
		if (**argp == '-' && index("CDEIPU", (*argp)[1]))
			strcat(cmd, " "), strcat(cmd, *argp);

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

	fprintf(stderr, "+++++ +++ + sym_table: ");
	symrec *sym;
	for (sym = sym_table; sym != (symrec *) 0; sym = (symrec *)sym->next)
		fprintf(stderr, "%s, ", sym->name);
	fprintf(stderr, "\n");

	return ptr;
}

ident* push_ident(int sym_type) {
	fprintf(stderr, "\t *pushing %d onto stack\n", sym_type);
	ident *id = (ident *) malloc (sizeof (ident));	
	id->type = sym_type;
	id->previous = (ident *)id_stack; 
	id_stack = id;
	return id;
}

void cur_ident(char const *name) {
	if ( id_stack != NULL ) {
		fprintf(stderr, "\t swap cur name %s to %s\n", id_stack->name, name);
		id_stack->name = name;	
	}
}

void pop_ident() {
	ident *id = id_stack;
	if (id != NULL) {
		if (id->name != NULL)
			put_sym(id->name, id->type);
		else
			fprintf(stderr, "\t no cur name!\n");
		fprintf(stderr, "\t *popping\n");
		if ( id->previous == NULL )
			id_stack = NULL;
		else
			id_stack = id->previous;	
		id->name = NULL;
		free(id);
	} 
}
