#include <stdio.h>


extern FILE *yyin;
extern int yyparse(void);

int errcount = 0;  /* counter for lexical and syntax errors */


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
	yyparse();
	if (errcount == 0)
		printf("OK: program is correct\n");
	else
		printf("FAIL: %d error(s) found\n", errcount);
	
	/* close input file */
	fclose(yyin);
	
	return 0;
}
