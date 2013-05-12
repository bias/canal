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

"auto"					{ yylval = new_node(strdup("AUTO"),0); yylval->token = strdup(yytext); return(AUTO); }
"break"					{ yylval = new_node(strdup("BREAK"),0); yylval->token = strdup(yytext); return(BREAK); }
"case"					{ yylval = new_node(strdup("CASE"),0); yylval->token = strdup(yytext); return(CASE); }
"char"					{ yylval = new_node(strdup("CHAR"),0); yylval->token = strdup(yytext); return(CHAR); }
"const"					{ yylval = new_node(strdup("CONST"),0); yylval->token = strdup(yytext); return(CONST); }
"continue"				{ yylval = new_node(strdup("CONTINUE"),0); yylval->token = strdup(yytext); return(CONTINUE); }
"default"				{ yylval = new_node(strdup("DEFAULT"),0); yylval->token = strdup(yytext); return(DEFAULT); }
"do"					{ yylval = new_node(strdup("DO"),0); yylval->token = strdup(yytext); return(DO); }
"double"				{ yylval = new_node(strdup("DOUBLE"),0); yylval->token = strdup(yytext); return(DOUBLE); }
"else"					{ yylval = new_node(strdup("ELSE"),0); yylval->token = strdup(yytext); return(ELSE); }
"enum"					{ yylval = new_node(strdup("ENUM"),0); yylval->token = strdup(yytext); return(ENUM); }
"extern"				{ yylval = new_node(strdup("EXTERN"),0); yylval->token = strdup(yytext); return(EXTERN); }
"float"					{ yylval = new_node(strdup("FLOAT"),0); yylval->token = strdup(yytext); return(FLOAT); }
"for"					{ yylval = new_node(strdup("FOR"),0); yylval->token = strdup(yytext); return(FOR); }
"goto"					{ yylval = new_node(strdup("GOTO"),0); yylval->token = strdup(yytext); return(GOTO); }
"if"					{ yylval = new_node(strdup("IF"),0); yylval->token = strdup(yytext); return(IF); }
"inline"				{ yylval = new_node(strdup("INLINE"),0); yylval->token = strdup(yytext); return(INLINE); }
"int"					{ yylval = new_node(strdup("INT"),0); yylval->token = strdup(yytext); return(INT); }
"long"					{ yylval = new_node(strdup("LONG"),0); yylval->token = strdup(yytext); return(LONG); }
"register"				{ yylval = new_node(strdup("REGISTER"),0); yylval->token = strdup(yytext); return(REGISTER); }
"restrict"				{ yylval = new_node(strdup("RESTRICT"),0); yylval->token = strdup(yytext); return(RESTRICT); }
"return"				{ yylval = new_node(strdup("RETURN"),0); yylval->token = strdup(yytext); return(RETURN); }
"short"					{ yylval = new_node(strdup("SHORT"),0); yylval->token = strdup(yytext); return(SHORT); }
"signed"				{ yylval = new_node(strdup("SIGNED"),0); yylval->token = strdup(yytext); return(SIGNED); }
"sizeof"				{ yylval = new_node(strdup("SIZEOF"),0); yylval->token = strdup(yytext); return(SIZEOF); }
"static"				{ yylval = new_node(strdup("STATIC"),0); yylval->token = strdup(yytext); return(STATIC); }
"struct"				{ yylval = new_node(strdup("STRUCT"),0); yylval->token = strdup(yytext); return(STRUCT); }
"switch"				{ yylval = new_node(strdup("SWITCH"),0); yylval->token = strdup(yytext); return(SWITCH); }
"typedef"				{ yylval = new_node(strdup("TYPEDEF"),0); yylval->token = strdup(yytext); return(TYPEDEF); }
"union"					{ yylval = new_node(strdup("UNION"),0); yylval->token = strdup(yytext); return(UNION); }
"unsigned"				{ yylval = new_node(strdup("UNSIGNED"),0); yylval->token = strdup(yytext); return(UNSIGNED); }
"void"					{ yylval = new_node(strdup("VOID"),0); yylval->token = strdup(yytext); return(VOID); }
"volatile"				{ yylval = new_node(strdup("VOLATILE"),0); yylval->token = strdup(yytext); return(VOLATILE); }
"while"					{ yylval = new_node(strdup("WHILE"),0); yylval->token = strdup(yytext); return(WHILE); }

"_Alignas"                              { yylval = new_node(strdup("ALIGNAS"),0); yylval->token = strdup(yytext); return(ALIGNAS); }
"_Alignof"                              { yylval = new_node(strdup("ALIGNOF"),0); yylval->token = strdup(yytext); return(ALIGNOF); }
"_Atomic"                               { yylval = new_node(strdup("ATOMIC"),0); yylval->token = strdup(yytext); return(ATOMIC); }
"_Bool"                                 { yylval = new_node(strdup("BOOL"),0); yylval->token = strdup(yytext); return(BOOL); }
"_Complex"                              { yylval = new_node(strdup("COMPLEX"),0); yylval->token = strdup(yytext); return(COMPLEX); }
"_Generic"                              { yylval = new_node(strdup("GENERIC"),0); yylval->token = strdup(yytext); return(GENERIC); }
"_Imaginary"                            { yylval = new_node(strdup("IMAGINARY"),0); yylval->token = strdup(yytext); return(IMAGINARY); }
"_Noreturn"                             { yylval = new_node(strdup("NORETURN"),0); yylval->token = strdup(yytext); return(NORETURN); }
"_Static_assert"                        { yylval = new_node(strdup("STATIC_ASSERT"),0); yylval->token = strdup(yytext); return(STATIC_ASSERT); }
"_Thread_local"                         { yylval = new_node(strdup("THREAD_LOCAL"),0); yylval->token = strdup(yytext); return(THREAD_LOCAL); }
"__func__"                              { yylval = new_node(strdup("FUNC_NAME"),0); yylval->token = strdup(yytext); return(FUNC_NAME); }

{L}{A}*					                { yylval = new_node(strdup("IDENTIFIER"),0); yylval->token = strdup(yytext); return(sym_type(yytext)); }

{HP}{H}+{IS}?				            { yylval = new_node(strdup("I_CONSTANT"),0); yylval->token = strdup(yytext); return(I_CONSTANT); }
{NZ}{D}*{IS}?				            { yylval = new_node(strdup("I_CONSTANT"),0); yylval->token = strdup(yytext); return(I_CONSTANT); }
"0"{O}*{IS}?				            { yylval = new_node(strdup("I_CONSTANT"),0); yylval->token = strdup(yytext); return(I_CONSTANT); }
{CP}?"'"([^'\\\n]|{ES})+"'"		        { yylval = new_node(strdup("I_CONSTANT"),0); yylval->token = strdup(yytext); return(I_CONSTANT); }

{D}+{E}{FS}?				            { yylval = new_node(strdup("F_CONSTANT"),0); yylval->token = strdup(yytext); return(F_CONSTANT); }
{D}*"."{D}+{E}?{FS}?			        { yylval = new_node(strdup("F_CONSTANT"),0); yylval->token = strdup(yytext); return(F_CONSTANT); }
{D}+"."{E}?{FS}?			            { yylval = new_node(strdup("F_CONSTANT"),0); yylval->token = strdup(yytext); return(F_CONSTANT); }
{HP}{H}+{P}{FS}?			            { yylval = new_node(strdup("F_CONSTANT"),0); yylval->token = strdup(yytext); return(F_CONSTANT); }
{HP}{H}*"."{H}+{P}{FS}?			        { yylval = new_node(strdup("F_CONSTANT"),0); yylval->token = strdup(yytext); return(F_CONSTANT); }
{HP}{H}+"."{P}{FS}?			            { yylval = new_node(strdup("F_CONSTANT"),0); yylval->token = strdup(yytext); return(F_CONSTANT); }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ yylval = new_node(strdup("STRING_LITERAL"),0); yylval->token = strdup(yytext); return(STRING_LITERAL); }

"..."					{ yylval = new_node(strdup("ELLIPSIS"),0); yylval->token = strdup(yytext); return(ELLIPSIS); }
">>="					{ yylval = new_node(strdup("RIGHT_ASSIGN"),0); yylval->token = strdup(yytext); return(RIGHT_ASSIGN); }
"<<="					{ yylval = new_node(strdup("LEFT_ASSIGN"),0); yylval->token = strdup(yytext); return(LEFT_ASSIGN); }
"+="					{ yylval = new_node(strdup("ADD_ASSIGN"),0); yylval->token = strdup(yytext); return(ADD_ASSIGN); }
"-="					{ yylval = new_node(strdup("SUB_ASSIGN"),0); yylval->token = strdup(yytext); return(SUB_ASSIGN); }
"*="					{ yylval = new_node(strdup("MUL_ASSIGN"),0); yylval->token = strdup(yytext); return(MUL_ASSIGN); }
"/="					{ yylval = new_node(strdup("DIV_ASSIGN"),0); yylval->token = strdup(yytext); return(DIV_ASSIGN); }
"%="					{ yylval = new_node(strdup("MOD_ASSIGN"),0); yylval->token = strdup(yytext); return(MOD_ASSIGN); }
"&="					{ yylval = new_node(strdup("AND_ASSIGN"),0); yylval->token = strdup(yytext); return(AND_ASSIGN); }
"^="					{ yylval = new_node(strdup("XOR_ASSIGN"),0); yylval->token = strdup(yytext); return(XOR_ASSIGN); }
"|="					{ yylval = new_node(strdup("OR_ASSIGN"),0); yylval->token = strdup(yytext); return(OR_ASSIGN); }
">>"					{ yylval = new_node(strdup("RIGHT_OP"),0); yylval->token = strdup(yytext); return(RIGHT_OP); }
"<<"					{ yylval = new_node(strdup("LEFT_OP"),0); yylval->token = strdup(yytext); return(LEFT_OP); }
"++"					{ yylval = new_node(strdup("INC_OP"),0); yylval->token = strdup(yytext); return(INC_OP); }
"--"					{ yylval = new_node(strdup("DEC_OP"),0); yylval->token = strdup(yytext); return(DEC_OP); }
"->"					{ yylval = new_node(strdup("PTR_OP"),0); yylval->token = strdup(yytext); return(PTR_OP); }
"&&"					{ yylval = new_node(strdup("AND_OP"),0); yylval->token = strdup(yytext); return(AND_OP); }
"||"					{ yylval = new_node(strdup("OR_OP"),0); yylval->token = strdup(yytext); return(OR_OP); }
"<="					{ yylval = new_node(strdup("LE_OP"),0); yylval->token = strdup(yytext); return(LE_OP); }
">="					{ yylval = new_node(strdup("GE_OP"),0); yylval->token = strdup(yytext); return(GE_OP); }
"=="					{ yylval = new_node(strdup("EQ_OP"),0); yylval->token = strdup(yytext); return(EQ_OP); }
"!="					{ yylval = new_node(strdup("NE_OP"),0); yylval->token = strdup(yytext); return(NE_OP); }
";"					    { yylval = new_node(strdup("';'"),0); yylval->token = strdup(yytext); return(';'); }
("{"|"<%")				{ yylval = new_node(strdup("'{'"),0); yylval->token = strdup(yytext); return('{'); }
("}"|"%>")				{ yylval = new_node(strdup("'}'"),0); yylval->token = strdup(yytext); return('}'); }
","					{ yylval = new_node(strdup("','"),0); yylval->token = strdup(yytext); return(','); }
":"					{ yylval = new_node(strdup("':'"),0); yylval->token = strdup(yytext); return(':'); }
"="					{ yylval = new_node(strdup("'='"),0); yylval->token = strdup(yytext); return('='); }
"("					{ yylval = new_node(strdup("'('"),0); yylval->token = strdup(yytext); return('('); }
")"					{ yylval = new_node(strdup("')'"),0); yylval->token = strdup(yytext); return(')'); }
("["|"<:")				{ yylval = new_node(strdup("'['"),0); yylval->token = strdup(yytext); return('['); }
("]"|":>")				{ yylval = new_node(strdup("']'"),0); yylval->token = strdup(yytext); return(']'); }
"."					{ yylval = new_node(strdup("'.'"),0); yylval->token = strdup(yytext); return('.'); }
"&"					{ yylval = new_node(strdup("'&'"),0); yylval->token = strdup(yytext); return('&'); }
"!"					{ yylval = new_node(strdup("'!'"),0); yylval->token = strdup(yytext); return('!'); }
"~"					{ yylval = new_node(strdup("'~'"),0); yylval->token = strdup(yytext); return('~'); }
"-"					{ yylval = new_node(strdup("'-'"),0); yylval->token = strdup(yytext); return('-'); }
"+"					{ yylval = new_node(strdup("'+'"),0); yylval->token = strdup(yytext); return('+'); }
"*"					{ yylval = new_node(strdup("'*'"),0); yylval->token = strdup(yytext); return('*'); }
"/"					{ yylval = new_node(strdup("'/'"),0); yylval->token = strdup(yytext); return('/'); }
"%"					{ yylval = new_node(strdup("'%'"),0); yylval->token = strdup(yytext); return('%'); }
"<"					{ yylval = new_node(strdup("'<'"),0); yylval->token = strdup(yytext); return('<'); }
">"					{ yylval = new_node(strdup("'>'"),0); yylval->token = strdup(yytext); return('>'); }
"^"					{ yylval = new_node(strdup("'^'"),0); yylval->token = strdup(yytext); return('^'); }
"|"					{ yylval = new_node(strdup("'|'"),0); yylval->token = strdup(yytext); return('|'); }
"?"					{ yylval = new_node(strdup("'?'"),0); yylval->token = strdup(yytext); return('?'); }

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
