xquery version "1.0";

import module namespace aa='https://plt.bitbucket.io/autoassess' at 'DrRacketFunctions.xqy';


declare variable $funName := "vec-skal-mult";
declare variable $funParameterTypes := ("Vektor", "Number");
declare variable $funReturnType := "Vektor";
declare variable $funDecl :=  aa:funDecl($funName, count($funParameterTypes), true(), /drracket);

declare variable $consts :=  /drracket//paren/terminal[@value='define']/following-sibling::terminal[1]/attribute::value/string();

aa:assertPresent(
    "Es ist nicht das korrekte Sprachniveau ('beginner') eingestellt oder Teachpacks fehlen ('universe', 'image').",
    aa:studentLanguage("beginner", ('"image.rkt"', '"universe.rkt"'), /drracket)),

aa:assertTrue(
    "Eckige Klammern sind nur für die Fälle von cond-Ausdrücken erlaubt.",
    aa:squareParensOnlyInCond(/drracket)),
  
aa:assertTrue("Geben Sie Fälle von cond-Ausdrücken in eckigen Klammern an",
    aa:condCasesSquare(/drracket)),



aa:assertPresent(
    concat("Die Funktion ", $funName, " mit einem Parameter ist nicht definiert."),
    $funDecl),

aa:assertPresent(
    concat("Es sind keine Tests für die Function ", $funName, " definiert."),
    aa:precedingTests($funDecl)),

aa:assertPresent(
    concat("Es ist kein Kommentar für die Funktion ", $funName, " angegeben"),
    aa:functionComment($funDecl)),

aa:assertTrue(
    concat("Für die Funktion ", $funName, " ist die Signatur nicht oder nicht korrekt dokumentiert."),
  aa:funDocMatchesSignature($funDecl,
$funParameterTypes, $funReturnType)),

aa:assertTrue(
    concat("Die Dokumentation für die Funktion ", $funName, " enthält keine Beschreibung für alle parameter."),
  aa:funDocContainsParams($funDecl)),

aa:assertPresent(
   concat("Die Tests für die Funktion ", $funName, " verwenden keine als Konstanten definierten Beispielwerte."),
  aa:precedingTests($funDecl)//terminal[@value=$consts]),
 
aa:assertTrue(
    "Datentyp Vektor ist nicht korrekt als Kommentar definiert",
    for $comment in //comment/text()
    return matches($comment,
    ".*Vektor.*\(\s*make-posn\s*Number\s*Number\s*\).*", "s"))