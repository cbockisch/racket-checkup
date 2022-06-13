package io.bitbucket.plt.autotutor.racket.interpret;

import java.io.*;
import java.nio.charset.Charset;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;

import org.antlr.v4.runtime.ANTLRErrorStrategy;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.DefaultErrorStrategy;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.RecognitionException;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import io.bitbucket.plt.autotutor.DrRacketLexer;
import io.bitbucket.plt.autotutor.DrRacketParser;
import net.sf.saxon.Configuration;
import net.sf.saxon.s9api.DocumentBuilder;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XQueryCompiler;
import net.sf.saxon.s9api.XQueryEvaluator;
import net.sf.saxon.s9api.XQueryExecutable;
import net.sf.saxon.s9api.XdmNode;

public class DrRacketInterpreter {

	private static final String DEFAULT_XQUERY_FILE = "interpret.xqy";
	private boolean parseErrorsOccurred;
	private String errorOutput;
	private String xml;
	private String rktFile;

	public DrRacketInterpreter(String rktFile) throws Exception {

		this.rktFile = rktFile;

		DrRacketLexer lexer = new DrRacketLexer(CharStreams.fromString(rktFile));

		DrRacketParser parser = new DrRacketParser(new CommonTokenStream(lexer));

		ANTLRErrorStrategy errorStrategy = new DefaultErrorStrategy() {
			@Override
			public void reportError(Parser recognizer, RecognitionException e) {
				super.reportError(recognizer, e);
				parseErrorsOccurred = true;
			}

		};
		parser.setErrorHandler(errorStrategy);
		PrintStream origSysErr = System.err;

		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		try (PrintStream ps = new PrintStream(bos)) {
			System.setErr(ps);
			parser.start();
			System.setErr(origSysErr);
		}

		errorOutput = bos.toString();
		if (parseErrorsOccurred) {
			throw new Exception("Ein Fehler ist beim Einlesen der DrRacket-Datei aufgetreten. "
					+ "Vermutlich ist die Datei nicht im Text-Format gespeichert. "
					+ "Das passiert z.B. dann, wenn Bilder Teil des Programms sind. "
					+ "Probieren Sie die Datei über 'File' -> 'Save Other' -> 'Save Definitions as Text ...' zu speichern. "
					+ "Bilder gehen dabei verloren und Berechnungen, die von den Bildern abhängen werden dadurch vorraussichtlich fehlerhaft.");
		}

		// pretty printing
		xml = prettyPrint(parser.xml.toString());
	}

	private String prettyPrint(String xml) throws SAXException, IOException, ParserConfigurationException,
			TransformerFactoryConfigurationError, TransformerConfigurationException, TransformerException {
		InputSource src = new InputSource(new StringReader(xml.toString()));
		Document document = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(src);

		TransformerFactory transformerFactory = TransformerFactory.newInstance();
		Transformer transformer = transformerFactory.newTransformer();
		transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
		transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
		transformer.setOutputProperty(OutputKeys.INDENT, "yes");

		Writer out = new StringWriter();
		transformer.transform(new DOMSource(document), new StreamResult(out));
		return out.toString();
	}

	/**
	 * Interpret the Racket program with the XQuery expression from the default file.
	 * @return
	 * @throws Exception
	 */
	public String interpretWithXQuery() throws Exception {
		// read the XQuery expression from a file on the class path (e.g., the src/main/resources folder)
		String query = IOUtils.toString(ClassLoader.getSystemResourceAsStream(DEFAULT_XQUERY_FILE), Charset.defaultCharset());

		return interpretWithXQuery(query);
	}

	/**
	 * Interpret the Racket program with the passed XQuery expression.
	 * @return
	 * @throws Exception
	 */
	public String interpretWithXQuery(String query) throws SaxonApiException, Exception, IOException {
		// prepare query execution with Saxon:
		Processor processor = new Processor(Configuration.newConfiguration());

		// create parsed XML document
		InputSource is = new InputSource(new StringReader(xml));
		DocumentBuilder builder = processor.newDocumentBuilder();
		XdmNode doc = builder.build(new SAXSource(is));

		
		XQueryCompiler compiler = processor.newXQueryCompiler();

		// prepare XQuery evaluation		
		XQueryExecutable exp = compiler.compile(query);
		final XQueryEvaluator evaluator = exp.load();
		evaluator.setContextItem(doc);

		// check if XQuery expression is correct
		if (!exp.getUnderlyingCompiledQuery().usesContextItem()) {
			throw new Exception("Fehlerhafter Check (XQuery verwendet Context-Item nicht).");
		}

		// prepare serializer for result of XQuery expreession
		// the result will be written to bos
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		Serializer serializer = processor.newSerializer(bos);
		serializer.setOutputProperty(Serializer.Property.METHOD, "adaptive");
	
		// execute query
		evaluator.run(serializer);
		
		// collect result
		bos.flush();
		String result = bos.toString();
		bos.close();
		
		// done
		return result;
	}

	public String getInput() {
		return rktFile;
	}

	public String getXml() {
		return xml;
	}

	public boolean hasParseError() {
		return parseErrorsOccurred;
	}
	
	public String getParseErrors() {
		if (parseErrorsOccurred)
			return errorOutput;
		else
			return "No parse errors.";	
	}

	// Nick did this 3.5
	public void toXMLFile(String fileName) throws IOException {
		File file = new File("../Bachelor_Arbeit_stuff/XMLfromRacket/" + fileName);
		FileUtils.writeStringToFile(file, xml, (Charset) null);
	}

}
