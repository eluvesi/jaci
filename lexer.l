%{
enum token
{
	/* keywords */
	AND, BREAK, DO, ELSE, ELSEIF, END,
	FALSE, FOR, FUNCTION, GLOBAL, GOTO, IF,
	IN, LOCAL, NIL, NOT, OR, REPEAT,
	RETURN, THEN, TRUE, UNTIL, WHILE,
	
	/* operations */
	ADD,     /* +  */
	SUB,     /* -  */
	MUL,     /* *  */
	DIV,     /* /  */
	MOD,     /* %  */
	POW,     /* ^  */
	LEN,     /* #  */
	BAND,    /* &  */
	BNOT,    /* ~  */
	BOR,     /* |  */
	SHL,     /* << */
	SHR,     /* >> */
	IDIV,    /* // */
	EQ,      /* == */
	NE,      /* ~= */
	LE,      /* <= */
	GE,      /* >= */
	LT,      /* <  */
	GT,      /* >  */
	ASSIGN,  /* =  */
	
	/* symbols */
	LPAREN,    /* (   */
	RPAREN,    /* )   */
	LBRACE,    /* {   */
	RBRACE,    /* }   */
	LBRACK,    /* [   */
	RBRACK,    /* ]   */
	LABEL,     /* :: */
	SEMI,      /* ;   */
	COLON,     /* :   */
	COMMA,     /* ,   */
	DOT,       /* .   */
	CONCAT,    /* ..  */
	ELLIPSIS,  /* ... */

	
	/* other */
	NAME,
	NUMBER,
	STRING
};

char string_delim;
int string_level;
int comment_level;
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

%x long_comment long_string comment string escape

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
        		comment_level = yyleng - 4;  /* number of '=' */
        		printf("LONG COMMENT BEGIN(%s), %d\n", yytext, comment_level);
        		BEGIN(long_comment);
        	}

--  	BEGIN(comment);

\[=*\[	{
      		/* beginning of a long literal string */
      		string_level = yyleng - 2;  /* number of '=' */
      		printf("LONG STRING BEGIN(%s), %d\n", yytext, string_level);
      		BEGIN(long_string);
      	}

["']	{
    		/* beginning of a literal string */
    		string_delim = yytext[0];
    		printf("STRING BEGIN(%c)\n", string_delim);
    		BEGIN(string);
    	}

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
"~" 	{ puts("BNOT"); return BNOT; }
"|" 	{ puts("BOR");  return BOR;  }
"<" 	{ puts("LT");   return LT;   }
">" 	{ puts("GT");   return GT;   }
"=" 	{ puts("ASSIGN"); return ASSIGN; }
":"  	{ puts("COLON");  return COLON;  }
";"  	{ puts("SEMI");   return SEMI;   }
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

<long_comment>{
	\]=*\]	{
	       		/* maybe it's the ending of a long comment */
	       		if (yyleng - 2 == comment_level) {
	       			/* if levels match, then comment is over */
	       			printf("LONG COMMENT END(%s), %d\n", yytext, yyleng - 2);
	       			BEGIN(INITIAL);
	       		}
	       		/* otherwise it's just text inside a comment */
	       	}

	<<EOF>>	{
	       		fprintf(stderr,
	       		        "lexical error at line %d: unfinished long comment\n",
	       		        yylineno);
	       		yyterminate();
	       	}

	.|\n   	/* eat up text inside long comment */
}

<comment>{
	\n  	BEGIN(INITIAL);

	.   	/* eat up text inside comment */
}

<long_string>{
	\]=*\]	{
	       		/* maybe it's the ending of a long literal string */
	       		if (yyleng - 2 == string_level) {
	       			/* if levels match, then string is over */
	       			BEGIN(INITIAL);
	       			printf("LONG STRING END(%s), %d\n", yytext, yyleng - 2);
	       			return STRING;
	       		}
	       		/* otherwise it's just text inside a string */
	       	}

	<<EOF>>	{
	       		fprintf(stderr,
	       		        "lexical error at line %d: unfinished long string\n",
	       		        yylineno);
	       		yyterminate();
	       	}

	.|\n   	/* eat up long string content */
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

	\\     	BEGIN(escape);  /* beginning of escape sequence */

	\n     	{
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

<escape>{
	a                 	|               /* '\a' (bell) */
	b                 	|               /* '\b' (backspace) */
	f                 	|               /* '\f' (form feed) */
	n                 	|               /* '\n' (newline) */
	r                 	|               /* '\r' (carriage return) */
	t                 	|               /* '\t' (horizontal tab) */
	v                 	|               /* '\v' (vertical tab) */
	\\                	|               /* '\\' (backslash) */
	\"                	|               /* '\"' (quotation mark) */
	\'                	|               /* '\'' (apostrophe) */
	\n                	|               /* '\\n' (string continuation) */
	z[[:space:]]*     	|               /* '\z' (skip spaces) */
	[[:digit:]]{1,3}  	|               /* '\ddd' (decimal byte value) */
	x[[:xdigit:]]{2}  	|               /* '\xXX' (heximal byte value) */
	u\{[[:xdigit:]]+\}	BEGIN(string);  /* '\u{XXX}' (Unicode character) */

	.	{
	 		fprintf(stderr,
	 		        "lexical error at line %d: invalid escape sequence \\%c\n",
	 		        yylineno, yytext[0]);
	 		BEGIN(string);
	 	}
}

%%

int main(int argc, char *argv[])
{
	/* setup input */
	if (argc != 2) {
		fprintf(stderr, "Usage: ./jaci [FILE]\n");
		return 1;
	} else {
		yyin = fopen(argv[1], "r");
		if (!yyin) {
			perror(argv[1]);
			return 1;
		}
	}
	
	/* parse input */
	int tok;
	while ((tok = yylex()) != 0) {
		/* lexer-only mode */
	}
	
	/* close input file */
	if (yyin != stdin)
		fclose(yyin);
	
	return 0;
}
