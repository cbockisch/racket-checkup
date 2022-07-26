package io.bitbucket.plt.autotutor.racket.interpret;

import java.nio.charset.Charset;

import org.apache.commons.io.IOUtils;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class InterpreterTest {

	@Test
	void testCustomQuery() throws Exception {
		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Demo.rkt"), Charset.defaultCharset());
		
		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);
		
		assertEquals("value=\"0\"", interpreter.interpretWithXQuery("(//paren/terminal)[last()]/attribute::value"));
	}


	@Test
	void testReduceXMLtoValue() throws Exception{
		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("DemoResult.rkt"), Charset.defaultCharset());

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);

		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"0\"/></drracket>", interpreter.interpretWithXQuery());

	}

	@Test
	void testReduceBasicOperations() throws Exception{
		String rktFileDiv = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDivision.rkt"), Charset.defaultCharset());
		String rktFilePlus = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleAddition.rkt"), Charset.defaultCharset());
		String rktFileSub = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleSubtraktion.rkt"), Charset.defaultCharset());
		String rktFileMult = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleMultiplikation.rkt"), Charset.defaultCharset());

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFilePlus);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"42\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktFileSub);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"67\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktFileMult);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"16\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktFileDiv);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"4\"/></drracket>", interpreter.interpretWithXQuery());
	}


	@Test
	void testNestedFunctions() throws Exception{
		String rktFileSimpleNested = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleNestedCalc.rkt"), Charset.defaultCharset());
		String rktFileNested = IOUtils.toString(ClassLoader.getSystemResourceAsStream("nestedCalc.rkt"), Charset.defaultCharset());
		String rktFileBigNested = IOUtils.toString(ClassLoader.getSystemResourceAsStream("bigNestedCalc.rkt"), Charset.defaultCharset());
		String rktFileBigNested1 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("nestedCalc1.rkt"), Charset.defaultCharset());


		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFileSimpleNested);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"17\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktFileNested);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"8\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktFileBigNested1);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"1221\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktFileBigNested);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"249\"/></drracket>", interpreter.interpretWithXQuery());

	}

	@Test
	void ifTest() throws Exception{
		String rktSimpleIf = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleIf.rkt"), Charset.defaultCharset());

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktSimpleIf);

		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"9\"/></drracket>", interpreter.interpretWithXQuery());

	}


	@Test
	void defineTest() throws Exception{
		String rktSimpleDefine = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunction.rkt"), Charset.defaultCharset());
		String rktComplexDefine = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunctionKomplex.rkt"), Charset.defaultCharset());
		String rktRekDefine = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunctionRek.rkt"), Charset.defaultCharset());


		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktSimpleDefine);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"20\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktComplexDefine);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"36\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktRekDefine);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"10\"/></drracket>", interpreter.interpretWithXQuery());
	}


	@Test
	void nameDoubleTest() throws Exception{

		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunctionDoubleNames.rkt"), Charset.defaultCharset());

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);
		assertEquals("\"sry leider doppelt benannte Funktionen/Konstanten\"", interpreter.interpretWithXQuery());
	}


	@Test
	void usedBeforeDefineTest() throws Exception{

		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunctionUsedBeforeDefine.rkt"));

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);
		assertEquals("\"sry leider wurden irgendwo Funktionen benutzt bevor sie definiert wurden\"", interpreter.interpretWithXQuery());

	}







}
