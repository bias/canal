%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%option nodefault yylineno

%{
#include <stdio.h>
#include "parse.h"
#include "c.h"

static int check_type(void);

char linebuf[512];
%}

%x C_COMMENT


%%

\n.*					{ strncpy(linebuf, yytext+1, sizeof(linebuf)); yyless(1); }

"#".*							  	  { fprintf(stdout, "tok include\n"); }

"/*"								  { BEGIN(C_COMMENT); fprintf(stdout, "tok comment block\n"); }
<C_COMMENT>"*/"						  { BEGIN(INITIAL); }
<C_COMMENT>(.|\n)					  ;

"//".*                                ;

"auto"					{ yylval.a = yytext; return(AUTO); }
"break"					{ yylval.a = yytext; return(BREAK); }
"case"					{ yylval.a = yytext; return(CASE); }
"char"					{ yylval.a = yytext; return(CHAR); }
"const"					{ yylval.a = yytext; return(CONST); }
"continue"				{ yylval.a = yytext; return(CONTINUE); }
"default"				{ yylval.a = yytext; return(DEFAULT); }
"do"					{ yylval.a = yytext; return(DO); }
"double"				{ yylval.a = yytext; return(DOUBLE); }
"else"					{ yylval.a = yytext; return(ELSE); }
"enum"					{ yylval.a = yytext; return(ENUM); }
"extern"				{ yylval.a = yytext; return(EXTERN); }
"float"					{ yylval.a = yytext; return(FLOAT); }
"for"					{ yylval.a = yytext; return(FOR); }
"goto"					{ yylval.a = yytext; return(GOTO); }
"if"					{ yylval.a = yytext; return(IF); }
"inline"				{ yylval.a = yytext; return(INLINE); }
"int"					{ yylval.a = yytext; return(INT); }
"long"					{ yylval.a = yytext; return(LONG); }
"register"				{ yylval.a = yytext; return(REGISTER); }
"restrict"				{ yylval.a = yytext; return(RESTRICT); }
"return"				{ yylval.a = yytext; return(RETURN); }
"short"					{ yylval.a = yytext; return(SHORT); }
"signed"				{ yylval.a = yytext; return(SIGNED); }
"sizeof"				{ yylval.a = yytext; return(SIZEOF); }
"static"				{ yylval.a = yytext; return(STATIC); }
"struct"				{ yylval.a = yytext; return(STRUCT); }
"switch"				{ yylval.a = yytext; return(SWITCH); }
"typedef"				{ yylval.a = yytext; return(TYPEDEF); }
"union"					{ yylval.a = yytext; return(UNION); }
"unsigned"				{ yylval.a = yytext; return(UNSIGNED); }
"void"					{ yylval.a = yytext; return(VOID); }
"volatile"				{ yylval.a = yytext; return(VOLATILE); }
"while"					{ yylval.a = yytext; return(WHILE); }
"_Alignas"                              { yylval.a = yytext; return ALIGNAS; }
"_Alignof"                              { yylval.a = yytext; return ALIGNOF; }
"_Atomic"                               { yylval.a = yytext; return ATOMIC; }
"_Bool"                                 { yylval.a = yytext; return BOOL; }
"_Complex"                              { yylval.a = yytext; return COMPLEX; }
"_Generic"                              { yylval.a = yytext; return GENERIC; }
"_Imaginary"                            { yylval.a = yytext; return IMAGINARY; }
"_Noreturn"                             { yylval.a = yytext; return NORETURN; }
"_Static_assert"                        { yylval.a = yytext; return STATIC_ASSERT; }
"_Thread_local"                         { yylval.a = yytext; return THREAD_LOCAL; }
"__func__"                              { yylval.a = yytext; return FUNC_NAME; }

{L}{A}*					{ yylval.a = yytext; return check_type(); }

{HP}{H}+{IS}?				{ yylval.a = yytext; return I_CONSTANT; }
{NZ}{D}*{IS}?				{ yylval.a = yytext; return I_CONSTANT; }
"0"{O}*{IS}?				{ yylval.a = yytext; return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"		{ yylval.a = yytext; return I_CONSTANT; }

{D}+{E}{FS}?				{ yylval.a = yytext; return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{ yylval.a = yytext; return F_CONSTANT; }
{D}+"."{E}?{FS}?			{ yylval.a = yytext; return F_CONSTANT; }
{HP}{H}+{P}{FS}?			{ yylval.a = yytext; return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{ yylval.a = yytext; return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{ yylval.a = yytext; return F_CONSTANT; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ yylval.a = yytext; return STRING_LITERAL; }

"..."					{ yylval.a = yytext; return ELLIPSIS; }
">>="					{ yylval.a = yytext; return RIGHT_ASSIGN; }
"<<="					{ yylval.a = yytext; return LEFT_ASSIGN; }
"+="					{ yylval.a = yytext; return ADD_ASSIGN; }
"-="					{ yylval.a = yytext; return SUB_ASSIGN; }
"*="					{ yylval.a = yytext; return MUL_ASSIGN; }
"/="					{ yylval.a = yytext; return DIV_ASSIGN; }
"%="					{ yylval.a = yytext; return MOD_ASSIGN; }
"&="					{ yylval.a = yytext; return AND_ASSIGN; }
"^="					{ yylval.a = yytext; return XOR_ASSIGN; }
"|="					{ yylval.a = yytext; return OR_ASSIGN; }
">>"					{ yylval.a = yytext; return RIGHT_OP; }
"<<"					{ yylval.a = yytext; return LEFT_OP; }
"++"					{ yylval.a = yytext; return INC_OP; }
"--"					{ yylval.a = yytext; return DEC_OP; }
"->"					{ yylval.a = yytext; return PTR_OP; }
"&&"					{ yylval.a = yytext; return AND_OP; }
"||"					{ yylval.a = yytext; return OR_OP; }
"<="					{ yylval.a = yytext; return LE_OP; }
">="					{ yylval.a = yytext; return GE_OP; }
"=="					{ yylval.a = yytext; return EQ_OP; }
"!="					{ yylval.a = yytext; return NE_OP; }
";"					{ yylval.a = yytext; return ';'; }
("{"|"<%")				{ yylval.a = yytext; return '{'; }
("}"|"%>")				{ yylval.a = yytext; return '}'; }
","					{ yylval.a = yytext; return ','; }
":"					{ yylval.a = yytext; return ':'; }
"="					{ yylval.a = yytext; return '='; }
"("					{ yylval.a = yytext; return '('; }
")"					{ yylval.a = yytext; return ')'; }
("["|"<:")				{ yylval.a = yytext; return '['; }
("]"|":>")				{ yylval.a = yytext; return ']'; }
"."					{ yylval.a = yytext; return '.'; }
"&"					{ yylval.a = yytext; return '&'; }
"!"					{ yylval.a = yytext; return '!'; }
"~"					{ yylval.a = yytext; return '~'; }
"-"					{ yylval.a = yytext; return '-'; }
"+"					{ yylval.a = yytext; return '+'; }
"*"					{ yylval.a = yytext; return '*'; }
"/"					{ yylval.a = yytext; return '/'; }
"%"					{ yylval.a = yytext; return '%'; }
"<"					{ yylval.a = yytext; return '<'; }
">"					{ yylval.a = yytext; return '>'; }
"^"					{ yylval.a = yytext; return '^'; }
"|"					{ yylval.a = yytext; return '|'; }
"?"					{ yylval.a = yytext; return '?'; }

{WS}					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

/* called at end of input */
int yywrap(void) {
    return 1;           /* terminate now */
}

/* NOTE we're actually going to skip buidling the type/constant/identifier symbol table */
/* XXX this means we replaced the grammer rules for typedef/constant with identifier */
static int check_type(void) {
    switch (sym_type(yytext)) {
		case TYPEDEF_NAME:                /* previously defined */
			return TYPEDEF_NAME;
		case ENUMERATION_CONSTANT:        /* previously defined */
			return ENUMERATION_CONSTANT;
		default:                          /* includes undefined */
			return IDENTIFIER;
    }
}

void yyerror(const char *s) {
	printf("%d: %s at %s\n in line:%s\n", yylineno, s, yytext, linebuf);
}
