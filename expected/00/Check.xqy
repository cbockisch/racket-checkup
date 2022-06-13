xquery version "1.0";

import module namespace aa='https://plt.bitbucket.io/autoassess' at '../DrRacketFunctions.xqy';

aa:assertPresent("Es ist nicht das korrekte Sprachniveau ('beginner') eingestellt oder Teachpacks fehlen ('universe', 'image', 'abstraction').", aa:studentLanguage("beginner", ('"image.rkt"', '"abstraction.rkt"', '"universe.rkt"'), /drracket)),

aa:assertPresent("Top-Level Funktion sum mit einem Parameter ist nicht definiert", aa:funDecl("sum", 1, true(), /drracket)),

aa:assertPresent("Bei der Top-Level Funktion sum mit einem Parameter fehlt die Dokumentaiton", aa:funComment(aa:funDecl("sum", 1, true(), /drracket))),

aa:assertPresent("Die Funktion sum enthält keinen rekursiven Aufruf", aa:funCall("sum", 1, aa:funBody(aa:funDecl("sum", 1, false(), /drracket))))