package io.bitbucket.plt.autotutor.racket.ui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Arrays;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JEditorPane;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;
import javax.swing.text.Document;
import javax.swing.text.html.HTMLEditorKit;

import org.apache.commons.io.FileUtils;

import io.bitbucket.plt.autotutor.racket.Assess;
import io.bitbucket.plt.autotutor.racket.AssessmentFailedException;

public class AutoTutorGui {
    
    private JTextField racket;
    private JTextField expected;
    private JTextField results;
    private JComboBox<String> expectedList;
    private JTextField solutionFilename;
    private JEditorPane jEditorPane;

    public AutoTutorGui() {
        // 1. Create the frame.
        JFrame frame = new JFrame("FrameDemo");

        // 2. Optional: What happens when the frame closes?
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // 3. Create components and put them in the frame.
        JPanel filesPanel = new JPanel(new GridLayout(3, 3));
        frame.getContentPane().add(filesPanel, BorderLayout.NORTH);
        
        // Racket Binary
        filesPanel.add(new JLabel("Racket:"));
        racket = new JTextField(Assess.RACKET_BINARY);
        racket.setEditable(false);
        filesPanel.add(racket);
        JButton browseRacket = new JButton("Durchsuchen...");
        browseRacket.addActionListener(this::browseRacket);
        filesPanel.add(browseRacket);

//        // Expected Folder
//        filesPanel.add(new JLabel("Aufgabenstellungen:"));
//        expected = new JTextField(Assess.EXPECTED_BASE_DIR.getAbsolutePath());
//        expected.setEditable(false);
//        filesPanel.add(expected);
//        JButton browseExpected = new JButton("Durchsuchen...");
//        browseExpected.addActionListener(this::browseExpected);
//        filesPanel.add(browseExpected);
//
//        // Results Folder
//        filesPanel.add(new JLabel("Resultate:"));
//        results = new JTextField(Assess.OUTPUT_DIR.getAbsolutePath());
//        results.setEditable(false);
//        filesPanel.add(results);
//        JButton browseResults = new JButton("Durchsuchen...");
//        browseResults.addActionListener(this::browseResults);
//        filesPanel.add(browseResults);

        // Select Expected
        filesPanel.add(new JLabel("Aufgabenstellung:"));
        String[] petStrings = Arrays.stream(Assess.EXPECTED_BASE_DIR.listFiles(file -> file.isDirectory()))
                .map(file -> file.getName()).toArray(size -> new String[size]);
        expectedList = new JComboBox<String>(petStrings);
        filesPanel.add(expectedList);
        filesPanel.add(new JLabel());
        
        // Solution File
        filesPanel.add(new JLabel("Lösungsdatei:"));
        solutionFilename = new JTextField();
        filesPanel.add(solutionFilename);
        JButton browse = new JButton("Durchsuchen...");
        browse.addActionListener(this::browseSolution);
        filesPanel.add(browse);
        
        // Results view
        jEditorPane = new JEditorPane();
        jEditorPane.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(jEditorPane);
        HTMLEditorKit kit = new HTMLEditorKit();
        jEditorPane.setEditorKit(kit);
        String htmlString = "<html>\n"
                          + "<body>\n"
                          + "<h1>Willkommen zum DrRacket Auto-Tutor</h1>\n"
                          + "</body>\n";
        Document doc = kit.createDefaultDocument();
        jEditorPane.setDocument(doc);
        jEditorPane.setText(htmlString);
        frame.getContentPane().add(scrollPane, BorderLayout.CENTER);

        // run check
        JPanel buttonsPanel = new JPanel(new GridLayout(2, 1));
        frame.getContentPane().add(buttonsPanel, BorderLayout.SOUTH);
        
        JButton check = new JButton("Lösung überprüfen");
        buttonsPanel.add(check);
        check.addActionListener(this::assess);

        JButton about = new JButton("Über ...");
        buttonsPanel.add(about);
        about.addActionListener(this::about);
        
        // finalize frame
        frame.setSize(new Dimension(800,600));
        frame.setVisible(true);
    }

    public static void main(String[] args) {
        new AutoTutorGui();
    }
    
    private static final JFileChooser fc = new JFileChooser(); 
    
    public void browseRacket(ActionEvent e) {
        try {
            int returnVal = fc.showOpenDialog(null);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();
                racket.setText(file.getAbsolutePath());
                Assess.updateRacketPath(file.getAbsolutePath());
            }
        } catch (Throwable thr) {
            JOptionPane.showMessageDialog(null, "Ein Fehler ist aufgetreten. Für Details siehe error.log.");
            Assess.log(thr);
        }

    }

//    public void browseExpected(ActionEvent e) {
//        int returnVal = fc.showOpenDialog(null);
//        if (returnVal == JFileChooser.APPROVE_OPTION) {
//            File file = fc.getSelectedFile();
//            expected.setText(file.getAbsolutePath());
//            Assess.updateExpectedDir(file.getAbsolutePath());
//        }
//    }
//
//    public void browseResults(ActionEvent e) {
//        int returnVal = fc.showOpenDialog(null);
//        if (returnVal == JFileChooser.APPROVE_OPTION) {
//            File file = fc.getSelectedFile();
//            results.setText(file.getAbsolutePath());
//            Assess.updateOutputDir(file.getAbsolutePath());
//        }
//    }

    public void browseSolution(ActionEvent e) {
        try {
            int returnVal = fc.showOpenDialog(null);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();
                solutionFilename.setText(file.getAbsolutePath());
            }
        } catch (Throwable thr) {
            JOptionPane.showMessageDialog(null, "Ein Fehler ist aufgetreten. Für Details siehe error.log.");
            Assess.log(thr);
        }

    }
    
    public void assess(ActionEvent e) {
        try {
            Assess assess = new Assess(solutionFilename.getText(), expectedList.getItemAt(expectedList.getSelectedIndex()));
            try {
                assess.assess();
            } catch (AssessmentFailedException failed) {
                // this can be ignored
            }
            assess.report();
            String report = FileUtils.readFileToString(assess.getResultsFile(), (Charset) null);
            jEditorPane.setText(report);
        } catch (Throwable thr) {
            JOptionPane.showMessageDialog(null, "Ein Fehler ist aufgetreten. Für Details siehe error.log.");
            Assess.log(thr);
        }
    }
    
    public void about(ActionEvent e) {
        JOptionPane.showMessageDialog(null, 
                "Dieses Werkzeug für das automatische Testieren von DrRacket Programmen\n"
                + "ist ausschließlich für den Gebrauch in der Lehrveranstaltung\n"
                + "Deklarative Programmierung an der Philipps-Universität Marburg\n"
                + "bestimmt.\n"
                + "\n"
                + "Autor: Prof. C. Bockisch, AG Programmiersprachen und Werkzeuge, Philipps-\n"
                + "Universität Marburg,\n"
                + "bockisch@mathematik.uni-marburg.de\n"
                + "\n"
                + "Dieses Programm verwendet die folgenden Bibliotheken:\n"
                + "* ANTLR 4.7.2\n"
                + "* Apache Commons IO 2.6\n"
                + "* Jjson-simple 3.1\n"
                + "* Apache Commons Text 1.6");
    }
}
