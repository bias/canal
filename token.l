%{
#include <stdio.h>
#include "canal.h"
#define YYSTYPE struct ast *
#include "parse.h"
char linebuf[512];
%}

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

%option warn yylineno

%x C_COMMENT


%%

\n.*					{ strncpy(linebuf, yytext+1, sizeof(linebuf)); yyless(1); }

"#".*							  	  { tok_cpp_file(yytext); }

"auto"					{ yylval = new_ast(strdup("AUTO"),0); yylval->value = strdup(yytext); return(AUTO); }
"break"					{ yylval = new_ast(strdup("BREAK"),0); yylval->value = strdup(yytext); return(BREAK); }
"case"					{ yylval = new_ast(strdup("CASE"),0); yylval->value = strdup(yytext); return(CASE); }
"char"					{ yylval = new_ast(strdup("CHAR"),0); yylval->value = strdup(yytext); return(CHAR); }
"const"					{ yylval = new_ast(strdup("CONST"),0); yylval->value = strdup(yytext); return(CONST); }
"continue"				{ yylval = new_ast(strdup("CONTINUE"),0); yylval->value = strdup(yytext); return(CONTINUE); }
"default"				{ yylval = new_ast(strdup("DEFAULT"),0); yylval->value = strdup(yytext); return(DEFAULT); }
"do"					{ yylval = new_ast(strdup("DO"),0); yylval->value = strdup(yytext); return(DO); }
"double"				{ yylval = new_ast(strdup("DOUBLE"),0); yylval->value = strdup(yytext); return(DOUBLE); }
"else"					{ yylval = new_ast(strdup("ELSE"),0); yylval->value = strdup(yytext); return(ELSE); }
"enum"					{ yylval = new_ast(strdup("ENUM"),0); yylval->value = strdup(yytext); return(ENUM); }
"extern"				{ yylval = new_ast(strdup("EXTERN"),0); yylval->value = strdup(yytext); return(EXTERN); }
"float"					{ yylval = new_ast(strdup("FLOAT"),0); yylval->value = strdup(yytext); return(FLOAT); }
"for"					{ yylval = new_ast(strdup("FOR"),0); yylval->value = strdup(yytext); return(FOR); }
"goto"					{ yylval = new_ast(strdup("GOTO"),0); yylval->value = strdup(yytext); return(GOTO); }
"if"					{ yylval = new_ast(strdup("IF"),0); yylval->value = strdup(yytext); return(IF); }
"inline"				{ yylval = new_ast(strdup("INLINE"),0); yylval->value = strdup(yytext); return(INLINE); }
"int"					{ yylval = new_ast(strdup("INT"),0); yylval->value = strdup(yytext); return(INT); }
"long"					{ yylval = new_ast(strdup("LONG"),0); yylval->value = strdup(yytext); return(LONG); }
"register"				{ yylval = new_ast(strdup("REGISTER"),0); yylval->value = strdup(yytext); return(REGISTER); }
"restrict"				{ yylval = new_ast(strdup("RESTRICT"),0); yylval->value = strdup(yytext); return(RESTRICT); }
"return"				{ yylval = new_ast(strdup("RETURN"),0); yylval->value = strdup(yytext); return(RETURN); }
"short"					{ yylval = new_ast(strdup("SHORT"),0); yylval->value = strdup(yytext); return(SHORT); }
"signed"				{ yylval = new_ast(strdup("SIGNED"),0); yylval->value = strdup(yytext); return(SIGNED); }
"sizeof"				{ yylval = new_ast(strdup("SIZEOF"),0); yylval->value = strdup(yytext); return(SIZEOF); }
"static"				{ yylval = new_ast(strdup("STATIC"),0); yylval->value = strdup(yytext); return(STATIC); }
"struct"				{ yylval = new_ast(strdup("STRUCT"),0); yylval->value = strdup(yytext); return(STRUCT); }
"switch"				{ yylval = new_ast(strdup("SWITCH"),0); yylval->value = strdup(yytext); return(SWITCH); }
"typedef"				{ yylval = new_ast(strdup("TYPEDEF"),0); yylval->value = strdup(yytext); return(TYPEDEF); }
"union"					{ yylval = new_ast(strdup("UNION"),0); yylval->value = strdup(yytext); return(UNION); }
"unsigned"				{ yylval = new_ast(strdup("UNSIGNED"),0); yylval->value = strdup(yytext); return(UNSIGNED); }
"void"					{ yylval = new_ast(strdup("VOID"),0); yylval->value = strdup(yytext); return(VOID); }
"volatile"				{ yylval = new_ast(strdup("VOLATILE"),0); yylval->value = strdup(yytext); return(VOLATILE); }
"while"					{ yylval = new_ast(strdup("WHILE"),0); yylval->value = strdup(yytext); return(WHILE); }

"_Alignas"                              { yylval = new_ast(strdup("ALIGNAS"),0); yylval->value = strdup(yytext); return(ALIGNAS); }
"_Alignof"                              { yylval = new_ast(strdup("ALIGNOF"),0); yylval->value = strdup(yytext); return(ALIGNOF); }
"_Atomic"                               { yylval = new_ast(strdup("ATOMIC"),0); yylval->value = strdup(yytext); return(ATOMIC); }
"_Bool"                                 { yylval = new_ast(strdup("BOOL"),0); yylval->value = strdup(yytext); return(BOOL); }
"_Complex"                              { yylval = new_ast(strdup("COMPLEX"),0); yylval->value = strdup(yytext); return(COMPLEX); }
"_Generic"                              { yylval = new_ast(strdup("GENERIC"),0); yylval->value = strdup(yytext); return(GENERIC); }
"_Imaginary"                            { yylval = new_ast(strdup("IMAGINARY"),0); yylval->value = strdup(yytext); return(IMAGINARY); }
"_Noreturn"                             { yylval = new_ast(strdup("NORETURN"),0); yylval->value = strdup(yytext); return(NORETURN); }
"_Static_assert"                        { yylval = new_ast(strdup("STATIC_ASSERT"),0); yylval->value = strdup(yytext); return(STATIC_ASSERT); }
"_Thread_local"                         { yylval = new_ast(strdup("THREAD_LOCAL"),0); yylval->value = strdup(yytext); return(THREAD_LOCAL); }
"__func__"                              { yylval = new_ast(strdup("FUNC_NAME"),0); yylval->value = strdup(yytext); return(FUNC_NAME); }

{L}{A}*					                { yylval = new_ast(strdup("IDENTIFIER"),0); yylval->value = strdup(yytext); return(sym_type(yytext)); }

{HP}{H}+{IS}?				            { yylval = new_ast(strdup("I_CONSTANT"),0); yylval->value = strdup(yytext); return(I_CONSTANT); }
{NZ}{D}*{IS}?				            { yylval = new_ast(strdup("I_CONSTANT"),0); yylval->value = strdup(yytext); return(I_CONSTANT); }
"0"{O}*{IS}?				            { yylval = new_ast(strdup("I_CONSTANT"),0); yylval->value = strdup(yytext); return(I_CONSTANT); }
{CP}?"'"([^'\\\n]|{ES})+"'"		        { yylval = new_ast(strdup("I_CONSTANT"),0); yylval->value = strdup(yytext); return(I_CONSTANT); }

{D}+{E}{FS}?				            { yylval = new_ast(strdup("F_CONSTANT"),0); yylval->value = strdup(yytext); return(F_CONSTANT); }
{D}*"."{D}+{E}?{FS}?			        { yylval = new_ast(strdup("F_CONSTANT"),0); yylval->value = strdup(yytext); return(F_CONSTANT); }
{D}+"."{E}?{FS}?			            { yylval = new_ast(strdup("F_CONSTANT"),0); yylval->value = strdup(yytext); return(F_CONSTANT); }
{HP}{H}+{P}{FS}?			            { yylval = new_ast(strdup("F_CONSTANT"),0); yylval->value = strdup(yytext); return(F_CONSTANT); }
{HP}{H}*"."{H}+{P}{FS}?			        { yylval = new_ast(strdup("F_CONSTANT"),0); yylval->value = strdup(yytext); return(F_CONSTANT); }
{HP}{H}+"."{P}{FS}?			            { yylval = new_ast(strdup("F_CONSTANT"),0); yylval->value = strdup(yytext); return(F_CONSTANT); }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ yylval = new_ast(strdup("STRING_LITERAL"),0); yylval->value = strdup(yytext); return(STRING_LITERAL); }

"..."					{ yylval = new_ast(strdup("ELLIPSIS"),0); yylval->value = strdup(yytext); return(ELLIPSIS); }
">>="					{ yylval = new_ast(strdup("RIGHT_ASSIGN"),0); yylval->value = strdup(yytext); return(RIGHT_ASSIGN); }
"<<="					{ yylval = new_ast(strdup("LEFT_ASSIGN"),0); yylval->value = strdup(yytext); return(LEFT_ASSIGN); }
"+="					{ yylval = new_ast(strdup("ADD_ASSIGN"),0); yylval->value = strdup(yytext); return(ADD_ASSIGN); }
"-="					{ yylval = new_ast(strdup("SUB_ASSIGN"),0); yylval->value = strdup(yytext); return(SUB_ASSIGN); }
"*="					{ yylval = new_ast(strdup("MUL_ASSIGN"),0); yylval->value = strdup(yytext); return(MUL_ASSIGN); }
"/="					{ yylval = new_ast(strdup("DIV_ASSIGN"),0); yylval->value = strdup(yytext); return(DIV_ASSIGN); }
"%="					{ yylval = new_ast(strdup("MOD_ASSIGN"),0); yylval->value = strdup(yytext); return(MOD_ASSIGN); }
"&="					{ yylval = new_ast(strdup("AND_ASSIGN"),0); yylval->value = strdup(yytext); return(AND_ASSIGN); }
"^="					{ yylval = new_ast(strdup("XOR_ASSIGN"),0); yylval->value = strdup(yytext); return(XOR_ASSIGN); }
"|="					{ yylval = new_ast(strdup("OR_ASSIGN"),0); yylval->value = strdup(yytext); return(OR_ASSIGN); }
">>"					{ yylval = new_ast(strdup("RIGHT_OP"),0); yylval->value = strdup(yytext); return(RIGHT_OP); }
"<<"					{ yylval = new_ast(strdup("LEFT_OP"),0); yylval->value = strdup(yytext); return(LEFT_OP); }
"++"					{ yylval = new_ast(strdup("INC_OP"),0); yylval->value = strdup(yytext); return(INC_OP); }
"--"					{ yylval = new_ast(strdup("DEC_OP"),0); yylval->value = strdup(yytext); return(DEC_OP); }
"->"					{ yylval = new_ast(strdup("PTR_OP"),0); yylval->value = strdup(yytext); return(PTR_OP); }
"&&"					{ yylval = new_ast(strdup("AND_OP"),0); yylval->value = strdup(yytext); return(AND_OP); }
"||"					{ yylval = new_ast(strdup("OR_OP"),0); yylval->value = strdup(yytext); return(OR_OP); }
"<="					{ yylval = new_ast(strdup("LE_OP"),0); yylval->value = strdup(yytext); return(LE_OP); }
">="					{ yylval = new_ast(strdup("GE_OP"),0); yylval->value = strdup(yytext); return(GE_OP); }
"=="					{ yylval = new_ast(strdup("EQ_OP"),0); yylval->value = strdup(yytext); return(EQ_OP); }
"!="					{ yylval = new_ast(strdup("NE_OP"),0); yylval->value = strdup(yytext); return(NE_OP); }
";"					    { yylval = new_ast(strdup("';'"),0); yylval->value = strdup(yytext); return(';'); }
("{"|"<%")				{ yylval = new_ast(strdup("'{'"),0); yylval->value = strdup(yytext); return('{'); }
("}"|"%>")				{ yylval = new_ast(strdup("'}'"),0); yylval->value = strdup(yytext); return('}'); }
","					{ yylval = new_ast(strdup("','"),0); yylval->value = strdup(yytext); return(','); }
":"					{ yylval = new_ast(strdup("':'"),0); yylval->value = strdup(yytext); return(':'); }
"="					{ yylval = new_ast(strdup("'='"),0); yylval->value = strdup(yytext); return('='); }
"("					{ yylval = new_ast(strdup("'('"),0); yylval->value = strdup(yytext); return('('); }
")"					{ yylval = new_ast(strdup("')'"),0); yylval->value = strdup(yytext); return(')'); }
("["|"<:")				{ yylval = new_ast(strdup("'['"),0); yylval->value = strdup(yytext); return('['); }
("]"|":>")				{ yylval = new_ast(strdup("']'"),0); yylval->value = strdup(yytext); return(']'); }
"."					{ yylval = new_ast(strdup("'.'"),0); yylval->value = strdup(yytext); return('.'); }
"&"					{ yylval = new_ast(strdup("'&'"),0); yylval->value = strdup(yytext); return('&'); }
"!"					{ yylval = new_ast(strdup("'!'"),0); yylval->value = strdup(yytext); return('!'); }
"~"					{ yylval = new_ast(strdup("'~'"),0); yylval->value = strdup(yytext); return('~'); }
"-"					{ yylval = new_ast(strdup("'-'"),0); yylval->value = strdup(yytext); return('-'); }
"+"					{ yylval = new_ast(strdup("'+'"),0); yylval->value = strdup(yytext); return('+'); }
"*"					{ yylval = new_ast(strdup("'*'"),0); yylval->value = strdup(yytext); return('*'); }
"/"					{ yylval = new_ast(strdup("'/'"),0); yylval->value = strdup(yytext); return('/'); }
"%"					{ yylval = new_ast(strdup("'%'"),0); yylval->value = strdup(yytext); return('%'); }
"<"					{ yylval = new_ast(strdup("'<'"),0); yylval->value = strdup(yytext); return('<'); }
">"					{ yylval = new_ast(strdup("'>'"),0); yylval->value = strdup(yytext); return('>'); }
"^"					{ yylval = new_ast(strdup("'^'"),0); yylval->value = strdup(yytext); return('^'); }
"|"					{ yylval = new_ast(strdup("'|'"),0); yylval->value = strdup(yytext); return('|'); }
"?"					{ yylval = new_ast(strdup("'?'"),0); yylval->value = strdup(yytext); return('?'); }

{WS}					{ /* whitespace separates tokens */ }
.					    { /* discard bad characters */ }

%%

/* called at end of input */
int yywrap(void) {
    // set as 0 and point yyin to new file to continue
    return 1;           
}

void yyerror(const char *s) {
	fprintf(stderr, "%d: %s at \"%s\" in line: \"%s\"\n", yylineno, s, yytext, linebuf);
}
