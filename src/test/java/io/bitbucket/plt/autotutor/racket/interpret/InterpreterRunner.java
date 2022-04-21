package io.bitbucket.plt.autotutor.racket.interpret;

import java.nio.charset.Charset;

import org.apache.commons.io.IOUtils;

class InterpreterRunner {

	public static void main(String[] args) throws Exception {
	String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Demo.rkt"), Charset.defaultCharset());
		
		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);
		
		System.out.println("INPUT FILE");
		System.out.println("==========");
		System.out.println(interpreter.getInput());
		System.out.println();
		
		System.out.println("XML");
		System.out.println("===");
		System.out.println(interpreter.getXml());
		System.out.println();

		System.out.println("PARSE ERRORS");
		System.out.println("============");
		System.out.println(interpreter.getParseErrors());
		System.out.println();

		System.out.println("INTERPRETATION RESULT");
		System.out.println("=====================");
		System.out.println(interpreter.interpretWithXQuery());
	}

}
