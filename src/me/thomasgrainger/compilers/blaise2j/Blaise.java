package me.thomasgrainger.compilers.blaise2j;

import java.io.IOException;
import org.antlr.runtime.ANTLRInputStream;
import org.antlr.runtime.CharStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.CommonTreeNodeStream;
import org.antlr.runtime.tree.Tree;

public class Blaise {
	
	
	public static void main(String[] args) {
		try {
			parse(new ANTLRInputStream(System.in));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	
	public static void parse(CharStream input){
		BlaiseParser.program_return parsedProgram = null;
		BlaiseCheck checker;
		
		BlaiseLexer lex = new BlaiseLexer(input);
		CommonTokenStream tokens = new CommonTokenStream(lex);
		BlaiseParser parser = new BlaiseParser(tokens);
		try {
			parsedProgram = parser.program();
		} catch (IllegalArgumentException e) {
			System.err.println("Failed Syntax checks");
			System.err.println(e.getMessage());
			System.exit(1);
		} catch (RecognitionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		checker = new BlaiseCheck((new CommonTreeNodeStream((Tree)parsedProgram.tree)));
		BlaiseCheck.program_return r2 = null;
		try {
			r2 = checker.program();
		} catch (IllegalArgumentException e) {
			System.err.println("Failed Context checks");
			System.err.println(e.getMessage());
			System.exit(1);
		} catch (RecognitionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(r2.jc);
		System.exit(0);

	}

}


