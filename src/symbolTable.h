/**
* This file contains the code for structure for symbol table. The symbol table contains the tokens(lexemes) found by the scanner.
* The symbol table is represented as a linked list
* This code belongs to:
* 				Aravind Sagar	1100104
* 				V Priyan		1100136
*/
struct Symbol{
	char value[100];				//Value of the lexeme.
	enum yytokentype type;		//Type of token.
	int index;					//Index no. of the token. Used to identify the the tokens during parsing.
	struct Symbol *next;		//Pointer to the next element.
	int lineNo;					//The line no. where the token was identified.
}*symbolTableHeader;
