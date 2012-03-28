package me.thomasgrainger.compilers.blaise2j;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintStream;
import java.util.Collection;
import java.util.Random;

import org.antlr.runtime.ANTLRInputStream;
import org.antlr.runtime.ANTLRReaderStream;
import org.antlr.runtime.ANTLRStringStream;
import org.antlr.runtime.CharStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.TokenStream;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.CommonTreeNodeStream;
import org.antlr.runtime.tree.DOTTreeGenerator;
import org.antlr.runtime.tree.Tree;
import org.antlr.runtime.tree.TreeAdaptor;
import org.antlr.runtime.tree.TreeNodeStream;
import org.antlr.stringtemplate.StringTemplate;

public class Blaise2J {
	private static final boolean DEBUG = true;
	private static final boolean TEST_CASES = false;
	private static final String DEBUG_STR = 
	"PROGRAM math := \n" + 
	"CONST fast: BOOLEAN := 1=1;\n" + 
	"CONST pi: FLOAT := 3.14159265;\n" + 
	"VAR result: FLOAT;\n" + 
	"FUNCTION pow(x: FLOAT, n: INTEGER): FLOAT := \n" + 
	"    VAR acc: FLOAT;\n" + 
	"	VAR count: INTEGER\n" + 
	"    BEGIN\n" + 
	"        acc := result;\n" + 
	"		count := n;\n" + 
	"		WHILE count > 0 DO\n" + 
	"		BEGIN\n" + 
	"		    IF fast /\\ (((count / 2) * 2) = count) THEN\n" + 
	"			BEGIN\n" + 
	"				acc := pow(x, count/2);\n" + 
	"				acc := acc * acc;\n" + 
	"				count := 0\n" + 
	"			END ELSE BEGIN\n" + 
	"				acc := acc * x;\n" + 
	"		        count := count - 1\n" + 
	"			END\n" + 
	"		END;\n" +
	"		DO pow:=acc WHILE 1=1;\n" +		
	"		pow := acc;\n" + 
	"		result := acc\n" + 
	"	END pow;\n" + 
	"PROCEDURE print(x: FLOAT) :=\n" +
	"    BEGIN\n" + 
	"	    IF result = x \n" + 
	"		THEN result := pi\n" + 
	"		ELSE result := 0.0\n" + 
	"	END print\n" + 
	"BEGIN\n" + 
	"  result := pow(pi, 34);\n" + 
	"  print(80001044042362353.788443428093913);\n" + 
	"  print(1**2)"+
	"END math.";
	
	
	public static void main(String[] args) throws RecognitionException,
			FileNotFoundException, IOException {
		if (!TEST_CASES) {
			if (DEBUG) {
				parse(new ANTLRStringStream(DEBUG_STR));
			} else {
				if (args.length > 0) {
					File file = new File(args[0]);
					parse(new ANTLRReaderStream(new FileReader(file)));
				} else {
					parse(new ANTLRInputStream(System.in));
				}
			}
		} else {
			testCases(new File(args[0]));
		}
	}
	
	public static void testCases(File file){
		//for i in `find . - type f`; do java -jar "C:\Users\graingert\blaise2j.jar" $i; done &> ../blaiseOut
		if (file.toString().toUpperCase().contains("FAIL")){
			boolean failed = false;
			try {
				parse(new ANTLRReaderStream(new FileReader(file)));
			} catch (IllegalArgumentException e) {
				//System.out.println("PASS");
				failed = true;
			} catch (ContextualRestraintException e){
				failed = true;
			} catch (FileNotFoundException e) {
			} catch (RecognitionException e) {
			} catch (IOException e) {
			}
			if (failed){
				System.out.println("FILE " + file + " OK");
			} else {
				System.out.println("FILE " + file + " ERROR");
			}
		}
	
		if (file.toString().toUpperCase().contains("PASS")){
			boolean failed = false;
			try {
				parse(new ANTLRReaderStream(new FileReader(file)));
			} catch (Exception e) {
				failed = true;
			}
			if (failed){
				System.out.println("FILE " + file + " ERROR");
			} else {
				System.out.println("FILE " + file + " OK");
			}
		}
	}
	
	public static void parse(CharStream input) throws RecognitionException{
		BlaiseLexer lex = new BlaiseLexer(input);
		CommonTokenStream tokens = new CommonTokenStream(lex);
		BlaiseParser parser = new BlaiseParser(tokens);
		BlaiseParser.program_return r = parser.program();
		Tree t = (Tree)r.tree;
		//System.out.println(t.toStringTree());
		if (!TEST_CASES){
			DOTTreeGenerator gen = new DOTTreeGenerator();
			StringTemplate st = gen.toDOT(t);
			System.out.println(st);
		}
		BlaiseCheck checker = new BlaiseCheck((new CommonTreeNodeStream(t)));
		
		BlaiseCheck.program_return r2 = checker.program();
		Tree t2 = (Tree)r2.tree;
		
		//DOTTreeGenerator gen = new DOTTreeGenerator();
		//StringTemplate st2 = gen.toDOT(t2);
		//System.out.println(st2);
		
		System.out.println(r2.jc);

	}

}


