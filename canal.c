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
	/* make this a bitfield */
	int cppflag = 1;
	int printflag = 0;
	int pennflag = 0;
	int statsflag = 1;
	int tokflag = 0;

	/* FIXME this should really use getopt */
	/* XXX should some of these be mutually exclusive? */
	for (argp = argv; *++argp && **argp == '-'; )
		switch ((*argp)[1]) {
			case 't':
				tokflag = 1, statsflag=0; break;
			case 'p':
				printflag = 1, statsflag=0; break;
			case 'e':
				pennflag = 1, statsflag=0; break;
			case 'M':
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

	fc_flag = 1;
	yyparse();
	/* we need to try to swap file contexts back to normal */
	file_context(file_name); 


	stat.order = 0;
	stat.max_height = 0;
	tree->num = 0;
	tree->height = 0;
	ast_bfwalk(tree, &gen_heights);
	leaves = NULL;
	ast_bfwalk(tree, &gen_leaves);
	tok_stats(leaves);

	if (statsflag) {
		fprintf(stdout, "%d %d %d %d %f\n", stat.order, stat.max_height, stat.max_height2, stat.ntoks, stat.avg_height);
	}

	if (printflag) {
		ast_bfwalk(tree, &print_ast);	
	}

	if (pennflag) {
		print_penn(tree);
	}

	if (tokflag) {
		print_tok(leaves);
	}

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

void file_context(char const *fname) {  
	int diff;
	if ( fname != NULL )
		diff = strcmp(fname, file_name);
	else
		diff = 1;

	if ( !diff  && in_file) {
		/* nothing */
	} else if ( !diff && !in_file ) {
		fc_flag = 1;
		in_file = 1;
	} else if ( diff && in_file ) {
		in_file = 0;
		fc_flag = 0;
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

ast *new_node(char const *type, int num, ...) {
	va_list argp;
	ast *new_node;
	int n;

	new_node = malloc(sizeof(ast));
	new_node->children = malloc((num+1) * sizeof(ast *));
	//fprintf(stderr, "%s = ", type);
	new_node->type = strdup(type);
	new_node->token = NULL;
	if (num) {
		va_start(argp, num);
		for (n = 0; n < num; n++) {
			new_node->children[n] = va_arg(argp, ast *);	
			//fprintf(stderr, "%s ", new_node->children[n]->type);
		}
		va_end(argp);
	}
	new_node->children[num] = NULL;	
	//fprintf(stderr, "\n");
	return new_node;
}

int ast_bfwalk(ast *ap, void (*funct)(ast *)) {
	int i;
	if (ap == NULL)
		return -1;
	(*funct)(ap);
	for (i = 0; ap->children[i] != NULL; i++)
		ast_bfwalk(ap->children[i], funct);
	return 0;
}

/*  ***** ***** ***** ***** ***** ***** *****
 *  In house analysis
 */

void print_ast(ast *ap) {
	if (ap != NULL ) {
		fprintf(stdout, "%d:%s ", ap->num, ap->type);
		if (ap->token != NULL)
			fprintf(stdout, "= \'%s\'", ap->token);
		else
			fprintf(stdout, "-> ");
		int i; 
		for (i = 0; ap->children[i] != NULL; i++) {	
			ap->children[i]->num = ++stat.order;
			fprintf(stdout, "%d:%s ", ap->children[i]->num, ap->children[i]->type);
		}
		fprintf(stdout, "\n");
	}
}

void print_penn(ast *ap) {
	int i; 
	if (ap != NULL ) {
		fprintf(stdout, "(%s ", ap->type);
		for (i = 0; ap->children[i] != NULL; i++) {	
			if ( ap->children[i]->token == NULL )
				print_penn(ap->children[i]);
		}
		if (ap->children[0] != NULL && ap->children[0]->token != NULL)
			fprintf(stdout, "\'%s\') ", ap->children[0]->token);
		else
			fprintf(stdout, ") ");
	}
}

void gen_heights(ast *ap) {
	int i; 
	for (i = 0; ap->children[i] != NULL; i++) {	
		ap->children[i]->num = stat.order++;
		ap->children[i]->height = ap->height++;
	}
	ap->cvalance = i;
}

void gen_leaves(ast *ap) {
	tokl *new_leaf;
	if (ap->children[0] == NULL) {
		new_leaf = malloc(sizeof(tokl));
		new_leaf->ap = ap;
		new_leaf->next = leaves;
		leaves = new_leaf;
	}
}

int tok_stats(tokl *l) {
	if (l == NULL) {
		return stat.avg_height = stat.avg_height / stat.ntoks;
	}
	stat.avg_height += l->ap->height;
	stat.ntoks++;
	if (l->ap->height > stat.max_height) {
		stat.max_height2 = stat.max_height;
		stat.max_height = l->ap->height;
	}
	else if (l->ap->height > stat.max_height2)
		stat.max_height2 = stat.max_height2;
	return tok_stats(l->next);
}

int print_tok(tokl *l) {
	if (l==NULL)
		return 0;
	fprintf(stdout, "%s=\'%s\'\n", l->ap->type, l->ap->token);
	return print_tok(l->next);
}
