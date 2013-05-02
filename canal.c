#include <stdio.h>		/* fprintf */
#include <stdlib.h>		/* ??? */
#include <string.h>		/* ??? */
#include <unistd.h>		/* for dup */
#include <fcntl.h>		/* for open */
#include <stdarg.h>		/* for va_list */

#include "canal.h"
#include "parse.h" /* for lexer token definitions */

/*  ***** ***** ***** ***** ***** ***** *****
 *  External Bison constructs
 */

extern int yyparse();
extern int yydebug;
extern FILE *yyin;	


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


	yyparse();

	/* we need to try to swap file contexts back to normal */
	file_context(file_name); 
	cur_ast_num = 0;
	tree->num = 0;
	print_ast(tree);	

	return 0;
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
void file_context(char const *fname) {  
	int diff;
	if ( fname != NULL )
		diff = strcmp(fname, file_name);
	else
		diff = 1;

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
	int type = 0;
	symrec *ptr;
	for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next) {
		if (strcmp(ptr->name,sym_name) == 0) {
			type = ptr->type;
		   	break;
		}
	}
	switch (type) {
		case TYPEDEF_NAME:
			return(type);
		case ENUMERATION_CONSTANT:
			return(type);
		default:
			return(IDENTIFIER);
	}
}

symrec* put_sym(const char *sym_name, int sym_type) {
	symrec *ptr = (symrec *) malloc (sizeof (symrec));
	ptr->name = (char *) malloc (strlen (sym_name) + 1);
	strcpy (ptr->name,sym_name);
	ptr->type = sym_type;
	ptr->next = (struct symrec *)sym_table;
	sym_table = ptr;
	return ptr;
}


/*
 * Identifier stack
 */

ident* push_ident(int sym_type) {
	ident *id = (ident *) malloc (sizeof (ident));	
	id->type = sym_type;
	id->previous = (ident *)id_stack; 
	id_stack = id;
	return id;
}

void cur_ident(char const *name) {
	if ( id_stack != NULL ) {
		id_stack->name = name;	
	}
}

void pop_ident() {
	ident *id = id_stack;
	if (id != NULL) {
		if (id->name != NULL & id->type != 0)
			put_sym(id->name, id->type);
		if ( id->previous == NULL )
			id_stack = NULL;
		else
			id_stack = id->previous;	
		id->name = NULL;
		free(id);
	} 
}

/*  ***** ***** ***** ***** ***** ***** *****
 *  Syntax Tree
 */

ast *new_ast(char const *type, int num, ...) {
	va_list argp;
	ast *new_ast;
	int n;

	new_ast = malloc(sizeof(ast));
	new_ast->children = malloc((num+1) * sizeof(ast *));
	//fprintf(stderr, "%s = ", type);
	new_ast->type = strdup(type);
	new_ast->value = NULL;
	if (num) {
		va_start(argp, num);
		for (n = 0; n < num; n++) {
			new_ast->children[n] = va_arg(argp, ast *);	
			//fprintf(stderr, "%s ", new_ast->children[n]->type);
		}
		va_end(argp);
	}
	new_ast->children[num] = NULL;	
	//fprintf(stderr, "\n");
	return new_ast;
}

void print_ast(ast *ap) {
	/* breadth first walk */
	if (ap != NULL ) {
		fprintf(stdout, "%d:%s ", ap->num, ap->type);
		if (ap->value != NULL)
			fprintf(stdout, "= %s", ap->value);
		else
			fprintf(stdout, "-> ");
		int i; 
		for (i = 0; ap->children[i] != NULL; i++) {	
			ap->children[i]->num = ++cur_ast_num;
			fprintf(stdout, "%d:%s ", ap->children[i]->num, ap->children[i]->type);
		}
		fprintf(stdout, "\n");
		for (i = 0; ap->children[i] != NULL; i++) {	
			print_ast(ap->children[i]);
		}
	}
}
