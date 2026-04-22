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
%}

%option yylineno noyywrap noinput nounput

DIGIT    	[0-9]
HEX_DIGIT	[0-9a-fA-F]
SIGN     	[+-]

INT      	{DIGIT}+
HEX_INT  	{HEX_DIGIT}+
EXP      	[eE]{SIGN}?{DIGIT}+
HEX_EXP  	[pP]{SIGN}?{DIGIT}+
FLOAT    	{DIGIT}*"."{DIGIT}+|{DIGIT}+"."{DIGIT}*
HEX_FLOAT	{HEX_DIGIT}*"."{HEX_DIGIT}+|{HEX_DIGIT}+"."{HEX_DIGIT}*

DECIMAL  	({INT}|{FLOAT})({EXP})?
HEXIMAL  	0[xX]({HEX_INT}|{HEX_FLOAT})({HEX_EXP})?

%%

"and"     	{ puts("AND");      return AND;      }
"break"   	{ puts("BREAK");    return BREAK;    }
"do"      	{ puts("DO");       return DO;       }
"else"    	{ puts("ELSE");     return ELSE;     }
"elseif"  	{ puts("ELSEIF");   return ELSEIF;   }
"end"     	{ puts("END");      return END;      }
"false"   	{ puts("FALSE");    return FALSE;    }
"for"     	{ puts("FOR");      return FOR;      }
"function"	{ puts("FUNCTION"); return FUNCTION; }
"global"  	{ puts("GLOBAL");   return GLOBAL;   }
"goto"    	{ puts("GOTO");     return GOTO;     }
"if"      	{ puts("IF");       return IF;       }
"in"      	{ puts("IN");       return IN;       }
"local"   	{ puts("LOCAL");    return LOCAL;    }
"nil"     	{ puts("NIL");      return NIL;      }
"not"     	{ puts("NOT");      return NOT;      }
"or"      	{ puts("OR");       return OR;       }
"repeat"  	{ puts("REPEAT");   return REPEAT;   }
"return"  	{ puts("RETURN");   return RETURN;   }
"then"    	{ puts("THEN");     return THEN;     }
"true"    	{ puts("TRUE");     return TRUE;     }
"until"   	{ puts("UNTIL");    return UNTIL;    }
"while"   	{ puts("WHILE");    return WHILE;    }

[_[:alpha:]][_[:alnum:]]*	{
                       			printf("NAME(%s)\n", yytext);
                       			return NAME;
                       		}

\"[^\n"]*\"	{
           		printf("STRING(%s)\n", yytext);
           		return STRING;
           	}

{HEXIMAL}	{
         		printf("NUMBER(%s)\n", yytext);
         		return NUMBER;
         	}

{DECIMAL}	{
         		printf("NUMBER(%s)\n", yytext);
         		return NUMBER;
         	}

"..."	{ puts("ELLIPSIS"); return ELLIPSIS; }
".." 	{ puts("CONCAT");   return CONCAT;   }
"."  	{ puts("DOT");      return DOT;      }
"::" 	{ puts("LABEL");    return LABEL;    }
":"  	{ puts("COLON");    return COLON;    }
";"  	{ puts("SEMI");     return SEMI;     }
","  	{ puts("COMMA");    return COMMA;    }

"<<" 	{ puts("SHL");    return SHL;    }
">>" 	{ puts("SHR");    return SHR;    }
"//" 	{ puts("IDIV");   return IDIV;   }
"=="	{ puts("EQ");     return EQ;     }
"~="	{ puts("NE");     return NE;     }
"<="	{ puts("LE");     return LE;     }
">="	{ puts("GE");     return GE;     }

"+" 	{ puts("ADD");    return ADD;    }
"-" 	{ puts("SUB");    return SUB;    }
"*" 	{ puts("MUL");    return MUL;    }
"/" 	{ puts("DIV");    return DIV;    }
"%" 	{ puts("MOD");    return MOD;    }
"^" 	{ puts("POW");    return POW;    }
"#" 	{ puts("LEN");    return LEN;    }

"&" 	{ puts("BAND");   return BAND;   }
"~" 	{ puts("BNOT");   return BNOT;   }
"|" 	{ puts("BOR");    return BOR;    }

"<" 	{ puts("LT");     return LT;     }
">" 	{ puts("GT");     return GT;     }

"=" 	{ puts("ASSIGN"); return ASSIGN; }
"("		{ puts("LPAREN"); return LPAREN; }
")"		{ puts("RPAREN"); return RPAREN; }
"[" 	{ puts("LBRACK"); return LBRACK; }
"]" 	{ puts("RBRACK"); return RBRACK; }
"{" 	{ puts("LBRACE"); return LBRACE; }
"}" 	{ puts("RBRACE"); return RBRACE; }

"--".*      	/* eat up short comments */
[[:space:]]+	/* eat up space symbols  */

.	{
 		fprintf(stderr,
 		        "lexical error at line %d: illegal character '%c' (%d)\n",
 		        yylineno, yytext[0], (unsigned char)yytext[0]);
 		/* continue */
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
