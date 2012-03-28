tree grammar BlaiseCheck;

options {
  language = Java;
  output = AST;
  tokenVocab = Blaise;
  ASTLabelType = CommonTree;
}

@header {
  package me.thomasgrainger.compilers.blaise2j;
  import java.util.HashMap;
}

@members {
  public HashMap SymbolTable = new HashMap<String,String>();
  @Override
  public void reportError(RecognitionException e) {
    throw new IllegalArgumentException(e.toString());
  }
}


program returns [String jc]
  : {String declarations ="" ; String statements ="";}
  ^(PROGRAM id=IDENT endid=IDENT (declarationList{declarations=$declarationList.jc;})?
                                 (statement_block{statements=$statement_block.jc;})?)
  
  { if (!$id.text.equals($endid.text))
    {
      throw new ContextualRestraintException("Start id not equal to end id at lines" + $id.getLine() + " and " + $endid.getLine());
    }
  }
  {
    $jc="public class " + $id.text + " {\n" +
             declarations  +
        "    public void _blaiseEntry(){\n" +
                    statements +
        "    }\n" +
        "    public static void main(String[] _args) {\n" + 
        "        new " + $id.text + "()._blaiseEntry();\n" + 
        "    }\n"+
        "}";
  }
  ;

declarationList returns [String jc]
  : {$jc="";} ^(DECLARATIONS (declaration {$jc+=$declaration.jc+"\n";})+)
  ;

declaration returns [String jc]
  : constant {$jc = $constant.jc;}
  | variable {$jc = $variable.jc;}
  | procedure {$jc = $procedure.jc;}
  | function {$jc = $function.jc;}
  ;
  
constant returns [String jc]
  : ^(CONST_DECLARATION id=IDENT type expression)
  {$jc = "final " + $type.jc + " " + $id.text + " = " + $expression.jc + ";" ;}
  ;
  
variable returns [String jc]
  :
    ^(VAR_DECLARATION id=IDENT type)
    {$jc = "" + $type.jc + " " + $id.text + ";" ;}
  ;

function returns [String jc]
  : {String params = "";
    String declarations = "";
    String statements = "";
    }
    ^(FUNCDEF id=IDENT endid=IDENT (parameterList{params+=$parameterList.jc;})?
                                    (declarationList{declarations+=$declarationList.jc;})?
                                     (statement_block{statements+=$statement_block.jc;})? type)
    { if (!$id.text.equals($endid.text))
      {
        throw new ContextualRestraintException("Start id not equal to end id at lines" + $id.getLine() + " and " + $endid.getLine());
      }
    }
    {$jc = "public " + $type.jc + " " + $id.text + "(" + params + "){\n" +
        declarations +
        $type.jc + " " + $id.text +";\n" +
        statements +
        "return " + $id.text + ";\n" + 
    "};";}
  ;
  
procedure returns [String jc]
  : {String params = "";
    String declarations = "";
    String statements = "";
    }
    ^(PROCDEF id=IDENT endid=IDENT (parameterList{params+=$parameterList.jc;})?
                                   (declarationList{declarations+=$declarationList.jc;})?
                                    (statement_block{statements+=$statement_block.jc;})?)
    { if (!$id.text.equals($endid.text))
      {
        throw new ContextualRestraintException("Start id not equal to end id at lines" + $id.getLine() + " and " + $endid.getLine());
      }
    }
    {$jc = "public void " + $id.text + "(" + params + "){\n" +
        declarations +
        statements +
    "};";}
  ;
  
parameterList returns [String jc]
  : ^(ARGS (first=formalParameter{$jc=$first.jc;})(trailing=formalParameter{$jc+=","+$trailing.jc;})*)
  ;
  
formalParameter returns [String jc]
  : ^(ARG id=IDENT type)
    {$jc="" + $type.jc +" " +$id.text;}
  ; 

type returns [String jc]
  : 'INTEGER' {$jc = "int";}
  | 'FLOAT' {$jc = "double";}
  | 'BOOLEAN' {$jc = "boolean";}
  ;
  
expression returns [String jc]
  : ^(NEGATION op1=expression {$jc="(!" + $op1.jc+")";})
  | ^('**' op1=expression op2=expression {$jc="(" + "Math.pow(" + $op1.jc + "," + $op2.jc + ")";})
  | ^('/' op1=expression op2=expression {$jc="(" + $op1.jc + "/" + $op2.jc + ")";})
  | ^('*' op1=expression op2=expression {$jc="(" + $op1.jc + "*" + $op2.jc + ")";})
  | ^('+' op1=expression op2=expression {$jc="(" + $op1.jc + "+" + $op2.jc + ")";})
  | ^('-' op1=expression op2=expression {$jc="(" + $op1.jc + "-" + $op2.jc + ")";})
  | ^('=' op1=expression op2=expression {$jc="(" + $op1.jc + "==" + $op2.jc +")";})
  | ^('~' op1=expression op2=expression {$jc="(" + $op1.jc + "!=" + $op2.jc +")";})
  | ^('<' op1=expression op2=expression {$jc="(" + $op1.jc + "<" + $op2.jc +")";})
  | ^('<=' op1=expression op2=expression {$jc="(" + $op1.jc + "<=" + $op2.jc +")";})
  | ^('>=' op1=expression op2=expression {$jc="(" + $op1.jc + ">=" + $op2.jc +")";})
  | ^('>' op1=expression op2=expression {$jc="(" + $op1.jc + ">" + $op2.jc +")";})
  | ^(AND op1=expression op2=expression {$jc="(" + $op1.jc + "&&" + $op2.jc +")";})
  | ^(OR op1=expression op2=expression {$jc="(" + $op1.jc + "||" + $op2.jc +")";})
  | (myint=INTEGER {$jc="(" + $myint.text + ")";})
  | (myfloat=FLOAT {$jc="(" + $myfloat.text + ")";})
  | (myident=IDENT {$jc="(" + $myident.text + ")";})
  | (procedureCallStatement {$jc = $procedureCallStatement.jc;}) 
  ;  
  
statement_block returns [String jc]
  : {$jc="";}^(STATEMENT_BLOCK (statementList{$jc = $statementList.jc+"\n";})?)
  ;

/*
varDeclarationList returns [String jc]
  :{$jc="";} ^(DECLARATIONS (variable {$jc+=$variable.jc+"\n";})+)
  ;
*/
statementList returns [String jc]
  : {$jc="";}^(STATEMENTS (statement {$jc+=$statement.jc+"\n";})+)
  ;
  
statement returns [String jc]
  :  assignmentStatement {$jc = $assignmentStatement.jc;}
  |  doStatement {$jc = $doStatement.jc;}
  |  whileStatement {$jc = $whileStatement.jc;}
  |  ifStatement {$jc = $ifStatement.jc;}
  |  procedureCallStatement {$jc = $procedureCallStatement.jc;}
  |  statement_block {$jc = $statement_block.jc;}
  ;
  
procedureCallStatement returns [String jc]
  : { String parms = "" ;}
    ^(CALL id=IDENT (actualParameters {parms = $actualParameters.jc;})?)
    {$jc ="" + $id.text + "(" + parms + ");";}
  ;
  

actualParameters returns [String jc]
  //^(ARGS (first=formalParameter{$jc=$first.jc;})(trailing=formalParameter{$jc+=","+$trailing.jc;})*)
  : ^(ELIST (first=expression {$jc=$first.jc;}) (trailing=expression {$jc+=","+$trailing.jc;})*)
  ;
  
ifStatement returns [String jc]
  : {String elseClause="";}^(IF_STATEMENT expression stmt=statement (^(ELSE elsestatement=statement{elseClause="else{\n" + $elsestatement.jc + "}";}))?)
  
   { $jc = "if (" + $expression.jc + "){\n" +
                $stmt.jc
                + "}" + elseClause;
   }
  ;

doStatement returns [String jc]
  : ^(DO_STATEMENT statement expression)
  
   {
    $jc="do {\n" +
        $statement.jc +
      "} while (" + $expression.jc + ");";
  }
  ;

whileStatement returns [String jc]
  : ^(WHILE_STATEMENT statement expression)
  {
    $jc="while (" + $expression.jc + "){\n" +
      $statement.jc +
      "}";
  }
  ;
  
assignmentStatement returns [String jc]
  : ^(ASSIGNMENT_STATEMENT id=IDENT expression)
  {$jc=""+$id.text+" = "+$expression.jc + ";"; }
  ;
   
