package io.bitbucket.plt.autotutor.racket;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;

import com.github.cliftonlabs.json_simple.JsonException;
import com.github.cliftonlabs.json_simple.JsonObject;
import com.github.cliftonlabs.json_simple.Jsoner;

public class Config {

    public static final String DEFAULT_CONFIG_FILE = "config.json";
    
    private static final String RACKET_PATH_KEY = "racket-path";
    private static final String RESULTS_FOLDER_KEY = "results-folder";
    private static final String EXPECTED_FOLDER_KEY = "expected-folder";
    
    
    public String racketPath;
    public String resultsFolder;
    public String expectedFolder;
    
    public Config() {
        racketPath = "/Applications/Racket v6.8/bin/racket";
        expectedFolder = "expected";
        resultsFolder = "results";
    }
    
    public Config(String filename) throws FileNotFoundException, JsonException {
        JsonObject jsonObject = (JsonObject) Jsoner.deserialize(new FileReader(filename));

        racketPath = jsonObject.getString(Jsoner.mintJsonKey(RACKET_PATH_KEY, null));
        expectedFolder = jsonObject.getString(Jsoner.mintJsonKey(EXPECTED_FOLDER_KEY, null));
        resultsFolder = jsonObject.getString(Jsoner.mintJsonKey(RESULTS_FOLDER_KEY, null));;
    }
    
    public void save(String filename) throws IOException {
        StringWriter sw = new StringWriter();
        try (FileWriter fw = new FileWriter(filename)) {
            JsonObject jsonObject = new JsonObject();
            jsonObject.put(RACKET_PATH_KEY, racketPath);
            jsonObject.put(RESULTS_FOLDER_KEY, resultsFolder);
            jsonObject.put(EXPECTED_FOLDER_KEY, expectedFolder);
            
            Jsoner.serialize(jsonObject, sw);
            fw.write(Jsoner.prettyPrint(sw.toString()));
        }
    }
    
    public static void main(String[] args) throws IOException {
        new Config().save(DEFAULT_CONFIG_FILE);
    }
    
}
