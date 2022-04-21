package io.bitbucket.plt.autotutor.racket;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.lang.Thread.UncaughtExceptionHandler;
import java.nio.charset.Charset;
import java.util.concurrent.TimeUnit;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamSource;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.DefaultErrorStrategy;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.RecognitionException;
import org.apache.commons.io.FileUtils;
import org.xml.sax.InputSource;

import com.github.cliftonlabs.json_simple.JsonException;

import io.bitbucket.plt.autotutor.DrRacketLexer;
import io.bitbucket.plt.autotutor.DrRacketParser;
import io.bitbucket.plt.autotutor.racket.ui.AutoTutorGui;
import net.sf.saxon.Configuration;
import net.sf.saxon.Version;
import net.sf.saxon.s9api.DocumentBuilder;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XQueryCompiler;
import net.sf.saxon.s9api.XQueryEvaluator;
import net.sf.saxon.s9api.XQueryExecutable;
import net.sf.saxon.s9api.XdmNode;

public class Assess {

    public final static String TEST_RKT;
    public final static String CHECK_XQY;
    public static File OUTPUT_DIR;
    public static File EXPECTED_BASE_DIR;
    public static String RACKET_BINARY;
    private static PrintWriter log;

    static {
        try {
            log = new PrintWriter(new FileWriter("error.log"));
        } catch (IOException e) {
            e.printStackTrace(System.err);
        }
        Thread.setDefaultUncaughtExceptionHandler(new UncaughtExceptionHandler() {
            @Override
            public void uncaughtException(Thread t, Throwable exception) {
                exception.printStackTrace(log);
            }
        });
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            log.close();
        }));

        TEST_RKT = "Test.rkt";
        CHECK_XQY = "Check.xqy";
        loadConfig();
    }
	
    public static void loadConfig() {
        try {
            Config config = new Config(Config.DEFAULT_CONFIG_FILE);
            RACKET_BINARY = config.racketPath;

            OUTPUT_DIR = new File(config.resultsFolder);
            OUTPUT_DIR.mkdirs();

            EXPECTED_BASE_DIR = new File(config.expectedFolder);
        } catch (FileNotFoundException | JsonException e) {
            throw new RuntimeException(e);
        }

    }
    
    public static void updateRacketPath(String racketPath) {
        try {
            Config config = new Config(Config.DEFAULT_CONFIG_FILE);
            config.racketPath = racketPath;
            config.save(Config.DEFAULT_CONFIG_FILE);
            loadConfig();
        } catch (JsonException | IOException e) {
            throw new RuntimeException(e);
        }
    }
    
    public static void updateOutputDir(String outputDir) {
        try {
            Config config = new Config(Config.DEFAULT_CONFIG_FILE);
            config.resultsFolder = outputDir;
            config.save(Config.DEFAULT_CONFIG_FILE);
            loadConfig();
        } catch (JsonException | IOException e) {
            throw new RuntimeException(e);
        }
    }
    
    public static void updateExpectedDir(String expectedDir) {
        try {
            Config config = new Config(Config.DEFAULT_CONFIG_FILE);
            config.expectedFolder = expectedDir;
            config.save(Config.DEFAULT_CONFIG_FILE);
            loadConfig();
        } catch (JsonException | IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static void main(String[] args) throws FileNotFoundException, JsonException {
        String programFile, assignment;
        if (args.length == 0) {
            new AutoTutorGui();
        } else {
            programFile = args[0];
            assignment = args[1];

            Assess assess = new Assess(programFile, assignment);
            try {
                assess.assess();
            } catch (AssessmentFailedException e) {
            }
            assess.report();
            if (assess.rb.getState() == AssessmentState.SUCCEEDED)
                System.out.println("Success");
            else if (assess.rb.getState() == AssessmentState.FAILED)
                System.out.println("Failure");
            else
                System.out.println("Unexpected termination");

            System.out.println("For results see " + assess.reportFile);
        }
	}

	public void report() {
	    try (FileWriter fw = new FileWriter(reportFile)) {
            fw.write(this.rb.getReport());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
	}

	private final File racketFile;
	private final File regularStdOut;
	private final File regularErrOut;
	private final File testStdOut;
	private final File testErrOut;
	private final File expectedDir;
	private final File regularStdOutExpected;
	private final File regularErrOutExpected;
	private final File xmlFile;

	private int racketExitValue;
	private final File racketFileWithTests;
    private final File testFile;
    private final File checkFile;
	private final File testResultsFile;
	private final File timeoutFile;
	private final File copiedTestFile;
	private final File testHarnessFile;
	private final File racketFileOutput;
	private final File reportFile;

    public final AssessmentResultBuilder rb;
    
	public Assess(String racketFilename, String expectedSubDirName) {
	    
		racketFile = new File(racketFilename);

		regularStdOut = new File(OUTPUT_DIR, "regular-stdout.txt");
		regularErrOut = new File(OUTPUT_DIR, "regular-errout.txt");
		testStdOut = new File(OUTPUT_DIR, "test-stdout.txt");
		testErrOut = new File(OUTPUT_DIR, "test-errout.txt");
		expectedDir = new File(EXPECTED_BASE_DIR, expectedSubDirName);
		xmlFile = new File(OUTPUT_DIR, "program.xml");
		racketFileOutput = new File(OUTPUT_DIR, racketFile.getName());
		racketFileWithTests = new File(OUTPUT_DIR, racketFile.getName() + ".t");
		copiedTestFile = new File(OUTPUT_DIR, TEST_RKT);
		testResultsFile = new File(OUTPUT_DIR, "test-out.txt");
		testHarnessFile = new File(EXPECTED_BASE_DIR, "Test-Harness.rkt");
		
		regularStdOutExpected = new File(expectedDir, "regular-stdout-expected.txt");
		regularErrOutExpected = new File(expectedDir, "regular-errout-expected.txt");
        testFile = new File(expectedDir, TEST_RKT);
        checkFile = new File(expectedDir, CHECK_XQY);
		timeoutFile = new File(expectedDir, "timeout.txt");
		
		reportFile = new File(OUTPUT_DIR, "result.html");
		rb = new AssessmentResultBuilder();

	}

	public void assess() {
	    
	    rb.reset();
		
		int TIMEOUT = 0;
		
        try (BufferedReader br = new BufferedReader(new FileReader(timeoutFile))) {
			TIMEOUT = Integer.parseInt(br.readLine());			
		} catch (IOException e) {
			rb.exception(e);
		}

		// STEP 1: execute submitted program
		rb.newTask("DrRacket Programm ausführen");

		try {
			FileUtils.copyFile(racketFile, racketFileOutput);
		} catch (IOException e) {
			rb.exception(e);
		}
		
		executeRacket(racketFileOutput.getName(), regularStdOut, regularErrOut, TIMEOUT, rb);
		checkExpectedOutput(regularStdOutExpected, regularStdOut, "Standard output does not match.", rb);
		checkExpectedOutput(regularErrOutExpected, regularErrOut, "Standard erroroutput does not match.", rb);
		rb.taskFinished();
		
		// STEP 2: perform static analysis
		rb.newTask("Statische Checks ausführen");
		racketToXml(racketFile, xmlFile, rb);

		String checkResult = processXQuery(checkFile, xmlFile, rb);
		if (checkResult == null) {
		    rb.failure("Fehler bei der Verarbeitung der Analyse " + checkFile.getName() + ".\n");
		}
		else {
    		checkResult = checkResult.replaceFirst("<\\?xml.*\\?>", "").trim();
    		if (!checkResult.equals("")) {
    			rb.failure(checkResult.toString());
    		}
		}
		rb.taskFinished();

		// STEP 3: run program with tests
		rb.newTask("Test ausführen");
		try {
			FileUtils.copyFile(racketFile, racketFileWithTests);
			FileUtils.copyFile(testFile, copiedTestFile);
			FileUtils.copyFile(testHarnessFile, new File(OUTPUT_DIR, testHarnessFile.getName()));
			try (FileWriter fw = new FileWriter(racketFileWithTests, true)) {
				fw.write("\n");
				fw.write("(require racket/include) (include \"" + TEST_RKT + "\")");
//				try (BufferedReader testFileReader = new BufferedReader(new FileReader(testFile))) {
//					// skip configuration
//					while (!testFileReader.readLine().startsWith("#"))
//						;
//
//					while (testFileReader.ready()) {
//						fw.write(testFileReader.readLine());
//						fw.write("\n");
//					}
//				}
			}
		} catch (IOException e) {
			rb.exception(e);
		}

		executeRacket(racketFileWithTests.getName(), testStdOut, testErrOut, TIMEOUT, rb);

		try {
			String testResult = FileUtils.readFileToString(testResultsFile, Charset.forName("UTF-8"));
			if (!testResult.trim().isEmpty()) {
				rb.failure("Tests fehlgeschlagen.", testResult);
			}
		} catch (IOException e) {
			rb.exception(e);
		}
		
		rb.taskFinished();

		rb.jobFinished();
	}

    private void racketToXml(File input, File output, AssessmentResultBuilder rb) {
        DrRacketLexer lexer;
        try {
            lexer = new DrRacketLexer(CharStreams.fromFileName(input.getAbsolutePath()));

            DrRacketParser parser = new DrRacketParser(new CommonTokenStream(lexer));

            class ErrorStrategy extends DefaultErrorStrategy {
                public boolean errorsOccurred = false;

                @Override
                public void reportError(Parser recognizer, RecognitionException e) {
                    super.reportError(recognizer, e);
                    errorsOccurred = true;
                }
            }
            ErrorStrategy errorStrategy = new ErrorStrategy();
            parser.setErrorHandler(errorStrategy);
            PrintStream origSysErr = System.err;

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            try (PrintStream ps = new PrintStream(bos)) {
                System.setErr(ps);
                parser.start();
                System.setErr(origSysErr);
            }
            if (errorStrategy.errorsOccurred) {
                rb.failure("Ein Fehler ist beim Einlesen der DrRacket-Datei aufgetreten. "
                        + "Vermutlich ist die Datei nicht im Text-Format gespeichert. "
                        + "Das passiert z.B. dann, wenn Bilder Teil des Programms sind. "
                        + "Probieren Sie die Datei über 'File' -> 'Save Other' -> 'Save Definitions as Text ...' zu speichern. "
                        + "Bilder gehen dabei verloren und Berechnungen, die von den Bildern abhängen werden dadurch vorraussichtlich fehlerhaft.",
                        bos.toString());
            }

            FileUtils.writeStringToFile(output, parser.xml.toString(), Charset.forName("UTF-8"));
        } catch (IOException e) {
            rb.exception(e);
        }
    }

	private void checkExpectedOutput(File expected, File actual, String message, AssessmentResultBuilder rb) {
		if (expected.exists()) {
			try {
				if (!FileUtils.contentEquals(actual, expected)) {
					rb.notAsExpected(message, FileUtils.readFileToString(actual, Charset.forName("UTF-8")),
							FileUtils.readFileToString(expected, Charset.forName("UTF-8")));
				}
			} catch (IOException e) {
				rb.exception(e);
			}
		}
	}

    private void executeRacket(String racketFilePath, File stdOut, File stdErr, int timeout,
            AssessmentResultBuilder rb) {
        ProcessBuilder pb = new ProcessBuilder(RACKET_BINARY, racketFilePath);
        pb.directory(OUTPUT_DIR);
        pb.redirectOutput(stdOut);
        pb.redirectError(stdErr);
        Process process;
        try {
            process = pb.start();
//		new Thread(() -> {
//			try {
//				process = pb.start();
//			} catch (IOException e) {
//				throw new RuntimeException(e);
//			}
//		}).run();

            try {
                if (!process.waitFor(timeout, TimeUnit.SECONDS)) {
                    process.destroyForcibly();
                    rb.failure("Zeitüberschreitung", "Höchstens " + timeout
                            + " Sekunden sind erlaubt. Wartet das Programm vielleicht auf Benutzereingaben?");
                }
            } catch (InterruptedException e) {
                rb.exception(e);
            }

            this.racketExitValue = process.exitValue();
            if (racketExitValue != 0) {
                rb.failure("Ausführung fehlgeschlagen.", racketExitValue,
                        FileUtils.readFileToString(stdOut, Charset.forName("UTF-8")),
                        FileUtils.readFileToString(stdErr, Charset.forName("UTF-8")));
            }
        } catch (IOException e) {
            rb.exception(e);
        }
    }

	private static String processXQuery(File xqFile, File xmlFile, AssessmentResultBuilder rb) {
		Source sourceInput;
		if (!xmlFile.exists()) {
			rb.failure("XML-Datei " + xmlFile + " fehlt.");
			return null;
		}

		if (Version.platform.isJava()) {
			InputSource eis = new InputSource(xmlFile.toURI().toString());
			sourceInput = new SAXSource(eis);
		} else {
			sourceInput = new StreamSource(xmlFile.toURI().toString());
		}

		Processor processor = new Processor(Configuration.newConfiguration());
		XQueryCompiler compiler = processor.newXQueryCompiler();

		XQueryExecutable exp;

		try (InputStream queryStream = new FileInputStream(xqFile)) {
			compiler.setBaseURI(xqFile.toURI());
			exp = compiler.compile(queryStream);
		} catch (IOException | SaxonApiException e) {
			rb.exception(e);
			return null;
		}

		final XQueryEvaluator evaluator = exp.load();

		DocumentBuilder builder = processor.newDocumentBuilder();
		if (!exp.getUnderlyingCompiledQuery().usesContextItem()) {
			rb.failure("Fehlerhafter Check (XQuery verwendet Context-Item nicht).");
			return null;
		}
//         builder.setDTDValidation(getConfiguration().getBooleanProperty(Feature.DTD_VALIDATION));
//         if (getConfiguration().getBooleanProperty(Feature.DTD_VALIDATION_RECOVERABLE)) {
//             sourceInput = new AugmentedSource(sourceInput, getConfiguration().getParseOptions());
//         }
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		try {
			XdmNode doc = builder.build(sourceInput);
			evaluator.setContextItem(doc);

			Serializer serializer = processor.newSerializer(bos);

			evaluator.run(serializer);
			bos.flush();
		} catch (SaxonApiException | IOException e) {
			rb.exception(e);
			return null;
		}
		return bos.toString();
	}

    public File getResultsFile() {
        return reportFile;
    }

    public static void log(Throwable thr) {
        thr.printStackTrace(log);
        log.flush();
    }

}
