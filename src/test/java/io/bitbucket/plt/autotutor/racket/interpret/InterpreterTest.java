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
		String rktIfF = IOUtils.toString(ClassLoader.getSystemResourceAsStream("ifWrongArgument.rkt"), Charset.defaultCharset());
		String rktIfF2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("ifWrongArgument2.rkt"), Charset.defaultCharset());


		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktSimpleIf);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"9\"/></drracket>", interpreter.interpretWithXQuery());


		 interpreter = new DrRacketInterpreter(rktIfF);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"falsche Anzahl an Argumenten für If/Cond-Klausel\"/></drracket>", interpreter.interpretWithXQuery());

		 interpreter = new DrRacketInterpreter(rktIfF2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"falsche Anzahl an Argumenten für If/Cond-Klausel\"/></drracket>", interpreter.interpretWithXQuery());
	}


	@Test
	void defineTest() throws Exception{
		String rktSimpleDefine = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunction.rkt"), Charset.defaultCharset());
		String rktIdDefine = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunction2.rkt"), Charset.defaultCharset());
		String rktComplexDefine = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunctionKomplex.rkt"), Charset.defaultCharset());
		String rktRekDefine = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunctionRek.rkt"), Charset.defaultCharset());


		String rktWrongFunc = IOUtils.toString(ClassLoader.getSystemResourceAsStream("wrongFunctionCall.rkt"), Charset.defaultCharset());
		String rktWrongFuncA = IOUtils.toString(ClassLoader.getSystemResourceAsStream("wrongFunctionArgument.rkt"), Charset.defaultCharset());
		String rktWrongFuncA2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("wrongFunctionArgument.rkt"), Charset.defaultCharset());

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktSimpleDefine);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"20\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktComplexDefine);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"36\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktRekDefine);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"10\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktWrongFunc);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"this function is not defined\"/></drracket>" , interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktWrongFuncA);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"this function expects different argument size\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktWrongFuncA2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"this function expects different argument size\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(rktIdDefine);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><terminal value=\"3\"/></drracket>", interpreter.interpretWithXQuery());

	}

	@Test
	void singleConstant() throws Exception{

		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineSingleConstant.rkt"), Charset.defaultCharset());

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"4\"/></drracket>", interpreter.interpretWithXQuery());
	}



	@Test
	void nameDoubleTest() throws Exception{

		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunctionDoubleNames.rkt"), Charset.defaultCharset());

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);
		assertEquals("\"sry leider doppelt benannte Funktionen/Konstanten\"", interpreter.interpretWithXQuery());
	}


	@Test
	void usedBeforeDefineTest() throws Exception{

		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineFunctionUsedBeforeDefine.rkt"), Charset.defaultCharset());

		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);
	//	assertEquals("\"sry leider wurden irgendwo Funktionen benutzt bevor sie definiert wurden\"", interpreter.interpretWithXQuery());

	}



	@Test
	void condTest() throws Exception{

		String simpleCond = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleCond.rkt"), Charset.defaultCharset());
		String simpleCond2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleCond2.rkt"), Charset.defaultCharset());
		String nestedCond = IOUtils.toString(ClassLoader.getSystemResourceAsStream("nestedCond.rkt"), Charset.defaultCharset());
		String nestedCond2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("nestedCond2.rkt"), Charset.defaultCharset());
		String nestedCond3 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("nestedCond3.rkt"), Charset.defaultCharset());

		String condF = IOUtils.toString(ClassLoader.getSystemResourceAsStream("condWrongArgument.rkt"), Charset.defaultCharset());
		String condF2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("condWrongArgument2.rkt"), Charset.defaultCharset());



		DrRacketInterpreter interpreter = new DrRacketInterpreter(simpleCond);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"33\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(simpleCond2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"22\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(nestedCond);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"cond: all question results were false\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(nestedCond2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"22\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(nestedCond3);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"11\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(condF);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"falsche Anzahl an Argumenten für If/Cond-Klausel\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(condF2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"falsche Anzahl an Argumenten für If/Cond-Klausel\"/></drracket>", interpreter.interpretWithXQuery());

	}


	@Test
	void structMakeTest() throws Exception{

		String simpleMake = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStruct.rkt"), Charset.defaultCharset());
		String nestedMake = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleNestedDefineStruct.rkt"),Charset.defaultCharset());

		String falseMake1 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructFalse1.rkt"),Charset.defaultCharset());
		String falseMake2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructFalse2.rkt"),Charset.defaultCharset());
		String falseMake3 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructFalse3.rkt"),Charset.defaultCharset());
		String falseMake4 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructFalse4.rkt"),Charset.defaultCharset());
		String falseMake5 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructFalse5.rkt"),Charset.defaultCharset());
		String falseNested1 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("nestedDefineStructFalse1.rkt"),Charset.defaultCharset());
		String falseNested2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("nestedDefineStructFalse2.rkt"),Charset.defaultCharset());


		DrRacketInterpreter interpreter = new DrRacketInterpreter(simpleMake);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
				"<drracket><paren><terminal line=\"6\" type=\"Name\" value=\"make-fahrrad\"" +
				"/><terminal line=\"6\" type=\"Number\" value=\"10\"/><terminal line=\"6\" " +
				"type=\"Number\" value=\"20\"/></paren></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(nestedMake);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><paren><terminal line=\"6\" type=\"Name\"" +
				" value=\"make-boot\"/><paren line=\"6\" type=\"round\">\n" +
				"         <terminal line=\"6\" type=\"Name\" value=\"make-boot\"/>\n" +
				"         <terminal line=\"6\" type=\"Number\" value=\"3\"/>\n" +
				"         <terminal line=\"6\" type=\"Number\" value=\"4\"/>\n" +
				"      </paren><paren line=\"6\" type=\"round\">\n" +
				"         <terminal line=\"6\" type=\"Name\" value=\"make-boot\"/>\n" +
				"         <terminal line=\"6\" type=\"String\" value=\"&#34;grün&#34;\"/>\n" +
				"         <terminal line=\"6\" type=\"String\" value=\"&#34;blau&#34;\"/>\n" +
				"      </paren></paren></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(falseMake1);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"not the correct struct Struktur\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(falseMake2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"not the correct struct Struktur\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(falseMake3);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"not the correct struct Struktur\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(falseMake4);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"not the correct struct Struktur\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(falseMake5);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"this function is not defined\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(falseNested1);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"not the correct struct Struktur\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(falseNested2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"not the correct struct Struktur\"/></drracket>", interpreter.interpretWithXQuery());

	}


	@Test
	void structPredTest() throws Exception{

		String simplePred = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructPred.rkt"), Charset.defaultCharset());

		String errorPred = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructPredFalse.rkt"), Charset.defaultCharset());
		String errorPred2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructPredFalse2.rkt"), Charset.defaultCharset());
		String errorPred3 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructPredFalse3.rkt"), Charset.defaultCharset());
		String errorPred4 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructPredFalse4.rkt"), Charset.defaultCharset());
		String errorPred6 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleDefineStructPredFalse6.rkt"), Charset.defaultCharset());



		DrRacketInterpreter interpreter = new DrRacketInterpreter(simplePred);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket>true</drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(errorPred);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"not the correct struct Struktur\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(errorPred2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"this function is not defined\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(errorPred3);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"not the correct struct Struktur\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(errorPred4);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"this function is not defined\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(errorPred6);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"expects only 1 argument, but found more\"/></drracket>", interpreter.interpretWithXQuery());

	}



	@Test
	void structSelectTest() throws Exception{

		String structSelect = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineStructSelect.rkt"), Charset.defaultCharset());
		String structSelect2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineStructSelect2.rkt"), Charset.defaultCharset());

		String structSelectF = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineStructSelectFalse.rkt"), Charset.defaultCharset());
		String structSelectF2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineStructSelectFalse2.rkt"), Charset.defaultCharset());
		String structSelectF3 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineStructSelectFalse3.rkt"), Charset.defaultCharset());
		String structSelectF4 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("defineStructSelectFalse4.rkt"), Charset.defaultCharset());



		DrRacketInterpreter interpreter = new DrRacketInterpreter(structSelect);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal line=\"6\" type=\"Number\" value=\"10\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(structSelect2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"30\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(structSelectF);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"this function is not defined\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(structSelectF2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"expects only 1 argument, but found more\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(structSelectF3);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal>\"this is not the same struct :(\"</terminal></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(structSelectF4);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"expects only 1 argument, but found more\"/></drracket>", interpreter.interpretWithXQuery());


	}

	@Test
	void andTest() throws Exception{

		String simpleAnd = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleAnd.rkt"), Charset.defaultCharset());
		String simpleAnd2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleAnd2.rkt"), Charset.defaultCharset());
		String simpleAnd3 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("simpleAnd3.rkt"), Charset.defaultCharset());
		String trickyAnd = IOUtils.toString(ClassLoader.getSystemResourceAsStream("trickyAnd.rkt"), Charset.defaultCharset());
		String trickyAnd2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("trickyAnd2.rkt"), Charset.defaultCharset());


		String wrongAnd = IOUtils.toString(ClassLoader.getSystemResourceAsStream("wrongSizeAnd.rkt"), Charset.defaultCharset());
		String wrongAnd2 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("wrongSizeAnd2.rkt"), Charset.defaultCharset());

		String wrongAnd3 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("wrongTypeAnd.rkt"), Charset.defaultCharset());
		String wrongAnd4 = IOUtils.toString(ClassLoader.getSystemResourceAsStream("wrongTypeAnd2.rkt"), Charset.defaultCharset());



		DrRacketInterpreter interpreter = new DrRacketInterpreter(simpleAnd);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"true\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(simpleAnd2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"false\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(simpleAnd3);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"true\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(trickyAnd);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"false\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(trickyAnd2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"10\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(wrongAnd);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"falsche Anzahl an Argumenten für and-Klausel\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(wrongAnd2);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"falsche Anzahl an Argumenten für and-Klausel\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(wrongAnd3);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"falscher Argument Typ in and\"/></drracket>", interpreter.interpretWithXQuery());

		interpreter = new DrRacketInterpreter(wrongAnd4);
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><drracket><terminal value=\"falscher Argument Typ in and\"/></drracket>", interpreter.interpretWithXQuery());

	}



}
