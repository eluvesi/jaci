%code {
	#include <stdio.h>

	extern int yylineno;
	extern char *yytext;
	extern int error_count;

	int yylex(void);
	void yyerror(const char *s)
	{
		error_count++;
		fprintf(stderr, "%s at line %d near '%s'\n", s,
		        yytext[0] == '\n' ? yylineno - 1 : yylineno,
		        yytext[0] == '\n' ? "\\n" : yytext);
	}
}

%defines "parser.h"
%output  "parser.c"

%token AND BREAK DO ELSE ELSEIF END FALSE FOR FUNCTION GLOBAL GOTO
%token IF IN LOCAL NIL NOT OR REPEAT RETURN THEN TRUE UNTIL WHILE

%token ADD SUB MUL DIV MOD POW LEN BAND BXOR BOR SHL SHR IDIV
%token EQ NE LE GE LT GT
%token ASSIGN LABEL SEMI COLON COMMA DOT CONCAT ELLIPSIS
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK

%token NAME NUMBER STRING

%token UMINUS BNOT

%left OR
%left AND
%left LT GT LE GE EQ NE
%left BOR
%left BXOR
%left BAND
%left SHL SHR
%right CONCAT
%left ADD SUB
%left MUL DIV MOD IDIV
%right NOT LEN UMINUS BNOT
%right POW

%%

chunk:
	  block
	;

block:
	  stat_list opt_retstat
    ;

opt_retstat:
	  /* empty */
	| retstat
	;

stat_list:
	  /* empty */
	| stat_list stat
	;

stat:
	  SEMI
	| varlist ASSIGN explist
	| functioncall
	| label
	| BREAK
	| GOTO NAME
	| DO block END
	| WHILE exp DO block END
	| REPEAT block UNTIL exp
	| IF exp THEN block elseif_list opt_else_block END
	| FOR NAME ASSIGN exp COMMA exp opt_comma_exp DO block END
	| FOR namelist IN explist DO block END
	| FUNCTION funcname funcbody
	| LOCAL FUNCTION NAME funcbody
	| GLOBAL FUNCTION NAME funcbody
	| LOCAL attnamelist opt_assign_explist
	| GLOBAL attnamelist
	| GLOBAL opt_attrib MUL
	;

elseif_list:
	  /* empty */
	| elseif_list ELSEIF exp THEN block
	;

opt_else_block:
	  /* empty */
	| ELSE block
	;

opt_comma_exp:
	  /* empty */
	| COMMA exp
	;

opt_assign_explist:
	  /* empty */
	| ASSIGN explist
	;

opt_attrib:
	  /* empty */ 
	| attrib 
	;

attnamelist:
	  opt_attrib NAME opt_attrib name_attrib_list
	;

name_attrib_list:
	  /* empty */
	| name_attrib_list COMMA NAME opt_attrib
	;

attrib:
	  LT NAME GT 
	;

retstat:
	  RETURN opt_explist opt_semi
    ;

opt_explist:
	  /* empty */
	| explist
	;

opt_semi:
	  /* empty */ 
	| SEMI 
	;

label:
	  LABEL NAME LABEL
	;

funcname:
	  NAME dot_name_list opt_colon_name
    ;

dot_name_list:
	  /* empty */
	| dot_name_list DOT NAME
	;

opt_colon_name:
	  /* empty */
	| COLON NAME
	;

varlist:
      var
    | varlist COMMA var
    ;

var:
	  NAME
	| prefixexp LBRACK exp RBRACK
	| prefixexp DOT NAME
	;

namelist:
	  NAME
	| namelist COMMA NAME
	;

explist:
	  exp
	| explist COMMA exp
	;

exp:
	  NIL | FALSE | TRUE | NUMBER | STRING | ELLIPSIS
	| functiondef
	| prefixexp
	| tableconstructor

	| exp ADD exp
	| exp SUB exp
	| exp MUL exp
	| exp DIV exp
	| exp IDIV exp
	| exp POW exp
	| exp MOD exp
	| exp BAND exp
	| exp BXOR exp
	| exp BOR exp
	| exp SHL exp
	| exp SHR exp
	| exp CONCAT exp
	| exp LT exp
	| exp LE exp
	| exp GT exp
	| exp GE exp
	| exp EQ exp
	| exp NE exp
	| exp AND exp
	| exp OR exp

	| SUB exp %prec UMINUS
	| NOT exp
	| LEN exp
	| BXOR exp %prec BNOT
	;

prefixexp:
	  var
	| functioncall
	| LPAREN exp RPAREN
	;

functioncall:
	  prefixexp args
	| prefixexp COLON NAME args
	;

args:
	  LPAREN opt_explist RPAREN
	| tableconstructor
	| STRING
	;

functiondef:
	  FUNCTION funcbody
	;

funcbody:
	  LPAREN opt_parlist RPAREN block END
	;

opt_parlist:
	  /* empty */
	| parlist
	;

parlist:
	  namelist opt_comma_varargparam
	| varargparam
	;

opt_comma_varargparam:
	  /* empty */
	| COMMA varargparam
	;

varargparam:
	  ELLIPSIS
	| ELLIPSIS NAME
	;

tableconstructor:
	  LBRACE opt_fieldlist RBRACE
	;

opt_fieldlist:
	  /* empty */
	| fieldlist
	;

fieldlist:
	  field fieldsep_field_list opt_fieldsep
	;

fieldsep_field_list:
	  /* empty */
	| fieldsep_field_list fieldsep field
	;

opt_fieldsep:
	  /* empty */
	| fieldsep
	;

field:
	  LBRACK exp RBRACK ASSIGN exp
	| NAME ASSIGN exp
	| exp
	;

fieldsep:
	  COMMA
	| SEMI
	;

%%