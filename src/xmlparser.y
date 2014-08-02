/**
* This file contains the code for Syntax Analyzer (Parser) for XML. The lexical Analysis is done in the file "xmlscanner.l".
* This code belongs to:
* 				Aravind Sagar	1100104
* 				V Priyan		1100136
*/
%{
#include<stdio.h>
#include<stdlib.h>
#include "xmlparser.tab.h"
#include "symbolTable.h"
extern int lineNo,columnNo;
int errorFlag = 0;
void validateTag(int,int);
%}

%token HEADER
%token START_TAG
%token ATTRIBUTE
%token ATTRIBUTE_VALUE
%token END_TAG
%token DATA
%token SYMBOL_GREATER_THAN
%token ENTITY_REFERENCE
%define parse.error verbose

%%

start:			HEADER root
			|	root						{printf("Warning, XML Header missing. It is always recommended to use XML header.\n\n");			};

root:		starttag exprblck END_TAG		{validateTag($1,$3);								};

exprblck:		exprs
			|	data;

data:			DATA data
			|	ENTITY_REFERENCE data
			|	;

exprs:			root exprs
			|	root;


starttag:		START_TAG attribs;


attribs:		ATTRIBUTE attval attribs
			|	SYMBOL_GREATER_THAN
			|	error SYMBOL_GREATER_THAN;

attval:			ATTRIBUTE_VALUE
			|	error;


%%

int main(){
	/**
	* This is the main funtion for the XML compiler. The compilation starts from here.
	*/

	symbolTableHeader = NULL;				//Header of the symbol table.
	printf("\n");
	yyparse();								//Starts parsing the input.


	if(errorFlag == 0){						//Checking for the validity of the XML.
		printf("Valid XML!\n\n");
	}
	else{
		printf("Invalid XML.\n\n");
	}
	
	return 0;
}

void validateTag(int index1,int index2){
	
	/**
	* This function matches the START_TAG and END_TAG, and checks for the proper nesting of the TAGs.
	* @param index1: Index of the START_TAG.
	* @param index2: Index of the END_TAG.
	*/

	struct Symbol *temp1,*temp2;
	int i,j;
	char value1[100],value2[100];

	//Traversing through the symbol table to find the START_TAG and END_TAG

	temp1 = symbolTableHeader;
	temp2 = symbolTableHeader;

	while(temp1->index != index1){
		temp1 = temp1->next;
	}

	while(temp2->index != index2){
		temp2 = temp2->next;
	}

	//Extracting the value of the START_TAG and END_TAG

	for(i = 0;temp1->value[i+1] != '\0' && temp1->value[i+1] != ' ';i++){
		value1[i] = temp1->value[i+1];
	}
	value1[i]='\0';


	for(i = 1;temp2->value[i+1] != '>' && temp2->value[i+1] != ' ';i++){
		value2[i-1] = temp2->value[i+1];
	}
	value2[i-1]='\0';			//if the end tag detection has problem, change this line to value2[i-2]  and the for loop condition to temp2->value[i+1] != '\0'

	//Comparing the value of the START_TAG and END_TAG

	int strflag = 0;

	for(i=0;value1[i]!='\0' || value2[i]!='\0';i++){
		if(value1[i]!=value2[i]){
			strflag = 1;
			break;
		}
	}

	//Reporting error if START_TAG and END_TAG do not match.

	if(strflag!=0){
		char s[100];
		sprintf(s,"syntax error, unexpected ETAG \"%s\", expecting \"/%s\"",value2,value1 );
		yyerror(s);
	}

}

int yyerror(char* s){
	/**
	* This function reports the error found during parsing and also the type of error and more details about the error.
	* @param s: The error verbose string which is passed by the Bison (3.0 and above only).
	*/
	printf("Error at line: %d.%d: %s\n\n",lineNo,columnNo,s);
	errorFlag = 1;
}
