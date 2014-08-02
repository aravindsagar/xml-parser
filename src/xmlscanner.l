/**
* This file contains the code for Lexical Analyzer (Scanner) for XML. The syntax Analysis is done in the file "xmlparser.l".
* This code belongs to:
* 				Aravind Sagar	1100104
* 				V Priyan		1100136
*/
%{
	#include<stdio.h>
	#include "xmlparser.tab.h"
	#include "symbolTable.h"
	int i,lineNo=1,columnNo=0;
	extern int yylval;

%}
%%

['<']['?'][' ']*"xml version"[' ']*['=']['"'][0-9]+['.'][0-9]+['"'][^'<''>''&''/']*['?']['>']	{return HEADER;}

['\t']*			{}

['\n']			{lineNo++;columnNo=0;}

['<']['!']['\-']['\-'][^'<''>''&''/''\']*['>']	{columnNo+=yyleng;/*Comments*/}

[' ']*[^'<''>''&''/''\''\-''=''"''?'' ']+['=']			{
	columnNo+=yyleng-1;
	unput(yytext[yyleng-1]);
	yylval = addToSymbolTable(yytext,yyleng,ATTRIBUTE);
	return ATTRIBUTE;
}

['='][' ']*['"'][^'<''>''&''/''\''\-''"''?''=']*['"']		{
	columnNo+=yyleng;
	yylval = addToSymbolTable(yytext,yyleng,ATTRIBUTE_VALUE);
	return ATTRIBUTE_VALUE;
}

['<'][^'<''>''&''/''\''\-'' ''?']+[' ']*		{
	columnNo+=yyleng;
	yylval = addToSymbolTable(yytext,yyleng,START_TAG);
	return START_TAG;
}

['<']['/'][^'<''>''&''/''\''?'' ']+[' ']*['>']			{
	columnNo+=yyleng;
	yylval = addToSymbolTable(yytext,yyleng,END_TAG);
	return END_TAG;
}

['&'][a-zA-Z0-9]*[';'] {
	columnNo+=yyleng;
	yylval = addToSymbolTable(yytext,yyleng,ENTITY_REFERENCE);
	return ENTITY_REFERENCE;
}

['>']				{columnNo+=1;return SYMBOL_GREATER_THAN;}

[^'<''>''=''&''/']	{columnNo+=yyleng;
					//printf("Data:%s\n", yytext);
					return DATA;}

.		{}

%%

yywrap(){}

int addToSymbolTable(char *val, int leng , enum yytokentype type){
	/**
	* This function adds the tokens found (or lexemes) to the symbol table.
	* @param *val: Value of the the lexeme.
	* @param leng: Length of the value of the lexeme.
	* @param type: The type of the token found.
	*/

	//Extracting required information.

	char value[50];
	int i;
	for(i=0; i<leng; i++){
		value[i] = val[i];
	}
	value[i] = '\0';
	// printf("Adding %s to ST\n", value);
	struct Symbol *temp = symbolTableHeader, *last = symbolTableHeader;
	while(temp != NULL){
		if(strcmp(temp->value,value)==0 && type == temp->type){
			return temp->index;
		}
		last = temp;
		temp = temp->next;
	}

	//Creating a new node and adding it to the symbol table.

	temp = malloc(sizeof(struct Symbol));
	if(symbolTableHeader == NULL){
		symbolTableHeader = temp;
		temp->index = 0;
	}
	else{
		last->next = temp;
		temp->index = last->index+1;
	}
	strcpy(temp->value, value);
	temp->type = type;
	temp->next = NULL;
	temp->lineNo = lineNo;
	return temp->index;
}