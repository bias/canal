/*
 * 		main() -- possibly run C preprocessor before yyparse()
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "c.h"

/* The symbol table: a chain of `struct symrec'.  */
symrec *sym_table;

int usage(register char *name) {
	fputs("usage: ", stderr);
	fputs(name, stderr);
	fputs(" [C preprocessor options] [source]\n", stderr);
	exit(1);
}

int main(int argc, char **argv) {
	char **argp;
	int cppflag = 0;

	for (argp = argv; *++argp && **argp == '-'; )
		switch ((*argp)[1]) {
			default: 
				usage(argv[0]);
			case 'C':
			case 'D':
			case 'E':
			case 'I':
			case 'P':
			case 'U':
				cppflag = 1;
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

/* NOTE C fails to be LR(1) because of a conflict with identifier and typedef-name */
/* XXX so, we're going to skip this */
int sym_type(const char *s) {
	/* TYPEDEF_NAME ENUMERATION_CONSTANT IDENTIFIER */
	return 0;
}

symrec* put_sym(const char *sym_name, int sym_type) {
       symrec *ptr = (symrec *) malloc (sizeof (symrec));
       ptr->name = (char *) malloc (strlen (sym_name) + 1);
       strcpy (ptr->name,sym_name);
       ptr->type = sym_type;
       ptr->value.var = 0; /* Set value to 0 even if fctn.  */
       ptr->next = (struct symrec *)sym_table;
       sym_table = ptr;
       return ptr;
}

symrec* get_sym(const char *sym_name) {
       symrec *ptr;
       for (ptr = sym_table; ptr != (symrec *) 0;
            ptr = (symrec *)ptr->next)
         if (strcmp (ptr->name,sym_name) == 0)
           return ptr;
       return 0;
}
