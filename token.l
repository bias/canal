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

%option warn nodefault yylineno

%{
#include <stdio.h>
#include "parse.h"
#include "canal.h"
char linebuf[512];
%}

%x C_COMMENT


%%

\n.*					{ strncpy(linebuf, yytext+1, sizeof(linebuf)); yyless(1); }

"#"{WS}+{D}+{WS}+\"([^"\\n]|{ES})*\"							  	  { file_context("file", 0); /* FIXME splice string and line num from yytext */ }

"auto"					{ yylval.string = strdup(yytext); fprintf(stderr, "t:AUTO auto", ); return(AUTO); }
"break"					{ yylval.string = strdup(yytext); fprintf(stderr, "t:AUTO auto", ); return(BREAK); }
"case"					{ yylval.string = strdup(yytext); return(CASE); }
"char"					{ yylval.string = strdup(yytext); return(CHAR); }
"const"					{ yylval.string = strdup(yytext); return(CONST); }
"continue"				{ yylval.string = strdup(yytext); return(CONTINUE); }
"default"				{ yylval.string = strdup(yytext); return(DEFAULT); }
"do"					{ yylval.string = strdup(yytext); return(DO); }
"double"				{ yylval.string = strdup(yytext); return(DOUBLE); }
"else"					{ yylval.string = strdup(yytext); return(ELSE); }
"enum"					{ yylval.string = strdup(yytext); return(ENUM); }
"extern"				{ yylval.string = strdup(yytext); return(EXTERN); }
"float"					{ yylval.string = strdup(yytext); return(FLOAT); }
"for"					{ yylval.string = strdup(yytext); return(FOR); }
"goto"					{ yylval.string = strdup(yytext); return(GOTO); }
"if"					{ yylval.string = strdup(yytext); return(IF); }
"inline"				{ yylval.string = strdup(yytext); return(INLINE); }
"int"					{ yylval.string = strdup(yytext); return(INT); }
"long"					{ yylval.string = strdup(yytext); return(LONG); }
"register"				{ yylval.string = strdup(yytext); return(REGISTER); }
"restrict"				{ yylval.string = strdup(yytext); return(RESTRICT); }
"return"				{ yylval.string = strdup(yytext); return(RETURN); }
"short"					{ yylval.string = strdup(yytext); return(SHORT); }
"signed"				{ yylval.string = strdup(yytext); return(SIGNED); }
"sizeof"				{ yylval.string = strdup(yytext); return(SIZEOF); }
"static"				{ yylval.string = strdup(yytext); return(STATIC); }
"struct"				{ yylval.string = strdup(yytext); return(STRUCT); }
"switch"				{ yylval.string = strdup(yytext); return(SWITCH); }
"typedef"				{ yylval.string = strdup(yytext); return(TYPEDEF); }
"union"					{ yylval.string = strdup(yytext); return(UNION); }
"unsigned"				{ yylval.string = strdup(yytext); return(UNSIGNED); }
"void"					{ yylval.string = strdup(yytext); return(VOID); }
"volatile"				{ yylval.string = strdup(yytext); return(VOLATILE); }
"while"					{ yylval.string = strdup(yytext); return(WHILE); }
"_Alignas"                              { yylval.string = strdup(yytext); return ALIGNAS; }
"_Alignof"                              { yylval.string = strdup(yytext); return ALIGNOF; }
"_Atomic"                               { yylval.string = strdup(yytext); return ATOMIC; }
"_Bool"                                 { yylval.string = strdup(yytext); return BOOL; }
"_Complex"                              { yylval.string = strdup(yytext); return COMPLEX; }
"_Generic"                              { yylval.string = strdup(yytext); return GENERIC; }
"_Imaginary"                            { yylval.string = strdup(yytext); return IMAGINARY; }
"_Noreturn"                             { yylval.string = strdup(yytext); return NORETURN; }
"_Static_assert"                        { yylval.string = strdup(yytext); return STATIC_ASSERT; }
"_Thread_local"                         { yylval.string = strdup(yytext); return THREAD_LOCAL; }
"__func__"                              { yylval.string = strdup(yytext); return FUNC_NAME; }

{L}{A}*					{ yylval.string = strdup(yytext); return sym_type(yytext); }

{HP}{H}+{IS}?				{ yylval.string = strdup(yytext); return I_CONSTANT; }
{NZ}{D}*{IS}?				{ yylval.string = strdup(yytext); return I_CONSTANT; }
"0"{O}*{IS}?				{ yylval.string = strdup(yytext); return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"		{ yylval.string = strdup(yytext); return I_CONSTANT; }

{D}+{E}{FS}?				{ yylval.string = strdup(yytext); return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{ yylval.string = strdup(yytext); return F_CONSTANT; }
{D}+"."{E}?{FS}?			{ yylval.string = strdup(yytext); return F_CONSTANT; }
{HP}{H}+{P}{FS}?			{ yylval.string = strdup(yytext); return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{ yylval.string = strdup(yytext); return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{ yylval.string = strdup(yytext); return F_CONSTANT; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ yylval.string = strdup(yytext); return STRING_LITERAL; }

"..."					{ yylval.string = strdup(yytext); return ELLIPSIS; }
">>="					{ yylval.string = strdup(yytext); return RIGHT_ASSIGN; }
"<<="					{ yylval.string = strdup(yytext); return LEFT_ASSIGN; }
"+="					{ yylval.string = strdup(yytext); return ADD_ASSIGN; }
"-="					{ yylval.string = strdup(yytext); return SUB_ASSIGN; }
"*="					{ yylval.string = strdup(yytext); return MUL_ASSIGN; }
"/="					{ yylval.string = strdup(yytext); return DIV_ASSIGN; }
"%="					{ yylval.string = strdup(yytext); return MOD_ASSIGN; }
"&="					{ yylval.string = strdup(yytext); return AND_ASSIGN; }
"^="					{ yylval.string = strdup(yytext); return XOR_ASSIGN; }
"|="					{ yylval.string = strdup(yytext); return OR_ASSIGN; }
">>"					{ yylval.string = strdup(yytext); return RIGHT_OP; }
"<<"					{ yylval.string = strdup(yytext); return LEFT_OP; }
"++"					{ yylval.string = strdup(yytext); return INC_OP; }
"--"					{ yylval.string = strdup(yytext); return DEC_OP; }
"->"					{ yylval.string = strdup(yytext); return PTR_OP; }
"&&"					{ yylval.string = strdup(yytext); return AND_OP; }
"||"					{ yylval.string = strdup(yytext); return OR_OP; }
"<="					{ yylval.string = strdup(yytext); return LE_OP; }
">="					{ yylval.string = strdup(yytext); return GE_OP; }
"=="					{ yylval.string = strdup(yytext); return EQ_OP; }
"!="					{ yylval.string = strdup(yytext); return NE_OP; }
";"					{ yylval.string = strdup(yytext); return ';'; }
("{"|"<%")				{ yylval.string = strdup(yytext); return '{'; }
("}"|"%>")				{ yylval.string = strdup(yytext); return '}'; }
","					{ yylval.string = strdup(yytext); return ','; }
":"					{ yylval.string = strdup(yytext); return ':'; }
"="					{ yylval.string = strdup(yytext); return '='; }
"("					{ yylval.string = strdup(yytext); return '('; }
")"					{ yylval.string = strdup(yytext); return ')'; }
("["|"<:")				{ yylval.string = strdup(yytext); return '['; }
("]"|":>")				{ yylval.string = strdup(yytext); return ']'; }
"."					{ yylval.string = strdup(yytext); return '.'; }
"&"					{ yylval.string = strdup(yytext); return '&'; }
"!"					{ yylval.string = strdup(yytext); return '!'; }
"~"					{ yylval.string = strdup(yytext); return '~'; }
"-"					{ yylval.string = strdup(yytext); return '-'; }
"+"					{ yylval.string = strdup(yytext); return '+'; }
"*"					{ yylval.string = strdup(yytext); return '*'; }
"/"					{ yylval.string = strdup(yytext); return '/'; }
"%"					{ yylval.string = strdup(yytext); return '%'; }
"<"					{ yylval.string = strdup(yytext); return '<'; }
">"					{ yylval.string = strdup(yytext); return '>'; }
"^"					{ yylval.string = strdup(yytext); return '^'; }
"|"					{ yylval.string = strdup(yytext); return '|'; }
"?"					{ yylval.string = strdup(yytext); return '?'; }

{WS}					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

/* called at end of input */
int yywrap(void) {
    // set as 0 and point yyin to new file to continue
    return 1;           
}

void yyerror(const char *s) {
	printf("%d: %s at \"%s\" in line: \"%s\"\n", yylineno, s, yytext, linebuf);
}
