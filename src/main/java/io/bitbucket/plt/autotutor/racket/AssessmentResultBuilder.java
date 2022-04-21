package io.bitbucket.plt.autotutor.racket;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

public class AssessmentResultBuilder {
	
	private StringBuilder sb = new StringBuilder();
	private AssessmentState state = AssessmentState.IN_PROGRESS;
	
	public AssessmentResultBuilder() {
		prologue();
	}
	
	public void reset() {
	    sb = new StringBuilder();
	    state = AssessmentState.IN_PROGRESS;
	    prologue();
	}
	
	public void newTask(String task) {
		header1(task);
	}

	public void failure(String message, int exitCode, String stdOut, String stdErr) {
		header1Negative("Fehlschlag");
		text(message + "(Mit exit code " + exitCode + ".)");
		header2("Standard Ausgabestrom");
		block(stdOut);
		header2("Fehler Ausgabestrom");
		block(stdErr);
		changeState(AssessmentState.FAILED);
		throw new AssessmentFailedException();
	}
	
	public void failure(String message) {
		header1Negative("Fehlschlag");
		text(message);
		changeState(AssessmentState.FAILED);
		throw new AssessmentFailedException();
	}
	
	public void notAsExpected(String message, String actual, String expected) {
		header1Negative("Fehlschlag");
		text(message);
		header2("Erwartet");
		block("'" + expected + "'");
		header2("Tatsächlich");
		block("'" + actual + "'");
		changeState(AssessmentState.FAILED);
        throw new AssessmentFailedException();
	}
	
	public void exception(Throwable thr) {
		exception(null, thr);
	}
	
	public void failure(String message, String detail) {
		header1Negative("Fehlschlag");
		text(message);
		header2("Details");
		block(detail);
		changeState(AssessmentState.FAILED);
		throw new AssessmentFailedException();
	}

	public void exception(String string, Throwable thr) {
		header1Negative("Fehlschlag");
		if (string != null)
			text(string);
		header2("Excpetion");
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		try (PrintStream ps = new PrintStream(bos)) {
			thr.printStackTrace(ps);
		}
		block(bos.toString());
		changeState(AssessmentState.FAILED);
		throw new AssessmentFailedException();
	}

	public void taskFinished() {
	    if (state == AssessmentState.IN_PROGRESS)
	        header2Positive("Schritt erfüllt");
	    else
	        header2Negative("Schritt nicht erfüllt");
	}

	public void jobFinished() {
        if (state == AssessmentState.IN_PROGRESS) {
            header1Positive("Erfolg");
            changeState(AssessmentState.SUCCEEDED);
        }
        else {
            header1Negative("Beendet mit Fehlern");
        }
	}
	
	private void changeState(AssessmentState newState) {
		if (state == AssessmentState.IN_PROGRESS || state == newState) {
	        state = newState;
		}
		else {
		    throw new IllegalStateException("Assessment result already in state " + state + ".");
		}
		if (state != AssessmentState.IN_PROGRESS)
	          epilogue();

	}
	
	public AssessmentState getState() {
		return state;
	}

	protected void prologue() {
		sb.append(
				"<!DOCTYPE html>\n" + 
				"<html>\n" + 
				"  <head>\n" + 
				"    <meta charset=\"UTF-8\">\n" + 
				"    <title>DrRacket AutoAsessment Ergebnis</title>\n" + 
				"  </head>\n" + 
				"  <body>\n");
	}

	protected void epilogue() {
		sb.append(
				"  </body>\n" + 
				"</html>");
	}
	
	protected void header1(String text) {
		sb.append("<h1>" + text + "</h1>");
	}
	
	protected void header2(String text) {
		sb.append("<h2>" + text + "</h2>");		
	}
	
	protected void header1Negative(String text) {
		sb.append("<h2 style=\"color:red\">" + text + "</h2>");
	}

	protected void header1Positive(String text) {
		sb.append("<h1 style=\"color:green\">" + text + "</h1>");
	}
	
	protected void header2Positive(String text) {
		sb.append("<h2 style=\"color:green\">" + text + "</h2>");
	}

    protected void header2Negative(String text) {
        sb.append("<h2 style=\"color:red\">" + text + "</h2>");
    }

    protected void text(String text) {
		sb.append("<p>" + text.replace("\n", "<br/>") + "</p>");
		
	}
	
	protected void block(String text) {
		sb.append(
				"<div style=\"margin-left: 4em;\">\n" + 
				text.replace("\n", "<br/>") + 
				"</div>");
	}

	public String getReport() {
		if (state == AssessmentState.IN_PROGRESS)
			throw new IllegalStateException("Assessment still in progress.");
		return sb.toString();
	}

}
