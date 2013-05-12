%{
#include "canal.h"
#define YYSTYPE ast *
#include <stdio.h>
extern int yylex();
extern void yyerror(const char *);
extern int yyparse();
%}

%token	IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
%token	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token	XOR_ASSIGN OR_ASSIGN
%token	TYPEDEF_NAME ENUMERATION_CONSTANT

%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token	COMPLEX IMAGINARY 
%token	STRUCT UNION ENUM ELLIPSIS

%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%debug

%%

program
    : translation_unit              { tree = new_node("program", 1, $1); }
    ;

primary_expression
	: IDENTIFIER                        { if(fc_flag) $$ = new_node("primary_expression", 1, $1); }
	| constant                          { if(fc_flag) $$ = new_node("primary_expression", 1, $1); }
	| string                            { if(fc_flag) $$ = new_node("primary_expression", 1, $1); }
	| '(' expression ')'                { if(fc_flag) $$ = new_node("primary_expression", 3, $1, $2, $3); }
	| generic_selection                 { if(fc_flag) $$ = new_node("primary_expression", 1, $1); }
	;

constant
	: I_CONSTANT		                                        { if(fc_flag) $$ = new_node("constant", 1, $1); }
	| F_CONSTANT                                                { if(fc_flag) $$ = new_node("constant", 1, $1); }
	| ENUMERATION_CONSTANT	                                    { if(fc_flag) $$ = new_node("constant", 1, $1); } 
	;

enumeration_constant		
	: IDENTIFIER                        { put_sym($1->token, ENUMERATION_CONSTANT); if(fc_flag) $$ = new_node("enumeration_constant", 1, $1); }
	;

string
	: STRING_LITERAL                    { if(fc_flag) $$ = new_node("string", 1, $1); } 
	| FUNC_NAME                         { if(fc_flag) $$ = new_node("string", 1, $1); }    
	;

generic_selection
	: GENERIC '(' assignment_expression ',' generic_assoc_list ')'       { if(fc_flag) $$ = new_node("generic_selection", 6, $1, $2, $3, $4, $5, $6); }
	;

generic_assoc_list
	: generic_association                                                  { if(fc_flag) $$ = new_node("generic_assoc_list", 1, $1); }  
	| generic_assoc_list ',' generic_association                           { if(fc_flag) $$ = new_node("generic_assoc_list", 3, $1, $2, $3); }  
	;

generic_association
	: type_name ':' assignment_expression                                   { if(fc_flag) $$ = new_node("generic_association", 3, $1, $2, $3); }  
	| DEFAULT ':' assignment_expression                                     { if(fc_flag) $$ = new_node("generic_association", 3, $1, $2, $3); }  
	;

postfix_expression
	: primary_expression                                                    { if(fc_flag) $$ = new_node("postfix_expression", 1, $1); }  
	| postfix_expression '[' expression ']'                                 { if(fc_flag) $$ = new_node("postfix_expression", 4, $1, $2, $3, $4); }  
	| postfix_expression '(' ')'                                            { if(fc_flag) $$ = new_node("postfix_expression", 3, $1, $2, $3); }  
	| postfix_expression '(' argument_expression_list ')'                   { if(fc_flag) $$ = new_node("postfix_expression", 4, $1, $2, $3, $4); }  
	| postfix_expression '.' IDENTIFIER                                     { if(fc_flag) $$ = new_node("postfix_expression", 3, $1, $2, $3); }   
	| postfix_expression PTR_OP IDENTIFIER                                  { if(fc_flag) $$ = new_node("postfix_expression", 3, $1, $2, $3); }   
	| postfix_expression INC_OP                                             { if(fc_flag) $$ = new_node("postfix_expression", 2, $1, $2); }   
	| postfix_expression DEC_OP                                             { if(fc_flag) $$ = new_node("postfix_expression", 2, $1, $2); }   
	| '(' type_name ')' '{' initializer_list '}'                            { if(fc_flag) $$ = new_node("postfix_expression", 6, $1, $2, $3, $4, $5, $6); }   
	| '(' type_name ')' '{' initializer_list ',' '}'                        { if(fc_flag) $$ = new_node("postfix_expression", 7, $1, $2, $3, $4, $5, $6, $7); }   
	;

argument_expression_list
	: assignment_expression                                                 { if(fc_flag) $$ = new_node("argument_expression_list", 1, $1); }   
	| argument_expression_list ',' assignment_expression                    { if(fc_flag) $$ = new_node("argument_expression_list", 2, $1, $2, $3); }   
	;

unary_expression
	: postfix_expression                                                    { if(fc_flag) $$ = new_node("unary_expression", 1, $1); }   
	| INC_OP unary_expression                                               { if(fc_flag) $$ = new_node("unary_expression", 2, $1, $2); }   
	| DEC_OP unary_expression                                               { if(fc_flag) $$ = new_node("unary_expression", 2, $1, $2); }   
	| unary_operator cast_expression                                        { if(fc_flag) $$ = new_node("unary_expression", 2, $1, $2); }   
	| SIZEOF unary_expression                                               { if(fc_flag) $$ = new_node("unary_expression", 2, $1, $2); }   
	| SIZEOF '(' type_name ')'                                              { if(fc_flag) $$ = new_node("unary_expression", 4, $1, $2, $3, $4); }   
	| ALIGNOF '(' type_name ')'                                             { if(fc_flag) $$ = new_node("unary_expression", 4, $1, $2, $3, $4); }   
	;

unary_operator
	: '&'                                               { if(fc_flag) $$ = new_node("unary_operator", 1, $1); }   
	| '*'                                               { if(fc_flag) $$ = new_node("unary_operator", 1, $1); }                                                
	| '+'                                               { if(fc_flag) $$ = new_node("unary_operator", 1, $1); }   
	| '-'                                               { if(fc_flag) $$ = new_node("unary_operator", 1, $1); }   
	| '~'                                               { if(fc_flag) $$ = new_node("unary_operator", 1, $1); }   
	| '!'                                               { if(fc_flag) $$ = new_node("unary_operator", 1, $1); }   
	;

cast_expression
	: unary_expression                                          { if(fc_flag) $$ = new_node("cast_expression", 1, $1); }   
	| '(' type_name ')' cast_expression                         { if(fc_flag) $$ = new_node("cast_expression", 4, $1, $2, $3, $4); }                              
	| '(' struct_or_union type_name ')' cast_expression         { if(fc_flag) $$ = new_node("cast_expression", 5, $1, $2, $3, $4, $5); }                              
	;

multiplicative_expression
	: cast_expression                                               { if(fc_flag) $$ = new_node("multiplicative_expression", 1, $1); }   
	| multiplicative_expression '*' cast_expression                 { if(fc_flag) $$ = new_node("multiplicative_expression", 3, $1, $2, $3); }   
	| multiplicative_expression '/' cast_expression                 { if(fc_flag) $$ = new_node("multiplicative_expression", 3, $1, $2, $3); }   
	| multiplicative_expression '%' cast_expression                 { if(fc_flag) $$ = new_node("multiplicative_expression", 3, $1, $2, $3); }   
	;

additive_expression
	: multiplicative_expression                                      { if(fc_flag) $$ = new_node("additive_expression", 1, $1); }           
	| additive_expression '+' multiplicative_expression              { if(fc_flag) $$ = new_node("additive_expression", 3, $1, $2, $3); }     
	| additive_expression '-' multiplicative_expression              { if(fc_flag) $$ = new_node("additive_expression", 3, $1, $2, $3); }        
	;

shift_expression
	: additive_expression                                           { if(fc_flag) $$ = new_node("shift_expression", 1, $1); }     
	| shift_expression LEFT_OP additive_expression                  { if(fc_flag) $$ = new_node("shift_expression", 3, $1, $2, $3); }
	| shift_expression RIGHT_OP additive_expression                 { if(fc_flag) $$ = new_node("shift_expression", 3, $1, $2, $3); }
	;

relational_expression
	: shift_expression                                              { if(fc_flag) $$ = new_node("relational_expression", 1, $1); } 
	| relational_expression '<' shift_expression                    { if(fc_flag) $$ = new_node("relational_expression", 3, $1, $2, $3); } 
	| relational_expression '>' shift_expression                    { if(fc_flag) $$ = new_node("relational_expression", 3, $1, $2, $3); } 
	| relational_expression LE_OP shift_expression                  { if(fc_flag) $$ = new_node("relational_expression", 3, $1, $2, $3); } 
	| relational_expression GE_OP shift_expression                  { if(fc_flag) $$ = new_node("relational_expression", 3, $1, $2, $3); } 
	;

equality_expression
	: relational_expression                                         { if(fc_flag) $$ = new_node("equality_expression", 1, $1); } 
	| equality_expression EQ_OP relational_expression               { if(fc_flag) $$ = new_node("equality_expression", 3, $1, $2, $3); } 
	| equality_expression NE_OP relational_expression               { if(fc_flag) $$ = new_node("equality_expression", 3, $1, $2, $3); }
	;

and_expression
	: equality_expression                                           { if(fc_flag) $$ = new_node("and_expression", 1, $1); } 
	| and_expression '&' equality_expression                        { if(fc_flag) $$ = new_node("and_expression", 3, $1, $2, $3); } 
	;

exclusive_or_expression
	: and_expression                                                { if(fc_flag) $$ = new_node("exclusive_or_expression", 1, $1); }
	| exclusive_or_expression '^' and_expression                    { if(fc_flag) $$ = new_node("exclusive_or_expression", 3, $1, $2, $3); }
	;

inclusive_or_expression
	: exclusive_or_expression                                       { if(fc_flag) $$ = new_node("inclusive_or_expression", 1, $1); }
	| inclusive_or_expression '|' exclusive_or_expression           { if(fc_flag) $$ = new_node("inclusive_or_expression", 3, $1, $2, $3); }
	;

logical_and_expression
	: inclusive_or_expression                                               { if(fc_flag) $$ = new_node("logical_and_expression", 1, $1); }
	| logical_and_expression AND_OP inclusive_or_expression                 { if(fc_flag) $$ = new_node("logical_and_expression", 2, $1, $2, $3); }
	;

logical_or_expression
	: logical_and_expression                                                { if(fc_flag) $$ = new_node("logical_or_expression", 1, $1); }
	| logical_or_expression OR_OP logical_and_expression                    { if(fc_flag) $$ = new_node("logical_or_expression", 3, $1, $2, $3); }
	;

conditional_expression
	: logical_or_expression                                                 { if(fc_flag) $$ = new_node("conditional_expression", 1, $1); }
	| logical_or_expression '?' expression ':' conditional_expression       { if(fc_flag) $$ = new_node("conditional_expression", 5, $1, $2, $3, $4, $5); }
	;

assignment_expression
	: conditional_expression                                                { if(fc_flag) $$ = new_node("assignment_expression", 1, $1); }
	| unary_expression assignment_operator assignment_expression            { if(fc_flag) $$ = new_node("assignment_expression", 3, $1, $2, $3); }
	;

assignment_operator
	: '='                                                   { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| MUL_ASSIGN                                            { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| DIV_ASSIGN                                            { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| MOD_ASSIGN                                            { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| ADD_ASSIGN                                            { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| SUB_ASSIGN                                            { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| LEFT_ASSIGN                                           { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| RIGHT_ASSIGN                                          { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| AND_ASSIGN                                            { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| XOR_ASSIGN                                            { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	| OR_ASSIGN                                             { if(fc_flag) $$ = new_node("assignment_operator", 1, $1); }
	;

expression
	: assignment_expression                                                     { if(fc_flag) $$ = new_node("expression", 1, $1); }
	| expression ',' assignment_expression                                      { if(fc_flag) $$ = new_node("expression", 3, $1, $2, $3); }  
	;

constant_expression
	: conditional_expression	/* with constraints */                          { if(fc_flag) $$ = new_node("constant_expression", 1, $1); }
	;

declaration
	: declaration_specifiers ';'								{ if(fc_flag) $$ = new_node("declaration", 2, $1, $2); pop_ident(); }
	| declaration_specifiers init_declarator_list ';'			{ if(fc_flag) $$ = new_node("declaration", 3, $1, $2, $3); pop_ident(); }
	| static_assert_declaration                                 { if(fc_flag) $$ = new_node("declaration", 1, $1); }
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers            { if(fc_flag) $$ = new_node("declaration_specifiers", 2, $1, $2); }
	| storage_class_specifier                                   { if(fc_flag) $$ = new_node("declaration_specifiers", 1, $1); }
	| type_specifier declaration_specifiers                     { if(fc_flag) $$ = new_node("declaration_specifiers", 2, $1, $2); }
	| type_specifier                                            { if(fc_flag) $$ = new_node("declaration_specifiers", 1, $1); }
	| type_qualifier declaration_specifiers                     { if(fc_flag) $$ = new_node("declaration_specifiers", 2, $1, $2); }
	| type_qualifier                                            { if(fc_flag) $$ = new_node("declaration_specifiers", 1, $1); }
	| function_specifier declaration_specifiers                 { if(fc_flag) $$ = new_node("declaration_specifiers", 2, $1, $2); }
	| function_specifier                                        { if(fc_flag) $$ = new_node("declaration_specifiers", 1, $1); } 
	| alignment_specifier declaration_specifiers                { if(fc_flag) $$ = new_node("declaration_specifiers", 2, $1, $2); }
	| alignment_specifier                                       { if(fc_flag) $$ = new_node("declaration_specifiers", 1, $1); }
	;

init_declarator_list
	: init_declarator                                          	{ if(fc_flag) $$ = new_node("init_declarator_list", 1, $1); }
	| init_declarator_list ',' init_declarator					{ if(fc_flag) $$ = new_node("init_declarator_list", 3, $1, $2, $3); }
	;

init_declarator
	: declarator '=' initializer								{ if(fc_flag) $$ = new_node("init_declarator", 3, $1, $2, $3); }
	| declarator								                { if(fc_flag) $$ = new_node("init_declarator", 1, $1); }
	;

storage_class_specifier
	: TYPEDEF	                            { if(fc_flag) $$ = new_node("storage_class_specifier", 1, $1); push_ident(TYPEDEF_NAME);} /* XXX identifiers must be flagged as TYPEDEF_NAME */ 
	| EXTERN								{ if(fc_flag) $$ = new_node("storage_class_specifier", 1, $1); }
	| STATIC								{ if(fc_flag) $$ = new_node("storage_class_specifier", 1, $1); }
	| THREAD_LOCAL							{ if(fc_flag) $$ = new_node("storage_class_specifier", 1, $1); }
	| AUTO								    { if(fc_flag) $$ = new_node("storage_class_specifier", 1, $1); }
	| REGISTER								{ if(fc_flag) $$ = new_node("storage_class_specifier", 1, $1); }
	;

type_specifier
	: VOID                                                                      								{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| CHAR                                                                      								{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| SHORT                                                                     								{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| INT                                                                       								{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| LONG                                                                      								{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| FLOAT                                                                     								{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| DOUBLE                                                                    								{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| SIGNED                                                                    								{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| UNSIGNED                                                                      							{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| BOOL                                                                          							{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| COMPLEX                                                                       							{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| IMAGINARY	  	/* non-mandated extension */                                                                { if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| atomic_type_specifier                                                         							{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| struct_or_union_specifier                                                     							{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| enum_specifier                                                                							{ if(fc_flag) $$ = new_node("type_specifier", 1, $1); }
	| TYPEDEF_NAME		/* after it has been defined as such */                                                 { if(fc_flag) $$ = new_node("type_specifier", 1, $1); }   
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER                                                { if(fc_flag) $$ = new_node("struct_or_union_specifier", 2, $1, $2); cur_ident($2->token); }
	| struct_or_union '{' struct_declaration_list '}'                           { if(fc_flag) $$ = new_node("struct_or_union_specifier", 4, $1, $2, $3, $4); cur_ident(NULL);  }
	| struct_or_union IDENTIFIER '{' struct_declaration_list '}'                { if(fc_flag) $$ = new_node("struct_or_union_specifier", 5, $1, $2, $3, $4, $5); cur_ident($2->token); }
	;

struct_or_union
	: STRUCT                                                                   	{ if(fc_flag) $$ = new_node("struct_or_union", 1, $1); }
	| UNION                                                                    	{ if(fc_flag) $$ = new_node("struct_or_union", 1, $1); }
	;

struct_declaration_list
	: struct_declaration                                                       	{ if(fc_flag) $$ = new_node("struct_declaration_list", 1, $1); }
	| struct_declaration_list struct_declaration                               	{ if(fc_flag) $$ = new_node("struct_declaration_list", 2, $1, $2); }
	;

struct_declaration
	: specifier_qualifier_list ';'	        /* for anonymous struct/union */    { if(fc_flag) $$ = new_node("struct_declaration", 2, $1, $2); pop_ident(); }
	| specifier_qualifier_list struct_declarator_list ';'					    { if(fc_flag) $$ = new_node("struct_declaration", 3, $1, $2, $3); pop_ident(); }	
	| static_assert_declaration								                    { if(fc_flag) $$ = new_node("struct_declaration", 1, $1); }
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list                              	{ if(fc_flag) $$ = new_node("specifier_qualifier_list", 2, $1, $2); }
	| type_specifier                                                       	{ if(fc_flag) $$ = new_node("specifier_qualifier_list", 1, $1); }
	| type_qualifier specifier_qualifier_list								{ if(fc_flag) $$ = new_node("specifier_qualifier_list", 2, $1, $2); }
	| type_qualifier								                        { if(fc_flag) $$ = new_node("specifier_qualifier_list", 1, $1); }
	;

struct_declarator_list
	: struct_declarator														{ if(fc_flag) $$ = new_node("struct_declarator_list", 1, $1); push_ident(0); }
	| struct_declarator_list ',' struct_declarator							{ if(fc_flag) $$ = new_node("struct_declarator_list", 3, $1, $2, $3); }
	;

struct_declarator
	: ':' constant_expression								            { if(fc_flag) $$ = new_node("struct_declarator", 2, $1, $2); }
	| declarator ':' constant_expression								{ if(fc_flag) $$ = new_node("struct_declarator", 3, $1, $2, $3); }
	| declarator														{ if(fc_flag) $$ = new_node("struct_declarator", 1, $1); }
	;

enum_specifier
	: ENUM '{' enumerator_list '}'								                        { if(fc_flag) $$ = new_node("enum_specifier", 4, $1, $2, $3, $4); }
	| ENUM '{' enumerator_list ',' '}'								                    { if(fc_flag) $$ = new_node("enum_specifier", 5, $1, $2, $3, $4, $5); }
	| ENUM IDENTIFIER '{' enumerator_list '}'               							{ if(fc_flag) $$ = new_node("enum_specifier", 5, $1, $2, $3, $4, $5); }
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'          								{ if(fc_flag) $$ = new_node("enum_specifier", 6, $1, $2, $3, $4, $5, $6); }
	| ENUM IDENTIFIER                                     								{ if(fc_flag) $$ = new_node("enum_specifier", 2, $1, $2); }
	;

enumerator_list
	: enumerator								                    { if(fc_flag) $$ = new_node("enumerator_list", 1, $1); }
	| enumerator_list ',' enumerator								{ if(fc_flag) $$ = new_node("enumerator_list", 3, $1, $2, $3); }
	;

enumerator	/* XXX identifiers must be flagged as ENUMERATION_CONSTANT */
	: enumeration_constant '=' constant_expression          								{ if(fc_flag) $$ = new_node("enumerator", 3, $1, $2, $3); }
	| enumeration_constant                                  								{ if(fc_flag) $$ = new_node("enumerator", 1, $1); }
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')'								{ if(fc_flag) $$ = new_node("atomic_type_specifier", 4, $1, $2, $3, $4); }
	;

type_qualifier
	: CONST								    { if(fc_flag) $$ = new_node("type_qualifier", 1, $1); }
	| RESTRICT								{ if(fc_flag) $$ = new_node("type_qualifier", 1, $1); }
	| VOLATILE								{ if(fc_flag) $$ = new_node("type_qualifier", 1, $1); }
	| ATOMIC								{ if(fc_flag) $$ = new_node("type_qualifier", 1, $1); }
	;

function_specifier
	: INLINE								{ if(fc_flag) $$ = new_node("function_specifier", 1, $1); }
	| NORETURN								{ if(fc_flag) $$ = new_node("function_specifier", 1, $1); }
	;

alignment_specifier
	: ALIGNAS '(' type_name ')'								{ if(fc_flag) $$ = new_node("alignment_specifier", 4, $1, $2, $3, $4); }
	| ALIGNAS '(' constant_expression ')'					{ if(fc_flag) $$ = new_node("alignment_specifier", 4, $1, $2, $3, $4); }
	;

declarator
	: pointer direct_declarator								{ if(fc_flag) $$ = new_node("declarator", 2, $1, $2); }
	| direct_declarator								        { if(fc_flag) $$ = new_node("declarator", 1, $1); }
	;

direct_declarator
	: IDENTIFIER                                                                    { if(fc_flag) $$ = new_node("direct_declarator", 1, $1); cur_ident($1->token); }
	| '(' declarator ')'								                            { if(fc_flag) $$ = new_node("direct_declarator", 3, $1, $2, $3); }
	| direct_declarator '[' ']'								                        { if(fc_flag) $$ = new_node("direct_declarator", 3, $1, $2, $3); }
	| direct_declarator '[' '*' ']'								                    { if(fc_flag) $$ = new_node("direct_declarator", 4, $1, $2, $3, $4); }
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'	{ if(fc_flag) $$ = new_node("direct_declarator", 6, $1, $2, $3, $4, $5, $6); }
	| direct_declarator '[' STATIC assignment_expression ']'						{ if(fc_flag) $$ = new_node("direct_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_declarator '[' type_qualifier_list '*' ']'								{ if(fc_flag) $$ = new_node("direct_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'	{ if(fc_flag) $$ = new_node("direct_declarator", 6, $1, $2, $3, $4, $5, $6); }
	| direct_declarator '[' type_qualifier_list assignment_expression ']'			{ if(fc_flag) $$ = new_node("direct_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_declarator '[' type_qualifier_list ']'								    { if(fc_flag) $$ = new_node("direct_declarator", 4, $1, $2, $3, $4); }
	| direct_declarator '[' assignment_expression ']'								{ if(fc_flag) $$ = new_node("direct_declarator", 4, $1, $2, $3, $4); }
	| direct_declarator '(' parameter_type_list ')'								    { if(fc_flag) $$ = new_node("direct_declarator", 4, $1, $2, $3, $4); }
	| direct_declarator '(' ')'								                        { if(fc_flag) $$ = new_node("direct_declarator", 3, $1, $2, $3); }
	| direct_declarator '(' identifier_list ')'								        { if(fc_flag) $$ = new_node("direct_declarator", 4, $1, $2, $3, $4); }
	;

pointer
	: '*' type_qualifier_list pointer								{ if(fc_flag) $$ = new_node("pointer", 3, $1, $2, $3); }
	| '*' type_qualifier_list								        { if(fc_flag) $$ = new_node("pointer", 2, $1, $2); }
	| '*' pointer								                    { if(fc_flag) $$ = new_node("pointer", 2, $1, $2); }
	| '*'								                            { if(fc_flag) $$ = new_node("pointer", 1, $1); }
	;

type_qualifier_list
	: type_qualifier								                { if(fc_flag) $$ = new_node("type_qualifier_list", 1, $1); }
	| type_qualifier_list type_qualifier							{ if(fc_flag) $$ = new_node("type_qualifier_list", 2, $1, $2); }
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS								{ if(fc_flag) $$ = new_node("parameter_type_list", 3, $1, $2, $3); }
	| parameter_list								            { if(fc_flag) $$ = new_node("parameter_type_list", 1, $1); }
	;

parameter_list
	: parameter_declaration								                    { if(fc_flag) $$ = new_node("parameter_list", 1, $1); }
	| parameter_list ',' parameter_declaration								{ if(fc_flag) $$ = new_node("parameter_list", 3, $1, $2, $3); }
	;

parameter_declaration
	: declaration_specifiers declarator								{ if(fc_flag) $$ = new_node("parameter_declaration", 2, $1, $2); }
	| declaration_specifiers abstract_declarator					{ if(fc_flag) $$ = new_node("parameter_declaration", 2, $1, $2); }
	| declaration_specifiers								        { if(fc_flag) $$ = new_node("parameter_declaration", 1, $1); }
	;

identifier_list
	: IDENTIFIER                                                    { if(fc_flag) $$ = new_node("identifier_list", 1, $1); cur_ident($1->token); }
	| identifier_list ',' IDENTIFIER                                { if(fc_flag) $$ = new_node("identifier_list", 3, $1, $2, $3); cur_ident($3->token); }
	;

type_name
	: specifier_qualifier_list abstract_declarator					{ if(fc_flag) $$ = new_node("type_name", 2, $1, $2); }
	| specifier_qualifier_list										{ if(fc_flag) $$ = new_node("type_name", 1, $1); }
	;

abstract_declarator
	: pointer direct_abstract_declarator						{ if(fc_flag) $$ = new_node("abstract_declarator", 2, $1, $2); }
	| pointer								                    { if(fc_flag) $$ = new_node("abstract_declarator", 1, $1); }
	| direct_abstract_declarator								{ if(fc_flag) $$ = new_node("abstract_declarator", 1, $1); }
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'								        { if(fc_flag) $$ = new_node("direct_abstract_declarator", 3, $1, $2, $3); }
	| '[' ']'								                            { if(fc_flag) $$ = new_node("direct_abstract_declarator", 2, $1, $2); }
	| '[' '*' ']'								                        { if(fc_flag) $$ = new_node("direct_abstract_declarator", 3, $1, $2, $3); }
	| '[' STATIC type_qualifier_list assignment_expression ']'			{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 5, $1, $2, $3, $4, $5); }
	| '[' STATIC assignment_expression ']'								{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| '[' type_qualifier_list STATIC assignment_expression ']'			{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 5, $1, $2, $3, $4, $5); }
	| '[' type_qualifier_list assignment_expression ']'					{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| '[' type_qualifier_list ']'								        { if(fc_flag) $$ = new_node("direct_abstract_declarator", 3, $1, $2, $3); }
	| '[' assignment_expression ']'								        { if(fc_flag) $$ = new_node("direct_abstract_declarator", 3, $1, $2, $3); }
	| direct_abstract_declarator '[' ']'								                    { if(fc_flag) $$ = new_node("direct_abstract_declarator", 3, $1, $2, $3); }
	| direct_abstract_declarator '[' '*' ']'								                { if(fc_flag) $$ = new_node("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'	{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 6, $1, $2, $3, $4, $5, $6); }
	| direct_abstract_declarator '[' STATIC assignment_expression ']'					    { if(fc_flag) $$ = new_node("direct_abstract_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'			{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'	{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 6, $1, $2, $3, $4, $5, $6); }
	| direct_abstract_declarator '[' type_qualifier_list ']'								{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| direct_abstract_declarator '[' assignment_expression ']'								{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| '(' ')'								                                                { if(fc_flag) $$ = new_node("direct_abstract_declarator", 2, $1, $2); }
	| '(' parameter_type_list ')'								                            { if(fc_flag) $$ = new_node("direct_abstract_declarator", 3, $1, $2, $3); }
	| direct_abstract_declarator '(' ')'								                    { if(fc_flag) $$ = new_node("direct_abstract_declarator", 3, $1, $2, $3); }
	| direct_abstract_declarator '(' parameter_type_list ')'								{ if(fc_flag) $$ = new_node("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	;

initializer
	: '{' initializer_list '}'								    { if(fc_flag) $$ = new_node("initializer", 3, $1, $2, $3); }
	| '{' initializer_list ',' '}'								{ if(fc_flag) $$ = new_node("initializer", 4, $1, $2, $3, $4); }
	| assignment_expression								        { if(fc_flag) $$ = new_node("initializer", 1, $1); }
	;

initializer_list
	: designation initializer								{ if(fc_flag) $$ = new_node("initializer_list", 2, $1, $2); }
	| initializer								            { if(fc_flag) $$ = new_node("initializer_list", 1, $1); }
	| initializer_list ',' designation initializer			{ if(fc_flag) $$ = new_node("initializer_list", 4, $1, $2, $3, $4); }
	| initializer_list ',' initializer						{ if(fc_flag) $$ = new_node("initializer_list", 3, $1, $2, $3); }
	;

designation
	: designator_list '='								    { if(fc_flag) $$ = new_node("designator_list", 2, $1, $2); }
	;

designator_list
	: designator								            { if(fc_flag) $$ = new_node("designator_list", 1, $1); }
	| designator_list designator							{ if(fc_flag) $$ = new_node("designator_list", 2, $1, $2); }
	;

designator
	: '[' constant_expression ']'								{ if(fc_flag) $$ = new_node("designator", 3, $1, $2, $3); }
	| '.' IDENTIFIER               								{ if(fc_flag) $$ = new_node("designator", 2, $1, $2); }
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'								{ if(fc_flag) $$ = new_node("static_assert_declaration", 7, $1, $2, $3, $4, $5, $6, $7); }
	;

statement
	: labeled_statement								    { if(fc_flag) $$ = new_node("statment", 1, $1); }
	| compound_statement								{ if(fc_flag) $$ = new_node("statment", 1, $1); }
	| expression_statement								{ if(fc_flag) $$ = new_node("statment", 1, $1); }
	| selection_statement								{ if(fc_flag) $$ = new_node("statment", 1, $1); }
	| iteration_statement								{ if(fc_flag) $$ = new_node("statment", 1, $1); }
	| jump_statement								    { if(fc_flag) $$ = new_node("statment", 1, $1); }
    | primary_expression             { if(fc_flag) $$ = new_node("statement", 1, $1); } 
	;


labeled_statement
	: IDENTIFIER ':' statement                                              { if(fc_flag) $$ = new_node("labeled_statement", 3, $1, $2, $3); }
	| CASE constant_expression ':' statement								{ if(fc_flag) $$ = new_node("labeled_statement", 4, $1, $2, $3, $4); }
	| DEFAULT ':' statement								                    { if(fc_flag) $$ = new_node("labeled_statement", 3, $1, $2, $3); }
	;

compound_statement
	: '{' '}'								                { if(fc_flag) $$ = new_node("compound_statement", 2, $1, $2); }
	| '{' block_item_list '}'								{ if(fc_flag) $$ = new_node("compound_statement", 3, $1, $2, $3); }
	;

block_item_list
	: block_item								                { if(fc_flag) $$ = new_node("block_item_list", 1, $1); }
	| block_item_list block_item								{ if(fc_flag) $$ = new_node("block_item_list", 2, $1, $2); }
	;

block_item
	: declaration								{ if(fc_flag) $$ = new_node("block_item", 1, $1); }
	| statement								    { if(fc_flag) $$ = new_node("block_item", 1, $1); }
	;

expression_statement
	: ';'																		{ if(fc_flag) $$ = new_node("expression_statement", 1, $1); pop_ident(); }
	| expression ';'															{ if(fc_flag) $$ = new_node("expression_statement", 2, $1, $2); pop_ident(); }
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement								{ if(fc_flag) $$ = new_node("selection_statement", 7, $1, $2, $3, $4, $5, $6, $7); }
	| IF '(' expression ')' statement								                { if(fc_flag) $$ = new_node("selection_statement", 5, $1, $2, $3, $4, $5); }
	| SWITCH '(' expression ')' statement								            { if(fc_flag) $$ = new_node("selection_statement", 5, $1, $2, $3, $4, $5); }
	;

iteration_statement
	: WHILE '(' expression ')' statement								            { if(fc_flag) $$ = new_node("iteration_statement", 5, $1, $2, $3, $4, $5); }
	| DO statement WHILE '(' expression ')' ';'								        { if(fc_flag) $$ = new_node("iteration_statement", 7, $1, $2, $3, $4, $5, $6, $7); }
	| FOR '(' expression_statement expression_statement ')' statement				{ if(fc_flag) $$ = new_node("iteration_statement", 6, $1, $2, $3, $4, $5, $6); }
	| FOR '(' expression_statement expression_statement expression ')' statement	{ if(fc_flag) $$ = new_node("iteration_statement", 7, $1, $2, $3, $4, $5, $6, $7); }
	| FOR '(' declaration expression_statement ')' statement						{ if(fc_flag) $$ = new_node("iteration_statement", 6, $1, $2, $3, $4, $5, $6); }
	| FOR '(' declaration expression_statement expression ')' statement				{ if(fc_flag) $$ = new_node("iteration_statement", 7, $1, $2, $3, $4, $5, $6, $7); }
	;

jump_statement
	: GOTO IDENTIFIER ';'                       { if(fc_flag) $$ = new_node("jump_statement", 3, $1, $2, $3); }
	| CONTINUE ';'								{ if(fc_flag) $$ = new_node("jump_statement", 2, $1, $2); }
	| BREAK ';'								    { if(fc_flag) $$ = new_node("jump_statement", 2, $1, $2); }
	| RETURN ';'								{ if(fc_flag) $$ = new_node("jump_statement", 2, $1, $2); }
	| RETURN expression ';'						{ if(fc_flag) $$ = new_node("jump_statement", 3, $1, $2, $3); }
	;

translation_unit
	: external_declaration                          					{ if(fc_flag) $$ = new_node("translation_unit", 1, $1); }
	| translation_unit external_declaration								{ if(fc_flag) $$ = new_node("translation_unit", 2, $1, $2); }
	;

external_declaration
	: function_definition								{ if(fc_flag) $$ = new_node("external_declaration", 1, $1); }
	| declaration								        { if(fc_flag) $$ = new_node("external_declaration", 1, $1); }
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement				{ if(fc_flag) $$ = new_node("function_definition", 4, $1, $2, $3, $4); }
	| declaration_specifiers declarator compound_statement								{ if(fc_flag) $$ = new_node("function_definition", 3, $1, $2, $3); }
	| declarator compound_statement 					/* Non standard code */         { if(fc_flag) $$ = new_node("function_definition", 2, $1, $2); }

declaration_list
	: declaration								                { if(fc_flag) $$ = new_node("declaration_list", 1, $1); }
	| declaration_list declaration								{ if(fc_flag) $$ = new_node("declaration_list", 2, $1, $2); }
	;

%%

