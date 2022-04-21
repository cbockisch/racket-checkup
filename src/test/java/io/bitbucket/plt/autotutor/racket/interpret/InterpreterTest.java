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
	void testDefaultQuery() throws Exception {
		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Demo.rkt"), Charset.defaultCharset());
		
		DrRacketInterpreter interpreter = new DrRacketInterpreter(rktFile);
		
		assertEquals("value=\"0\"", interpreter.interpretWithXQuery());
	}

}
