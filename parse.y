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
    : translation_unit              { tree = new_ast("program", 1, $1); }
    ;

statement 
    : primary_expression             { $$ = new_ast("statement", 1, $1); } 
	;

primary_expression
	: IDENTIFIER                        { $$ = new_ast("primary_expression", 1, $1); }
	| constant                          { $$ = new_ast("primary_expression", 1, $1); }
	| string                            { $$ = new_ast("primary_expression", 1, $1); }
	| '(' expression ')'                { $$ = new_ast("primary_expression", 3, $1, $2, $3); }
	| generic_selection                 { $$ = new_ast("primary_expression", 1, $1); }
	;

constant
	: I_CONSTANT		                                        { $$ = new_ast("constant", 1, $1); }
	| F_CONSTANT                                                { $$ = new_ast("constant", 1, $1); }
	| ENUMERATION_CONSTANT	                                    { $$ = new_ast("constant", 1, $1); } 
	;

enumeration_constant		
	: IDENTIFIER                        { put_sym($1->value, ENUMERATION_CONSTANT); $$ = new_ast("enumeration_constant", 1, $1); }
	;

string
	: STRING_LITERAL                    { $$ = new_ast("string", 1, $1); } 
	| FUNC_NAME                         { $$ = new_ast("string", 1, $1); }    
	;

generic_selection
	: GENERIC '(' assignment_expression ',' generic_assoc_list ')'       { $$ = new_ast("generic_selection", 6, $1, $2, $3, $4, $5, $6); }
	;

generic_assoc_list
	: generic_association                                                  { $$ = new_ast("generic_assoc_list", 1, $1); }  
	| generic_assoc_list ',' generic_association                           { $$ = new_ast("generic_assoc_list", 3, $1, $2, $3); }  
	;

generic_association
	: type_name ':' assignment_expression                                   { $$ = new_ast("generic_association", 3, $1, $2, $3); }  
	| DEFAULT ':' assignment_expression                                     { $$ = new_ast("generic_association", 3, $1, $2, $3); }  
	;

postfix_expression
	: primary_expression                                                    { $$ = new_ast("postfix_expression", 1, $1); }  
	| postfix_expression '[' expression ']'                                 { $$ = new_ast("postfix_expression", 4, $1, $2, $3, $4); }  
	| postfix_expression '(' ')'                                            { $$ = new_ast("postfix_expression", 3, $1, $2, $3); }  
	| postfix_expression '(' argument_expression_list ')'                   { $$ = new_ast("postfix_expression", 4, $1, $2, $3, $4); }  
	| postfix_expression '.' IDENTIFIER                                     { $$ = new_ast("postfix_expression", 3, $1, $2, $3); }   
	| postfix_expression PTR_OP IDENTIFIER                                  { $$ = new_ast("postfix_expression", 3, $1, $2, $3); }   
	| postfix_expression INC_OP                                             { $$ = new_ast("postfix_expression", 2, $1, $2); }   
	| postfix_expression DEC_OP                                             { $$ = new_ast("postfix_expression", 2, $1, $2); }   
	| '(' type_name ')' '{' initializer_list '}'                            { $$ = new_ast("postfix_expression", 6, $1, $2, $3, $4, $5, $6); }   
	| '(' type_name ')' '{' initializer_list ',' '}'                        { $$ = new_ast("postfix_expression", 7, $1, $2, $3, $4, $5, $6, $7); }   
	;

argument_expression_list
	: assignment_expression                                                 { $$ = new_ast("argument_expression_list", 1, $1); }   
	| argument_expression_list ',' assignment_expression                    { $$ = new_ast("argument_expression_list", 2, $1, $2, $3); }   
	;

unary_expression
	: postfix_expression                                                    { $$ = new_ast("unary_expression", 1, $1); }   
	| INC_OP unary_expression                                               { $$ = new_ast("unary_expression", 2, $1, $2); }   
	| DEC_OP unary_expression                                               { $$ = new_ast("unary_expression", 2, $1, $2); }   
	| unary_operator cast_expression                                        { $$ = new_ast("unary_expression", 2, $1, $2); }   
	| SIZEOF unary_expression                                               { $$ = new_ast("unary_expression", 2, $1, $2); }   
	| SIZEOF '(' type_name ')'                                              { $$ = new_ast("unary_expression", 4, $1, $2, $3, $4); }   
	| ALIGNOF '(' type_name ')'                                             { $$ = new_ast("unary_expression", 4, $1, $2, $3, $4); }   
	;

unary_operator
	: '&'                                               { $$ = new_ast("unary_operator", 1, $1); }   
	| '*'                                               { $$ = new_ast("unary_operator", 1, $1); }                                                
	| '+'                                               { $$ = new_ast("unary_operator", 1, $1); }   
	| '-'                                               { $$ = new_ast("unary_operator", 1, $1); }   
	| '~'                                               { $$ = new_ast("unary_operator", 1, $1); }   
	| '!'                                               { $$ = new_ast("unary_operator", 1, $1); }   
	;

cast_expression
	: unary_expression                                  { $$ = new_ast("cast_expression", 1, $1); }   
	| '(' type_name ')' cast_expression                 { $$ = new_ast("cast_expression", 4, $1, $2, $3, $4); }                              
	;

multiplicative_expression
	: cast_expression                                               { $$ = new_ast("multiplicative_expression", 1, $1); }   
	| multiplicative_expression '*' cast_expression                 { $$ = new_ast("multiplicative_expression", 3, $1, $2, $3); }   
	| multiplicative_expression '/' cast_expression                 { $$ = new_ast("multiplicative_expression", 3, $1, $2, $3); }   
	| multiplicative_expression '%' cast_expression                 { $$ = new_ast("multiplicative_expression", 3, $1, $2, $3); }   
	;

additive_expression
	: multiplicative_expression                                      { $$ = new_ast("additive_expression", 1, $1); }           
	| additive_expression '+' multiplicative_expression              { $$ = new_ast("additive_expression", 3, $1, $2, $3); }     
	| additive_expression '-' multiplicative_expression              { $$ = new_ast("additive_expression", 3, $1, $2, $3); }        
	;

shift_expression
	: additive_expression                                           { $$ = new_ast("shift_expression", 1, $1); }     
	| shift_expression LEFT_OP additive_expression                  { $$ = new_ast("shift_expression", 3, $1, $2, $3); }
	| shift_expression RIGHT_OP additive_expression                 { $$ = new_ast("shift_expression", 3, $1, $2, $3); }
	;

relational_expression
	: shift_expression                                              { $$ = new_ast("relational_expression", 1, $1); } 
	| relational_expression '<' shift_expression                    { $$ = new_ast("relational_expression", 3, $1, $2, $3); } 
	| relational_expression '>' shift_expression                    { $$ = new_ast("relational_expression", 3, $1, $2, $3); } 
	| relational_expression LE_OP shift_expression                  { $$ = new_ast("relational_expression", 3, $1, $2, $3); } 
	| relational_expression GE_OP shift_expression                  { $$ = new_ast("relational_expression", 3, $1, $2, $3); } 
	;

equality_expression
	: relational_expression                                         { $$ = new_ast("equality_expression", 1, $1); } 
	| equality_expression EQ_OP relational_expression               { $$ = new_ast("equality_expression", 3, $1, $2, $3); } 
	| equality_expression NE_OP relational_expression               { $$ = new_ast("equality_expression", 3, $1, $2, $3); }
	;

and_expression
	: equality_expression                                           { $$ = new_ast("and_expression", 1, $1); } 
	| and_expression '&' equality_expression                        { $$ = new_ast("and_expression", 3, $1, $2, $3); } 
	;

exclusive_or_expression
	: and_expression                                                { $$ = new_ast("exclusive_or_expression", 1, $1); }
	| exclusive_or_expression '^' and_expression                    { $$ = new_ast("exclusive_or_expression", 3, $1, $2, $3); }
	;

inclusive_or_expression
	: exclusive_or_expression                                       { $$ = new_ast("inclusive_or_expression", 1, $1); }
	| inclusive_or_expression '|' exclusive_or_expression           { $$ = new_ast("inclusive_or_expression", 3, $1, $2, $3); }
	;

logical_and_expression
	: inclusive_or_expression                                               { $$ = new_ast("logical_and_expression", 1, $1); }
	| logical_and_expression AND_OP inclusive_or_expression                 { $$ = new_ast("logical_and_expression", 2, $1, $2, $3); }
	;

logical_or_expression
	: logical_and_expression                                                { $$ = new_ast("logical_or_expression", 1, $1); }
	| logical_or_expression OR_OP logical_and_expression                    { $$ = new_ast("logical_or_expression", 3, $1, $2, $3); }
	;

conditional_expression
	: logical_or_expression                                                 { $$ = new_ast("conditional_expression", 1, $1); }
	| logical_or_expression '?' expression ':' conditional_expression       { $$ = new_ast("conditional_expression", 5, $1, $2, $3, $4, $5); }
	;

assignment_expression
	: conditional_expression                                                { $$ = new_ast("assignment_expression", 1, $1); }
	| unary_expression assignment_operator assignment_expression            { $$ = new_ast("assignment_expression", 3, $1, $2, $3); }
	;

assignment_operator
	: '='                                                   { $$ = new_ast("assignment_operator", 1, $1); }
	| MUL_ASSIGN                                            { $$ = new_ast("assignment_operator", 1, $1); }
	| DIV_ASSIGN                                            { $$ = new_ast("assignment_operator", 1, $1); }
	| MOD_ASSIGN                                            { $$ = new_ast("assignment_operator", 1, $1); }
	| ADD_ASSIGN                                            { $$ = new_ast("assignment_operator", 1, $1); }
	| SUB_ASSIGN                                            { $$ = new_ast("assignment_operator", 1, $1); }
	| LEFT_ASSIGN                                           { $$ = new_ast("assignment_operator", 1, $1); }
	| RIGHT_ASSIGN                                          { $$ = new_ast("assignment_operator", 1, $1); }
	| AND_ASSIGN                                            { $$ = new_ast("assignment_operator", 1, $1); }
	| XOR_ASSIGN                                            { $$ = new_ast("assignment_operator", 1, $1); }
	| OR_ASSIGN                                             { $$ = new_ast("assignment_operator", 1, $1); }
	;

expression
	: assignment_expression                                                     { $$ = new_ast("expression", 1, $1); }
	| expression ',' assignment_expression                                      { $$ = new_ast("expression", 3, $1, $2, $3); }  
	;

constant_expression
	: conditional_expression	/* with constraints */                          { $$ = new_ast("constant_expression", 1, $1); }
	;

declaration
	: declaration_specifiers ';'								{ $$ = new_ast("declaration", 2, $1, $2); pop_ident(); }
	| declaration_specifiers init_declarator_list ';'			{ $$ = new_ast("declaration", 3, $1, $2, $3); pop_ident(); }
	| static_assert_declaration                                 { $$ = new_ast("declaration", 1, $1); }
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers            { $$ = new_ast("declaration_specifiers", 2, $1, $2); }
	| storage_class_specifier                                   { $$ = new_ast("declaration_specifiers", 1, $1); }
	| type_specifier declaration_specifiers                     { $$ = new_ast("declaration_specifiers", 2, $1, $2); }
	| type_specifier                                            { $$ = new_ast("declaration_specifiers", 1, $1); }
	| type_qualifier declaration_specifiers                     { $$ = new_ast("declaration_specifiers", 2, $1, $2); }
	| type_qualifier                                            { $$ = new_ast("declaration_specifiers", 1, $1); }
	| function_specifier declaration_specifiers                 { $$ = new_ast("declaration_specifiers", 2, $1, $2); }
	| function_specifier                                        { $$ = new_ast("declaration_specifiers", 1, $1); } 
	| alignment_specifier declaration_specifiers                { $$ = new_ast("declaration_specifiers", 2, $1, $2); }
	| alignment_specifier                                       { $$ = new_ast("declaration_specifiers", 1, $1); }
	;

init_declarator_list
	: init_declarator                                          	{ $$ = new_ast("init_declarator_list", 1, $1); }
	| init_declarator_list ',' init_declarator					{ $$ = new_ast("init_declarator_list", 3, $1, $2, $3); }
	;

init_declarator
	: declarator '=' initializer								{ $$ = new_ast("init_declarator", 3, $1, $2, $3); }
	| declarator								                { $$ = new_ast("init_declarator", 1, $1); }
	;

storage_class_specifier
	: TYPEDEF	                            { $$ = new_ast("storage_class_specifier", 1, $1); push_ident(TYPEDEF_NAME);} /* XXX identifiers must be flagged as TYPEDEF_NAME */ 
	| EXTERN								{ $$ = new_ast("storage_class_specifier", 1, $1); }
	| STATIC								{ $$ = new_ast("storage_class_specifier", 1, $1); }
	| THREAD_LOCAL							{ $$ = new_ast("storage_class_specifier", 1, $1); }
	| AUTO								    { $$ = new_ast("storage_class_specifier", 1, $1); }
	| REGISTER								{ $$ = new_ast("storage_class_specifier", 1, $1); }
	;

type_specifier
	: VOID                                                                      								{ $$ = new_ast("type_specifier", 1, $1); }
	| CHAR                                                                      								{ $$ = new_ast("type_specifier", 1, $1); }
	| SHORT                                                                     								{ $$ = new_ast("type_specifier", 1, $1); }
	| INT                                                                       								{ $$ = new_ast("type_specifier", 1, $1); }
	| LONG                                                                      								{ $$ = new_ast("type_specifier", 1, $1); }
	| FLOAT                                                                     								{ $$ = new_ast("type_specifier", 1, $1); }
	| DOUBLE                                                                    								{ $$ = new_ast("type_specifier", 1, $1); }
	| SIGNED                                                                    								{ $$ = new_ast("type_specifier", 1, $1); }
	| UNSIGNED                                                                      							{ $$ = new_ast("type_specifier", 1, $1); }
	| BOOL                                                                          							{ $$ = new_ast("type_specifier", 1, $1); }
	| COMPLEX                                                                       							{ $$ = new_ast("type_specifier", 1, $1); }
	| IMAGINARY	  	/* non-mandated extension */                                                                { $$ = new_ast("type_specifier", 1, $1); }
	| atomic_type_specifier                                                         							{ $$ = new_ast("type_specifier", 1, $1); }
	| struct_or_union_specifier                                                     							{ $$ = new_ast("type_specifier", 1, $1); }
	| enum_specifier                                                                							{ $$ = new_ast("type_specifier", 1, $1); }
	| TYPEDEF_NAME		/* after it has been defined as such */                                                 { $$ = new_ast("type_specifier", 1, $1); }   
	;

struct_or_union_specifier
	: struct_or_union '{' struct_declaration_list '}'                           { $$ = new_ast("struct_or_union_specifier", 4, $1, $2, $3, $4); cur_ident(NULL);  }
	| struct_or_union IDENTIFIER '{' struct_declaration_list '}'                { $$ = new_ast("struct_or_union_specifier", 5, $1, $2, $3, $4, $5); cur_ident($2->value); }
	| struct_or_union IDENTIFIER                                                { $$ = new_ast("struct_or_union_specifier", 2, $1, $2); cur_ident($2->value); }
	;

struct_or_union
	: STRUCT                                                                   	{ $$ = new_ast("struct_or_union", 1, $1); }
	| UNION                                                                    	{ $$ = new_ast("struct_or_union", 1, $1); }
	;

struct_declaration_list
	: struct_declaration                                                       	{ $$ = new_ast("struct_declaration_list", 1, $1); }
	| struct_declaration_list struct_declaration                               	{ $$ = new_ast("struct_declaration_list", 2, $1, $2); }
	;

struct_declaration
	: specifier_qualifier_list ';'	        /* for anonymous struct/union */    { $$ = new_ast("struct_declaration", 2, $1, $2); pop_ident(); }
	| specifier_qualifier_list struct_declarator_list ';'					    { $$ = new_ast("struct_declaration", 3, $1, $2, $3); pop_ident(); }	
	| static_assert_declaration								                    { $$ = new_ast("struct_declaration", 1, $1); }
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list                              	{ $$ = new_ast("specifier_qualifier_list", 2, $1, $2); }
	| type_specifier                                                       	{ $$ = new_ast("specifier_qualifier_list", 1, $1); }
	| type_qualifier specifier_qualifier_list								{ $$ = new_ast("specifier_qualifier_list", 2, $1, $2); }
	| type_qualifier								                        { $$ = new_ast("specifier_qualifier_list", 1, $1); }
	;

struct_declarator_list
	: struct_declarator														{ $$ = new_ast("struct_declarator_list", 1, $1); push_ident(0); }
	| struct_declarator_list ',' struct_declarator							{ $$ = new_ast("struct_declarator_list", 3, $1, $2, $3); }
	;

struct_declarator
	: ':' constant_expression								            { $$ = new_ast("struct_declarator", 2, $1, $2); }
	| declarator ':' constant_expression								{ $$ = new_ast("struct_declarator", 3, $1, $2, $3); }
	| declarator														{ $$ = new_ast("struct_declarator", 1, $1); }
	;

enum_specifier
	: ENUM '{' enumerator_list '}'								                        { $$ = new_ast("enum_specifier", 4, $1, $2, $3, $4); }
	| ENUM '{' enumerator_list ',' '}'								                    { $$ = new_ast("enum_specifier", 5, $1, $2, $3, $4, $5); }
	| ENUM IDENTIFIER '{' enumerator_list '}'               							{ $$ = new_ast("enum_specifier", 5, $1, $2, $3, $4, $5); }
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'          								{ $$ = new_ast("enum_specifier", 6, $1, $2, $3, $4, $5, $6); }
	| ENUM IDENTIFIER                                     								{ $$ = new_ast("enum_specifier", 2, $1, $2); }
	;

enumerator_list
	: enumerator								                    { $$ = new_ast("enumerator_list", 1, $1); }
	| enumerator_list ',' enumerator								{ $$ = new_ast("enumerator_list", 3, $1, $2, $3); }
	;

enumerator	/* XXX identifiers must be flagged as ENUMERATION_CONSTANT */
	: enumeration_constant '=' constant_expression          								{ $$ = new_ast("enumerator", 3, $1, $2, $3); }
	| enumeration_constant                                  								{ $$ = new_ast("enumerator", 1, $1); }
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')'								{ $$ = new_ast("atomic_type_specifier", 4, $1, $2, $3, $4); }
	;

type_qualifier
	: CONST								    { $$ = new_ast("type_qualifier", 1, $1); }
	| RESTRICT								{ $$ = new_ast("type_qualifier", 1, $1); }
	| VOLATILE								{ $$ = new_ast("type_qualifier", 1, $1); }
	| ATOMIC								{ $$ = new_ast("type_qualifier", 1, $1); }
	;

function_specifier
	: INLINE								{ $$ = new_ast("function_specifier", 1, $1); }
	| NORETURN								{ $$ = new_ast("function_specifier", 1, $1); }
	;

alignment_specifier
	: ALIGNAS '(' type_name ')'								{ $$ = new_ast("alignment_specifier", 4, $1, $2, $3, $4); }
	| ALIGNAS '(' constant_expression ')'					{ $$ = new_ast("alignment_specifier", 4, $1, $2, $3, $4); }
	;

declarator
	: pointer direct_declarator								{ $$ = new_ast("declarator", 2, $1, $2); }
	| direct_declarator								        { $$ = new_ast("declarator", 1, $1); }
	;

direct_declarator
	: IDENTIFIER                                                                    { $$ = new_ast("direct_declarator", 1, $1); cur_ident($1->value); }
	| '(' declarator ')'								                            { $$ = new_ast("direct_declarator", 3, $1, $2, $3); }
	| direct_declarator '[' ']'								                        { $$ = new_ast("direct_declarator", 3, $1, $2, $3); }
	| direct_declarator '[' '*' ']'								                    { $$ = new_ast("direct_declarator", 4, $1, $2, $3, $4); }
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'	{ $$ = new_ast("direct_declarator", 6, $1, $2, $3, $4, $5, $6); }
	| direct_declarator '[' STATIC assignment_expression ']'						{ $$ = new_ast("direct_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_declarator '[' type_qualifier_list '*' ']'								{ $$ = new_ast("direct_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'	{ $$ = new_ast("direct_declarator", 6, $1, $2, $3, $4, $5, $6); }
	| direct_declarator '[' type_qualifier_list assignment_expression ']'			{ $$ = new_ast("direct_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_declarator '[' type_qualifier_list ']'								    { $$ = new_ast("direct_declarator", 4, $1, $2, $3, $4); }
	| direct_declarator '[' assignment_expression ']'								{ $$ = new_ast("direct_declarator", 4, $1, $2, $3, $4); }
	| direct_declarator '(' parameter_type_list ')'								    { $$ = new_ast("direct_declarator", 4, $1, $2, $3, $4); }
	| direct_declarator '(' ')'								                        { $$ = new_ast("direct_declarator", 3, $1, $2, $3); }
	| direct_declarator '(' identifier_list ')'								        { $$ = new_ast("direct_declarator", 4, $1, $2, $3, $4); }
	;

pointer
	: '*' type_qualifier_list pointer								{ $$ = new_ast("pointer", 3, $1, $2, $3); }
	| '*' type_qualifier_list								        { $$ = new_ast("pointer", 2, $1, $2); }
	| '*' pointer								                    { $$ = new_ast("pointer", 2, $1, $2); }
	| '*'								                            { $$ = new_ast("pointer", 1, $1); }
	;

type_qualifier_list
	: type_qualifier								                { $$ = new_ast("type_qualifier_list", 1, $1); }
	| type_qualifier_list type_qualifier							{ $$ = new_ast("type_qualifier_list", 2, $1, $2); }
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS								{ $$ = new_ast("parameter_type_list", 3, $1, $2, $3); }
	| parameter_list								            { $$ = new_ast("parameter_type_list", 1, $1); }
	;

parameter_list
	: parameter_declaration								                    { $$ = new_ast("parameter_list", 1, $1); }
	| parameter_list ',' parameter_declaration								{ $$ = new_ast("parameter_list", 3, $1, $2, $3); }
	;

parameter_declaration
	: declaration_specifiers declarator								{ $$ = new_ast("parameter_declaration", 2, $1, $2); }
	| declaration_specifiers abstract_declarator					{ $$ = new_ast("parameter_declaration", 2, $1, $2); }
	| declaration_specifiers								        { $$ = new_ast("parameter_declaration", 1, $1); }
	;

identifier_list
	: IDENTIFIER                                                    { $$ = new_ast("identifier_list", 1, $1); cur_ident($1->value); }
	| identifier_list ',' IDENTIFIER                                { $$ = new_ast("identifier_list", 3, $1, $2, $3); cur_ident($3->value); }
	;

type_name
	: specifier_qualifier_list abstract_declarator					{ $$ = new_ast("type_name", 2, $1, $2); }
	| specifier_qualifier_list										{ $$ = new_ast("type_name", 1, $1); }
	;

abstract_declarator
	: pointer direct_abstract_declarator						{ $$ = new_ast("abstract_declarator", 2, $1, $2); }
	| pointer								                    { $$ = new_ast("abstract_declarator", 1, $1); }
	| direct_abstract_declarator								{ $$ = new_ast("abstract_declarator", 1, $1); }
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'								        { $$ = new_ast("direct_abstract_declarator", 3, $1, $2, $3); }
	| '[' ']'								                            { $$ = new_ast("direct_abstract_declarator", 2, $1, $2); }
	| '[' '*' ']'								                        { $$ = new_ast("direct_abstract_declarator", 3, $1, $2, $3); }
	| '[' STATIC type_qualifier_list assignment_expression ']'			{ $$ = new_ast("direct_abstract_declarator", 5, $1, $2, $3, $4, $5); }
	| '[' STATIC assignment_expression ']'								{ $$ = new_ast("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| '[' type_qualifier_list STATIC assignment_expression ']'			{ $$ = new_ast("direct_abstract_declarator", 5, $1, $2, $3, $4, $5); }
	| '[' type_qualifier_list assignment_expression ']'					{ $$ = new_ast("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| '[' type_qualifier_list ']'								        { $$ = new_ast("direct_abstract_declarator", 3, $1, $2, $3); }
	| '[' assignment_expression ']'								        { $$ = new_ast("direct_abstract_declarator", 3, $1, $2, $3); }
	| direct_abstract_declarator '[' ']'								                    { $$ = new_ast("direct_abstract_declarator", 3, $1, $2, $3); }
	| direct_abstract_declarator '[' '*' ']'								                { $$ = new_ast("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'	{ $$ = new_ast("direct_abstract_declarator", 6, $1, $2, $3, $4, $5, $6); }
	| direct_abstract_declarator '[' STATIC assignment_expression ']'					    { $$ = new_ast("direct_abstract_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'			{ $$ = new_ast("direct_abstract_declarator", 5, $1, $2, $3, $4, $5); }
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'	{ $$ = new_ast("direct_abstract_declarator", 6, $1, $2, $3, $4, $5, $6); }
	| direct_abstract_declarator '[' type_qualifier_list ']'								{ $$ = new_ast("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| direct_abstract_declarator '[' assignment_expression ']'								{ $$ = new_ast("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	| '(' ')'								                                                { $$ = new_ast("direct_abstract_declarator", 2, $1, $2); }
	| '(' parameter_type_list ')'								                            { $$ = new_ast("direct_abstract_declarator", 3, $1, $2, $3); }
	| direct_abstract_declarator '(' ')'								                    { $$ = new_ast("direct_abstract_declarator", 3, $1, $2, $3); }
	| direct_abstract_declarator '(' parameter_type_list ')'								{ $$ = new_ast("direct_abstract_declarator", 4, $1, $2, $3, $4); }
	;

initializer
	: '{' initializer_list '}'								    { $$ = new_ast("initializer", 3, $1, $2, $3); }
	| '{' initializer_list ',' '}'								{ $$ = new_ast("initializer", 4, $1, $2, $3, $4); }
	| assignment_expression								        { $$ = new_ast("initializer", 1, $1); }
	;

initializer_list
	: designation initializer								{ $$ = new_ast("initializer_list", 2, $1, $2); }
	| initializer								            { $$ = new_ast("initializer_list", 1, $1); }
	| initializer_list ',' designation initializer			{ $$ = new_ast("initializer_list", 4, $1, $2, $3, $4); }
	| initializer_list ',' initializer						{ $$ = new_ast("initializer_list", 3, $1, $2, $3); }
	;

designation
	: designator_list '='								    { $$ = new_ast("designator_list", 2, $1, $2); }
	;

designator_list
	: designator								            { $$ = new_ast("designator_list", 1, $1); }
	| designator_list designator							{ $$ = new_ast("designator_list", 2, $1, $2); }
	;

designator
	: '[' constant_expression ']'								{ $$ = new_ast("designator", 3, $1, $2, $3); }
	| '.' IDENTIFIER               								{ $$ = new_ast("designator", 2, $1, $2); }
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'								{ $$ = new_ast("static_assert_declaration", 7, $1, $2, $3, $4, $5, $6, $7); }
	;

statement
	: labeled_statement								    { $$ = new_ast("statment", 1, $1); }
	| compound_statement								{ $$ = new_ast("statment", 1, $1); }
	| expression_statement								{ $$ = new_ast("statment", 1, $1); }
	| selection_statement								{ $$ = new_ast("statment", 1, $1); }
	| iteration_statement								{ $$ = new_ast("statment", 1, $1); }
	| jump_statement								    { $$ = new_ast("statment", 1, $1); }
	;

labeled_statement
	: IDENTIFIER ':' statement                                              { $$ = new_ast("labeled_statement", 3, $1, $2, $3); }
	| CASE constant_expression ':' statement								{ $$ = new_ast("labeled_statement", 4, $1, $2, $3, $4); }
	| DEFAULT ':' statement								                    { $$ = new_ast("labeled_statement", 3, $1, $2, $3); }
	;

compound_statement
	: '{' '}'								                { $$ = new_ast("compound_statement", 2, $1, $2); }
	| '{' block_item_list '}'								{ $$ = new_ast("compound_statement", 3, $1, $2, $3); }
	;

block_item_list
	: block_item								                { $$ = new_ast("block_item_list", 1, $1); }
	| block_item_list block_item								{ $$ = new_ast("block_item_list", 2, $1, $2); }
	;

block_item
	: declaration								{ $$ = new_ast("block_item", 1, $1); }
	| statement								    { $$ = new_ast("block_item", 1, $1); }
	;

expression_statement
	: ';'																		{ $$ = new_ast("expression_statement", 1, $1); pop_ident(); }
	| expression ';'															{ $$ = new_ast("expression_statement", 2, $1, $2); pop_ident(); }
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement								{ $$ = new_ast("selection_statement", 7, $1, $2, $3, $4, $5, $6, $7); }
	| IF '(' expression ')' statement								                { $$ = new_ast("selection_statement", 5, $1, $2, $3, $4, $5); }
	| SWITCH '(' expression ')' statement								            { $$ = new_ast("selection_statement", 5, $1, $2, $3, $4, $5); }
	;

iteration_statement
	: WHILE '(' expression ')' statement								            { $$ = new_ast("iteration_statement", 5, $1, $2, $3, $4, $5); }
	| DO statement WHILE '(' expression ')' ';'								        { $$ = new_ast("iteration_statement", 7, $1, $2, $3, $4, $5, $6, $7); }
	| FOR '(' expression_statement expression_statement ')' statement				{ $$ = new_ast("iteration_statement", 6, $1, $2, $3, $4, $5, $6); }
	| FOR '(' expression_statement expression_statement expression ')' statement	{ $$ = new_ast("iteration_statement", 7, $1, $2, $3, $4, $5, $6, $7); }
	| FOR '(' declaration expression_statement ')' statement						{ $$ = new_ast("iteration_statement", 6, $1, $2, $3, $4, $5, $6); }
	| FOR '(' declaration expression_statement expression ')' statement				{ $$ = new_ast("iteration_statement", 7, $1, $2, $3, $4, $5, $6, $7); }
	;

jump_statement
	: GOTO IDENTIFIER ';'                       { $$ = new_ast("jump_statement", 3, $1, $2, $3); }
	| CONTINUE ';'								{ $$ = new_ast("jump_statement", 2, $1, $2); }
	| BREAK ';'								    { $$ = new_ast("jump_statement", 2, $1, $2); }
	| RETURN ';'								{ $$ = new_ast("jump_statement", 2, $1, $2); }
	| RETURN expression ';'						{ $$ = new_ast("jump_statement", 3, $1, $2, $3); }
	;

translation_unit
	: external_declaration                          					{ $$ = new_ast("translation_unit", 1, $1); }
	| translation_unit external_declaration								{ $$ = new_ast("translation_unit", 2, $1, $2); }
	;

external_declaration
	: function_definition								{ $$ = new_ast("external_declaration", 1, $1); }
	| declaration								        { $$ = new_ast("external_declaration", 1, $1); }
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement				{ $$ = new_ast("function_definition", 4, $1, $2, $3, $4); }
	| declaration_specifiers declarator compound_statement								{ $$ = new_ast("function_definition", 3, $1, $2, $3); }
	| declarator compound_statement 					/* Non standard code */         { $$ = new_ast("function_definition", 2, $1, $2); }

declaration_list
	: declaration								                { $$ = new_ast("declaration_list", 1, $1); }
	| declaration_list declaration								{ $$ = new_ast("declaration_list", 2, $1, $2); }
	;

%%

