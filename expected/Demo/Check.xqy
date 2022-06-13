xquery version "1.0";

import module namespace aa='https://plt.bitbucket.io/autoassess' at '../DrRacketFunctions.xqy';

aa:assertNotPresent("Es wird Multiplikation verwendet", aa:funDecl("double", 1, true(), /drracket)//terminal[@value="*"]),
aa:assertPresent("Die Funktion double wird nicht aufgerufen", /drracket/paren/terminal[1][@value='double'])