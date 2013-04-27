%{
#include <stdio.h>
#include "canal.h"
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

%start translation_unit

%union {
  int num;
  char *string;
}

%debug

/* NOTE pop_ident looks for a flagged typedef_name or enumeration_constant and pushes the respective ident onto the table */

%%

statement 
	: primary_expression                
	;

primary_expression
	: IDENTIFIER                        { fprintf(stderr, "y:primary_expression\n"); }
	| constant
	| string
	| '(' expression ')'
	| generic_selection
	;

constant
	: I_CONSTANT		/* includes character_constant */
	| F_CONSTANT
	| ENUMERATION_CONSTANT	/* after it has been defined as such */
	;

enumeration_constant		/* before it has been defined as such */
	: IDENTIFIER                        { cur_ident($<string>1); }
	;

string
	: STRING_LITERAL
	| FUNC_NAME
	;

generic_selection
	: GENERIC '(' assignment_expression ',' generic_assoc_list ')'
	;

generic_assoc_list
	: generic_association
	| generic_assoc_list ',' generic_association
	;

generic_association
	: type_name ':' assignment_expression
	| DEFAULT ':' assignment_expression
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER                                 {  }
	| postfix_expression PTR_OP IDENTIFIER                              {  }
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	| '(' type_name ')' '{' initializer_list '}'
	| '(' type_name ')' '{' initializer_list ',' '}'
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	| ALIGNOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression	/* with constraints */
	;

declaration
	: declaration_specifiers ';'								{ fprintf(stderr, "y:declaration_specifiers\n"); pop_ident(); }
	| declaration_specifiers init_declarator_list ';'			{ fprintf(stderr, "y:declaration_specifiers init_declarator_list\n"); pop_ident(); }
	| static_assert_declaration
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers            
	| storage_class_specifier                                   
	| type_specifier declaration_specifiers                     { fprintf(stderr, "y:type_specifier %s\n", $<string>1);  }
	| type_specifier                                            { fprintf(stderr, "y:type_specifier %s\n", $<string>1);  }
	| type_qualifier declaration_specifiers                     { fprintf(stderr, "y:type_qual %s\n", $<string>1);  }
	| type_qualifier                                            { fprintf(stderr, "y:type_qual %s\n", $<string>1);  }
	| function_specifier declaration_specifiers
	| function_specifier
	| alignment_specifier declaration_specifiers
	| alignment_specifier
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator '=' initializer
	| declarator
	;

storage_class_specifier
	: TYPEDEF	                                    { fprintf(stderr, "y:typedef\n"); push_ident(TYPEDEF_NAME); } /* XXX identifiers must be flagged as TYPEDEF_NAME */ 
	| EXTERN
	| STATIC
	| THREAD_LOCAL
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID                                                                      
	| CHAR                                                                      
	| SHORT                                                                     
	| INT                                                                       
	| LONG                                                                      
	| FLOAT                                                                     
	| DOUBLE                                                                    
	| SIGNED                                                                    
	| UNSIGNED                                                                      
	| BOOL                                                                          
	| COMPLEX                                                                       
	| IMAGINARY	  	/* non-mandated extension */                                    
	| atomic_type_specifier                                                         
	| struct_or_union_specifier                                                     
	| enum_specifier                                                                
	| TYPEDEF_NAME		/* after it has been defined as such */
    /*| error             /* XXX if we haven't added the type to the symbol table */        /*  { fprintf(stderr, "$$$$$ type not defined %s\n", $<string>1); } */
	;

struct_or_union_specifier
	: struct_or_union '{' struct_declaration_list '}'                           { fprintf(stderr, "y:struct\n") ; cur_ident(NULL); }
	| struct_or_union IDENTIFIER '{' struct_declaration_list '}'                { fprintf(stderr, "y:struct%s\n", $<string>2); cur_ident($<string>2); }
	| struct_or_union IDENTIFIER                                                { fprintf(stderr, "y:struct%s\n", $<string>2); cur_ident($<string>2); }
	;

struct_or_union
	: STRUCT                                                                    
	| UNION                                                                     
	;

struct_declaration_list
	: struct_declaration                                                        
	| struct_declaration_list struct_declaration                                
	;

struct_declaration
	: specifier_qualifier_list ';'	        /* for anonymous struct/union */ { fprintf(stderr, "y:specifier_qualifier_list %s\n", $<string>1); pop_ident(); }
	| specifier_qualifier_list struct_declarator_list ';'					 { fprintf(stderr, "y:specifier_qualifier_list struct_declarator_list %s %s\n", $<string>1, $<string>2); pop_ident(); }	
	| static_assert_declaration
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list                               { fprintf(stderr, "y:type_specifier %s\n", $<string>1);  }
	| type_specifier                                                        { fprintf(stderr, "y:type_specifier %s\n", $<string>1);  }
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator														{ fprintf(stderr, "y:struct_declarator %s\n", $<string>1); push_ident(0); }
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: ':' constant_expression
	| declarator ':' constant_expression
	| declarator															{ fprintf(stderr, "y:declarator %s\n", $<string>1); }
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'               {  }
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'           {  }
	| ENUM IDENTIFIER                                       {  }
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator	/* XXX identifiers must be flagged as ENUMERATION_CONSTANT */
	: enumeration_constant '=' constant_expression          
	| enumeration_constant                                  
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')'
	;

type_qualifier
	: CONST
	| RESTRICT
	| VOLATILE
	| ATOMIC
	;

function_specifier
	: INLINE
	| NORETURN
	;

alignment_specifier
	: ALIGNAS '(' type_name ')'
	| ALIGNAS '(' constant_expression ')'
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	;

direct_declarator
	: IDENTIFIER                                                                            { cur_ident($<string>1); }
	| '(' declarator ')'
	| direct_declarator '[' ']'
	| direct_declarator '[' '*' ']'
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_declarator '[' STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list '*' ']'
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list ']'
	| direct_declarator '[' assignment_expression ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' ')'
	| direct_declarator '(' identifier_list ')'
	;

pointer
	: '*' type_qualifier_list pointer
	| '*' type_qualifier_list
	| '*' pointer
	| '*'
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS
	| parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER                                                    { fprintf(stderr, "y:identifier_list\n"); cur_ident($<string>1); }
	| identifier_list ',' IDENTIFIER                                { fprintf(stderr, "y:identifier_list\n"); cur_ident($<string>3); }
	;

type_name
	: specifier_qualifier_list abstract_declarator					{ fprintf(stderr, "y:TYPENAME %s %s\n", $<string>1, $<string>2); }
	| specifier_qualifier_list										{ fprintf(stderr, "y:TYPENAME %s", $<string>1); }
	;

abstract_declarator
	: pointer direct_abstract_declarator
	| pointer
	| direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' '*' ']'
	| '[' STATIC type_qualifier_list assignment_expression ']'
	| '[' STATIC assignment_expression ']'
	| '[' type_qualifier_list STATIC assignment_expression ']'
	| '[' type_qualifier_list assignment_expression ']'
	| '[' type_qualifier_list ']'
	| '[' assignment_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' '*' ']'
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_abstract_declarator '[' STATIC assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list ']'
	| direct_abstract_declarator '[' assignment_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	| assignment_expression
	;

initializer_list
	: designation initializer
	| initializer
	| initializer_list ',' designation initializer
	| initializer_list ',' initializer
	;

designation
	: designator_list '='
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' constant_expression ']'
	| '.' IDENTIFIER                                                                    {  }
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement                                                          {  }
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{'  block_item_list '}'
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: declaration
	| statement
	;

expression_statement
	: ';'																		{ fprintf(stderr, "y:declaration\n"); pop_ident(); }
	| expression ';'															{ fprintf(stderr, "y:declaration\n"); pop_ident(); }
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement
	| IF '(' expression ')' statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	| FOR '(' declaration expression_statement ')' statement
	| FOR '(' declaration expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENTIFIER ';'                                                                       {  }
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	| declarator compound_statement 											/* Non standard code */

declaration_list
	: declaration
	| declaration_list declaration
	;

%%

