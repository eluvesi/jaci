%{
#include "parser.h"

extern int errcount;

char string_delim;
int long_level;
int long_is_string;
%}

%option yylineno noyywrap noinput nounput

INT      	[[:digit:]]+
HEX_INT  	[[:xdigit:]]+
EXP      	[eE][+-]?[[:digit:]]+
HEX_EXP  	[pP][+-]?[[:digit:]]+
FLOAT    	[[:digit:]]*"."[[:digit:]]+|[[:digit:]]+"."[[:digit:]]*
HEX_FLOAT	[[:xdigit:]]*"."[[:xdigit:]]+|[[:xdigit:]]+"."[[:xdigit:]]*

DECIMAL  	({INT}|{FLOAT})({EXP})?
HEXIMAL  	0[xX]({HEX_INT}|{HEX_FLOAT})({HEX_EXP})?

%x comment long_literal string

%%

and     	return AND;
break   	return BREAK;
do      	return DO;
else    	return ELSE;
elseif  	return ELSEIF;
end     	return END;
false   	return FALSE;
for     	return FOR;
function	return FUNCTION;
global  	return GLOBAL;
goto    	return GOTO;
if      	return IF;
in      	return IN;
local   	return LOCAL;
nil     	return NIL;
not     	return NOT;
or      	return OR;
repeat  	return REPEAT;
return  	return RETURN;
then    	return THEN;
true    	return TRUE;
until   	return UNTIL;
while   	return WHILE;

[_[:alpha:]][_[:alnum:]]*	return NAME;
{HEXIMAL}|{DECIMAL}      	return NUMBER;

--\[=*\[	{
        		/* beginning of a long comment */
        		long_level = yyleng - 4;  /* number of '=' */
        		long_is_string = 0;
        		BEGIN(long_literal);
        	}

\[=*\[	{
      		/* beginning of a long string */
      		long_level = yyleng - 2;  /* number of '=' */
      		long_is_string = 1;
      		BEGIN(long_literal);
      	}

["']	{
    		/* beginning of a string */
    		string_delim = yytext[0];
    		BEGIN(string);
    	}

--  	BEGIN(comment);

"..."	return ELLIPSIS;
".." 	return CONCAT;
"::" 	return LABEL;
"<<" 	return SHL;
">>" 	return SHR;
"//" 	return IDIV;
"==" 	return EQ;
"~=" 	return NE;
"<=" 	return LE;
">=" 	return GE;
"+"  	return ADD;
"-"  	return SUB;
"*"  	return MUL;
"/"  	return DIV;
"%"  	return MOD;
"^"  	return POW;
"#"  	return LEN;
"&"  	return BAND;
"|"  	return BOR;
"~"  	return BXOR;
"<"  	return LT;
">"  	return GT;
"="  	return ASSIGN;
";"  	return SEMI;
":"  	return COLON;
","  	return COMMA;
"."  	return DOT;
"("  	return LPAREN;
")"  	return RPAREN;
"["  	return LBRACK;
"]"  	return RBRACK;
"{"  	return LBRACE;
"}"  	return RBRACE;

[[:space:]]+	/* eat up space symbols  */

.	{
 		errcount++;
 		fprintf(stderr,
 		        "lexiacal error at line %d: illegal character '%c' (%d)\n",
 		        yylineno, yytext[0], (unsigned char)yytext[0]);
 	}

<comment>{
	\n  	BEGIN(INITIAL);

	.   	/* eat up text inside comment */
}

<long_literal>{
	\]=*\]	{
	       		/* maybe it's the ending of a long literal (string/comment) */
	       		if (yyleng - 2 == long_level) {
	       			/* if levels match, then long literal is over */
	       			BEGIN(INITIAL);
	       			if (long_is_string)
	       				return STRING;
	       		}
	       		/* otherwise it's just text inside long literal */
	       	}

	<<EOF>>	{
	       		errcount++;
	       		fprintf(stderr,
	       		        "lexical error at line %d: unfinished long %s\n",
	       		        yylineno, long_is_string ? "string" : "comment");
	       		yyterminate();
	       	}

	.|\n   	/* eat up text inside long literal */
}

<string>{
	["']   	{
	       		/* maybe it's the ending of a string */
	       		if (yytext[0] == string_delim) {
	       			/* if quote symbols match, then string is over */
	       			BEGIN(INITIAL);
	       			return STRING;
	       		}
	       		/* otherwise it's just quote symbol inside a string */
	       	}

	\\[abfnrtv]         	/* valid escape sequences: \a, \b, \f, \n, ... */
	\\[\"\'\n\\]        	/* ", ', \n and \ characters escaping */
	\\z[[:space:]]*     	/* \z (skip spaces) */
	\\[[:digit:]]{1,3}  	/* \ddd (decimal byte value) */
	\\x[[:xdigit:]]{2}  	/* \xXX (heximal byte value) */
	\\u\{[[:xdigit:]]+\}	/* \u{XXX} (unicode character) */

	\\.	{
	   		errcount++;
	   		fprintf(stderr,
	   		        "lexical error at line %d: unknown escape character %s\n",
	   		        yylineno, yytext);
	   	}

	\n 	{
	   		errcount++;
	   		fprintf(stderr,
	   		        "lexical error at line %d: unfinished string\n",
	   		        yylineno - 1);
	   		BEGIN(INITIAL);
	   		return STRING;
	   	}

	<<EOF>>	{
	       		errcount++;
	       		fprintf(stderr,
	       		        "lexical error at line %d: unfinished string\n",
	       		        yylineno);
	       		yyterminate();
	       	}

	.   	/* eat up text inside string */
}

%%
