extern int yyparse();
extern int yydebug;


int usage(register char *name) {
	fprintf(stderr, "usage: %s [source]\n", name);
	exit(1);
}

int main(int argc, char **argv) {

	char **argp;
	int cppflag = 1;

	for (argp = argv; *++argp && **argp == '-'; ) {
		switch ((*argp)[1]) {
			case 'P':
				cppflag	= 0; break;
			case 'd':
				yydebug	= 1; break;
			default: 
				usage(argv[0]);
		}
	}

	file_name = *argp;
	in_file = 1;

	if (argp[0] && argp[1])
		usage(argv[0]);
	if (*argp && !freopen(file_name, "r", stdin))
		perror(file_name), exit(1);
	if (cppflag && cpp(file_name))
		perror("C preprocessor"), exit(1);

	yyparse();

	file_context(file_name); 
	cur_ast_num = 0;
	tree->num = 0;
	serialize_ast(tree);	

	return 0;
}

