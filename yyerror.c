/*
 *		yywhere() -- input position for yyparse()
 *		yymark() -- get information from '# line file'
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char yytext[];		/* current token */
extern int yyleng;			/* and it's length */
extern int yylineno;		/* current input line number */

static char *source;		/* current input file name */

void yywhere() {
	char colon = 0;
	
	if (source && *source && strcmp(source, "\"\"")) {
		char *cp = source;
		int len = strlen(source);
		if (*cp == '"')
			++cp, len -= 2;
		if (strncmp(cp, "./", 2) == 0)
			cp += 2, len -= 2;
		fprintf(stdout, "file %.*s", len, cp);
		colon = 1;
	}
	
	if (yylineno > 0) {
		if (colon)
			fputs(", ", stdout);
		// FIXME
		//fprintf(stdout, "line %d", yylineno - (*yytext == '\n' || !*yytext));
		fprintf(stdout, "line %d", yylineno);
		colon = 1;
	}

	if (*yytext) {
		register int i;
		for (i = 0; i < 20; ++i)
			if (!yytext[i] || yytext[i] == '\n')
				break;
		if (i) {
			if (colon)
				putc(' ', stdout);
			fprintf(stdout, "near \"%.*s\"", i, yytext);
			colon = 1;
		}
	}

	if (colon)
		fputs(": ", stdout);
}

void yymark() {
	if (source)
		free(source);
	source = (char *) calloc(yyleng, sizeof(char));
	if (source)
		sscanf(yytext, "# %d %s", &yylineno, source);
}

/*
 *		yyerror() -- combine yywhere and yymark into error message
 */

void yyerror(const char *s) {
	extern int yynerrs;		/* total number of errors */
	// FIXME
	//fprintf(stdout, "[error %d] ", yynerrs+1);
	//yywhere();
	//fputs(s, stdout);
	//putc('\n', stdout);
	printf("%d: %s at %s\n", yylineno, s, yytext);
}
