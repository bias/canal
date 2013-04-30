#include <stdio.h>		/* fprintf */
#include <stdlib.h>		/* ??? */
#include <string.h>		/* ??? */
#include <unistd.h>		/* for dup */
#include <fcntl.h>		/* for open */

#include "canal.h"
#include "parse.h" /* for lexer token definitions */

int usage(register char *name) {
	fprintf(stderr, "usage: %s [source]\n", name);
	exit(1);
}

int main(int argc, char **argv) {

	char **argp;
	int cppflag = 1;

	/* FIXME this should really use getopt */
	for (argp = argv; *++argp && **argp == '-'; )
		switch ((*argp)[1]) {
			case 'P':
				cppflag	= 0; break;
			case 'd':
				yydebug	= 1; break;
			default: 
				usage(argv[0]);
		}

	/* XXX let's pray to god that the remaining arg is our file name */
	file_name = *argp;
	in_file = 1;

	if (argp[0] && argp[1])
		usage(argv[0]);
	if (*argp && !freopen(file_name, "r", stdin))
		perror(file_name), exit(1);
	if (cppflag && cpp(file_name))
		perror("C preprocessor"), exit(1);

	return yyparse();
}


/*  ***** ***** ***** ***** ***** ***** *****
 *  Preprocess 
 */

int cpp(char *argv) {
	char *cmd;
	extern FILE *popen();
	int i;

	cmd = (char*) calloc(sizeof(CPP)+strlen(argv)+1, sizeof(char));
	strcpy(cmd, CPP), strcat(cmd, " "), strcat(cmd, argv);
	yyin = popen(cmd, "r");
	free(cmd);

	return 0; /* XXX what? */
}


/*  ***** ***** ***** ***** ***** ***** *****
 *	File Context
 */
void tok_cpp_file(char const *file_spec) {
	char *spec;

	spec = strdup(file_spec);
	strtok(spec, "\"");
	file_context(strtok(NULL, "\""));

	free(spec);
}

/* If it's not our file redirect to /dev/null */
void file_context(char const *m_file_name) {  

	int diff = strcmp(m_file_name, file_name);

	if ( !diff  && in_file) {
		/* nothing */
	} else if ( !diff && !in_file ) {
		/* swap back to stdin */
		fflush(stdout);
		dup2(fd_swap, 1);
		close(fd_swap);
		in_file = 1;
	} else if ( diff && in_file ) {
		/* swap to null */
		fflush(stdout);
		fd_swap = dup(1);
		fd_null = open("/dev/null", O_WRONLY);
		dup2(fd_null, 1);
		close(fd_null);
		in_file = 0;
	} else {
		/* nothing */
	}

}


/*  ***** ***** ***** ***** ***** ***** *****
 *  Symbol table
 */

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


/*
 * Identifier stack
 */

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
