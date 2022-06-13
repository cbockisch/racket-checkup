xquery version "1.0";

import module namespace aa='https://plt.bitbucket.io/autoassess' at 'DrRacketFunctions.xqy';


declare variable $funName := "list-remove";
declare variable $funParameterTypes := ("X", "\(\s*list-of\s+X\s*\)");
declare variable $funReturnType := "\(\s*list-of\s+X\s*\)";
declare variable $funDecl :=  aa:funDecl($funName, count($funParameterTypes), true(), /drracket);
declare variable $allowed := ('empty?', 'cons', 'first', 'rest', 'cons?', 'equal?', 'define', 'cond', 'if', 'else', 'and', 'or', 'not', 'list',
'modname', 'read-case-sensitive', 'teachpacks', 'lib', 'htdp-settings', '#t', '#f',
//paren/terminal[@value="define"]/following-sibling::paren[1]/terminal[1]/attribute::value/string(),
//paren/terminal[@value="define"]/following-sibling::node()[1]/self::terminal[1]/attribute::value/string());

aa:assertPresent(
    "Es ist nicht das korrekte Sprachniveau ('beginner' oder 'beginner with list abbreviations') eingestellt oder Teachpacks fehlen ('universe', 'image').",
    (aa:studentLanguage("beginner-abbr", ('"image.rkt"', '"universe.rkt"'), /drracket),
    aa:studentLanguage("beginner", ('"image.rkt"', '"universe.rkt"'), /drracket))),

aa:assertTrue(
    "Eckige Klammern sind nur für die Fälle von cond-Ausdrücken erlaubt.",
    aa:squareParensOnlyInCond(/drracket)),
  
aa:assertTrue("Geben Sie Fälle von cond-Ausdrücken in eckigen Klammern an",
    aa:condCasesSquare(/drracket)),



aa:assertPresent(
    concat("Die Funktion ", $funName, " mit zwei Parametern ist nicht definiert."),
    $funDecl),

aa:assertTrue(
    concat("Es sind keine ausreichenden Tests für die Function ", $funName, " definiert."),
    count(aa:precedingTests($funDecl)) >= 2),

aa:assertPresent(
    concat("Es ist kein Kommentar für die Funktion ", $funName, " angegeben"),
    aa:functionComment($funDecl)),

aa:assertTrue(
    concat("Für die Funktion ", $funName, " ist die Signatur nicht oder nicht korrekt dokumentiert. Bitte verwenden Sie als Namen für den Typparameter X."),
  aa:funDocMatchesSignature2($funDecl,"\[\s*X\s*\]", 
$funParameterTypes, $funReturnType)),

aa:assertTrue(
    concat("Die Dokumentation für die Funktion ", $funName, " enthält keine Beschreibung für alle parameter."),
  aa:funDocContainsParams($funDecl)),
  
for $call in //paren/child::node()[1]/self::terminal/attribute::value/string()
where not(exists(index-of($allowed, $call))) and not(starts-with($call, "check-")) and not(string-length($call) <= 2)
return <p>Die Verwendung der Funktion {$call} ist nicht erlaubt.</p>