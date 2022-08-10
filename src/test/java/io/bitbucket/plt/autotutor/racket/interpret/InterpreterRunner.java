package io.bitbucket.plt.autotutor.racket.interpret;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.junit.platform.commons.util.StringUtils;
import org.stringtemplate.v4.ST;

class InterpreterRunner {



	public static void main(String[] args) throws Exception {
		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("nestedDefineStructFalse1.rkt"), Charset.defaultCharset());
//		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Assignment03a.rkt"), Charset.defaultCharset());


		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);

		interpreter.toXMLFile("nestedDefineStructFalse1.xml");
/*
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

 */

		System.out.println("INTERPRETATION RESULT");
		System.out.println("=====================");
		System.out.println(interpreter.interpretWithXQuery());


	}



}
