package io.bitbucket.plt.autotutor.racket.interpret;

import static org.junit.jupiter.api.Assertions.assertFalse;

import java.io.IOException;
import java.nio.charset.Charset;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.apache.commons.io.IOUtils;
import org.junit.jupiter.api.Test;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.diff.Diff;

import io.bitbucket.plt.autotutor.DrRacketLexer;
import io.bitbucket.plt.autotutor.DrRacketParser;
import net.sf.saxon.s9api.SaxonApiException;

class ParserTest {

	@Test
	void testCanParse() throws IOException {
		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Terminals.rkt"),
				Charset.defaultCharset());

		DrRacketLexer lexer = new DrRacketLexer(CharStreams.fromString(rktFile));

		DrRacketParser parser = new DrRacketParser(new CommonTokenStream(lexer));

		parser.start();
	}

	@Test
	void testParseEmpty() throws IOException, SaxonApiException {
		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Empty.rkt"), Charset.defaultCharset());
		String xmlFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Empty.xml"), Charset.defaultCharset());

		DrRacketLexer lexer = new DrRacketLexer(CharStreams.fromString(rktFile));
		DrRacketParser parser = new DrRacketParser(new CommonTokenStream(lexer));
		parser.start();

		String xml = parser.xml.toString();

		Diff myDiff = DiffBuilder.compare(xmlFile).withTest(xml).checkForSimilar().ignoreWhitespace().build();
		assertFalse(myDiff.hasDifferences(), myDiff.toString());
	}

	@Test
	void testAllForms() throws IOException, SaxonApiException {
		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("AllForms.rkt"), Charset.defaultCharset());
		String xmlFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("AllForms.xml"), Charset.defaultCharset());

		DrRacketLexer lexer = new DrRacketLexer(CharStreams.fromString(rktFile));
		DrRacketParser parser = new DrRacketParser(new CommonTokenStream(lexer));
		parser.start();

		String xml = parser.xml.toString();

		Diff myDiff = DiffBuilder.compare(xmlFile).withTest(xml).checkForSimilar().ignoreWhitespace().build();
		assertFalse(myDiff.hasDifferences(), myDiff.toString());
	}

	@Test
	void testParseTerminals() throws Exception {
		String rktFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Terminals.rkt"), Charset.defaultCharset());
		String xmlFile = IOUtils.toString(ClassLoader.getSystemResourceAsStream("Terminals.xml"), Charset.defaultCharset());

		DrRacketLexer lexer = new DrRacketLexer(CharStreams.fromString(rktFile));
		DrRacketParser parser = new DrRacketParser(new CommonTokenStream(lexer));
		parser.start();

		String xml = parser.xml.toString();

		Diff myDiff = DiffBuilder.compare(xmlFile).withTest(xml).checkForSimilar().ignoreWhitespace().build();
		assertFalse(myDiff.hasDifferences(), myDiff.toString());
	}
	
}
