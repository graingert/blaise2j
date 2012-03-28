grammar Blaise;

options {
	language = Java;
	output = AST;
	ASTLabelType = CommonTree;
}

tokens {
  PROGRAM;
  DECLARATIONS;
  STATEMENT_BLOCK;
  IF_STATEMENT;
  DO_STATEMENT;
  WHILE_STATEMENT;
  ASSIGNMENT_STATEMENT;
  FUNCDEF;
  PROCDEF;
  CALL;
  ELSE;
  ELIST;
  ARG;
  ARGS;
  CONST_DECLARATION;
  VAR_DECLARATION;
  STATEMENTS;
  NEGATION;
}

@header {
	package me.thomasgrainger.compilers.blaise2j;
}

@lexer::header {
	package me.thomasgrainger.compilers.blaise2j;
}

@lexer::members {
  @Override
  public void reportError(RecognitionException e) {
    throw new IllegalArgumentException(e.toString());
  }
}

@members {
  @Override
  public void reportError(RecognitionException e) {
    throw new IllegalArgumentException(e.toString());
  }
}

program
	:	'PROGRAM' id=IDENT ':='
		declarationList?
		statement_block endid=IDENT '.' EOF -> ^(PROGRAM $id $endid declarationList? statement_block?)
	;
	
declarationList
  : (declaration  (';' declaration)*) -> ^(DECLARATIONS declaration+)
  ;
  
declaration
  : (constant | variable | procedure | function) 
  ;
  
constant
	:	'CONST' id=IDENT ':' type ':=' expression -> ^(CONST_DECLARATION $id type expression)
	;
	
variable
	:
		'VAR' id=IDENT ':' type -> ^(VAR_DECLARATION $id type)
	;

type
	:	'INTEGER'
	|	'FLOAT'
	|	'BOOLEAN'
	;
	
statement_block
	:	'BEGIN'
		(statementList)?
		'END' -> ^(STATEMENT_BLOCK statementList?)
	;
	
statementList
  : statement  (';' statement)* -> ^(STATEMENTS statement+)
  ;

statement
	:  assignmentStatement
	|  doStatement
	|  whileStatement
	|  ifStatement
	|  procedureCallStatement
	|  statement_block
	;
	
procedureCallStatement
  :
    id=IDENT '(' actualParameters? ')' -> ^(CALL $id actualParameters?)
  ;
  
actualParameters
  : expression  (',' expression)* -> ^(ELIST expression+)
  ;
  
ifStatement
	:	'IF' expression	'THEN' stmnt = statement
		( ('ELSE')=> 'ELSE' elsestatement=statement)? -> ^(IF_STATEMENT expression $stmnt ^(ELSE $elsestatement)?)
	;

doStatement
  : 'DO' stmt=statement 'WHILE' condition=expression -> ^(DO_STATEMENT statement expression)
  ;

whileStatement
  : 'WHILE' condition=expression  'DO'  stmt=statement -> ^(WHILE_STATEMENT statement expression)
  ;
  
assignmentStatement
	:	id=IDENT ':=' expression -> ^(ASSIGNMENT_STATEMENT $id expression)
	;
	
varDeclarationList
  : (variable  (';' variable)*) -> ^(DECLARATIONS variable+)
  ;
	
	
function
  : 'FUNCTION' id=IDENT '(' parameterList? ')' ':' type ':='
    varDeclarationList?
    statement_block
    endid=IDENT -> ^(FUNCDEF $id $endid parameterList? varDeclarationList? statement_block? type)
  ;
  
procedure
  : 'PROCEDURE' id=IDENT '(' parameterList? ')' ':='
    varDeclarationList?
    statement_block
    endid = IDENT -> ^(PROCDEF $id $endid parameterList? varDeclarationList? statement_block?)
  ;
  
parameterList
  : formalParameter (',' formalParameter)* -> ^(ARGS formalParameter+)
  ;
  
formalParameter
  : id=IDENT ':' type -> ^(ARG $id type)
  ; 

term
	:	IDENT
	|	'('! expression ')'!
	|	INTEGER
	| FLOAT
	| procedureCallStatement
	;
  
unary
	:	(negation^)* term
	;

negation
  : '-' -> NEGATION
  ; 

exp
  : unary ('**'^ unary)*
  ;

divide
  : exp ('/'^ exp)?
  ;

mult
	:	divide ('*'^ divide)*
	;
	
add
	:	mult (('+'^ | '-'^) mult)*
	;
	
relation
	:	add (('='^ | '~'^ | '<'^ | '<='^ | '>='^ | '>'^) add)?
	;
	
and
  : relation (AND^ relation )?
  ;

or
  : and (OR^ and )?
  ;
  
expression
  : or
  ;


fragment LETTER : ('a'..'z' | 'A'..'Z') ;
fragment DIGIT : ('0'..'9');
fragment EXPONENT : ('E' | 'e')('+'|'-')?(DIGIT)*;
INTEGER : ('+'|'-')?(DIGIT)+ ;
FLOAT : ('+'|'-')?(DIGIT)*'.'(DIGIT)*EXPONENT?;


IDENT : LETTER (LETTER | DIGIT | '_')*;
AND:'/\\';
OR:'\\/';


WS : (' ' | '\t' | '\n' | '\r' | '\f')+ {$channel = HIDDEN;};
COMMENT : '/*' .* '*/' {$channel = HIDDEN;};
