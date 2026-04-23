%{
#include "parser.h"

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

and     	{ puts("AND");      return AND;      }
break   	{ puts("BREAK");    return BREAK;    }
do      	{ puts("DO");       return DO;       }
else    	{ puts("ELSE");     return ELSE;     }
elseif  	{ puts("ELSEIF");   return ELSEIF;   }
end     	{ puts("END");      return END;      }
false   	{ puts("FALSE");    return FALSE;    }
for     	{ puts("FOR");      return FOR;      }
function	{ puts("FUNCTION"); return FUNCTION; }
global  	{ puts("GLOBAL");   return GLOBAL;   }
goto    	{ puts("GOTO");     return GOTO;     }
if      	{ puts("IF");       return IF;       }
in      	{ puts("IN");       return IN;       }
local   	{ puts("LOCAL");    return LOCAL;    }
nil     	{ puts("NIL");      return NIL;      }
not     	{ puts("NOT");      return NOT;      }
or      	{ puts("OR");       return OR;       }
repeat  	{ puts("REPEAT");   return REPEAT;   }
return  	{ puts("RETURN");   return RETURN;   }
then    	{ puts("THEN");     return THEN;     }
true    	{ puts("TRUE");     return TRUE;     }
until   	{ puts("UNTIL");    return UNTIL;    }
while   	{ puts("WHILE");    return WHILE;    }

[_[:alpha:]][_[:alnum:]]*	{
                       			printf("NAME(%s)\n", yytext);
                       			return NAME;
                       		}

{HEXIMAL}	|
{DECIMAL}	{
         		printf("NUMBER(%s)\n", yytext);
         		return NUMBER;
         	}

--\[=*\[	{
        		/* beginning of a long comment */
        		long_level = yyleng - 4;  /* number of '=' */
        		long_is_string = 0;
        		printf("LONG COMMENT BEGIN(%s), %d\n", yytext, long_level);
        		BEGIN(long_literal);
        	}

\[=*\[	{
      		/* beginning of a long literal string */
      		long_level = yyleng - 2;  /* number of '=' */
      		long_is_string = 1;
      		printf("LONG STRING BEGIN(%s), %d\n", yytext, long_level);
      		BEGIN(long_literal);
      	}

["']	{
    		/* beginning of a literal string */
    		string_delim = yytext[0];
    		printf("STRING BEGIN(%c)\n", string_delim);
    		BEGIN(string);
    	}

--  	BEGIN(comment);

"..."	{ puts("ELLIPSIS"); return ELLIPSIS; }
".." 	{ puts("CONCAT");   return CONCAT;   }
"::" 	{ puts("LABEL");    return LABEL;    }
"<<" 	{ puts("SHL");      return SHL;      }
">>" 	{ puts("SHR");      return SHR;      }
"//" 	{ puts("IDIV");     return IDIV;     }
"=="	{ puts("EQ");       return EQ;       }
"~="	{ puts("NE");       return NE;       }
"<="	{ puts("LE");       return LE;       }
">="	{ puts("GE");       return GE;       }
"+" 	{ puts("ADD");  return ADD;  }
"-" 	{ puts("SUB");  return SUB;  }
"*" 	{ puts("MUL");  return MUL;  }
"/" 	{ puts("DIV");  return DIV;  }
"%" 	{ puts("MOD");  return MOD;  }
"^" 	{ puts("POW");  return POW;  }
"#" 	{ puts("LEN");  return LEN;  }
"&" 	{ puts("BAND"); return BAND; }
"|" 	{ puts("BOR");  return BOR;  }
"~" 	{ puts("BXOR"); return BXOR; }
"<" 	{ puts("LT");   return LT;   }
">" 	{ puts("GT");   return GT;   }
"=" 	{ puts("ASSIGN"); return ASSIGN; }
";"  	{ puts("SEMI");   return SEMI;   }
":"  	{ puts("COLON");  return COLON;  }
","  	{ puts("COMMA");  return COMMA;  }
"."  	{ puts("DOT");    return DOT;    }
"("		{ puts("LPAREN"); return LPAREN; }
")"		{ puts("RPAREN"); return RPAREN; }
"[" 	{ puts("LBRACK"); return LBRACK; }
"]" 	{ puts("RBRACK"); return RBRACK; }
"{" 	{ puts("LBRACE"); return LBRACE; }
"}" 	{ puts("RBRACE"); return RBRACE; }

[[:space:]]+	/* eat up space symbols  */

.	{
 		fprintf(stderr,
 		        "lexiacal error at line %d: illegal character '%c' (%d)\n",
 		        yylineno, yytext[0], (unsigned char)yytext[0]);
 		/* continue */
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
	       			printf("LONG LITERAL END(%s), %d\n", yytext, yyleng - 2);
	       			BEGIN(INITIAL);
	       			if (long_is_string)
	       				return STRING;
	       		}
	       		/* otherwise it's just text inside a comment */
	       	}

	<<EOF>>	{
	       		fprintf(stderr,
	       		        "lexical error at line %d: unfinished long %s\n",
	       		        yylineno,
	       		        long_is_string ? "string" : "comment");
	       		yyterminate();
	       	}

	.|\n   	/* eat up text inside long comment */
}

<string>{
	["']   	{
	       		/* maybe it's the ending of a string */
	       		if (yytext[0] == string_delim) {
	       			/* if quote symbols match, then string is over */
	       			BEGIN(INITIAL);
	       			printf("STRING END(%c)\n", string_delim);
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
	   		fprintf(stderr,
	   		        "lexical error at line %d: unknown escape character %s\n",
	   		        yylineno, yytext);
	   	}

	\n 	{
	   		fprintf(stderr,
	   		        "lexical error at line %d: unfinished string\n",
	   		        yylineno - 1);
	   		BEGIN(INITIAL);
	   	}

	<<EOF>>	{
	       		fprintf(stderr,
	       		        "lexical error at line %d: unfinished string\n",
	       		        yylineno);
	       		yyterminate();
	       	}

	.   	/* eat up string content */
}

%%
