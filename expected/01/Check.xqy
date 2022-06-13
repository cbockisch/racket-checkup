xquery version "1.0";

import module namespace aa='https://plt.bitbucket.io/autoassess' at '../DrRacketFunctions.xqy';

aa:assertPresent("Es ist nicht das korrekte Sprachniveau ('beginner') eingestellt oder Teachpacks fehlen ('universe', 'image').", aa:studentLanguage("beginner", ('"image.rkt"', '"universe.rkt"'), /drracket)),

if (/drracket/descendant::terminal[@value="read-case-sensitive"]/following::terminal[1]/attribute::value/string() != "#t") then (
<p>Sie haben die Unterscheidung zwischen Groß- und Kleinschreibung nicht aktiviert.</p>
 )
  else (),

aa:assertPresent("Der Ausdruck (+ 17 25) fehlt.", /drracket/paren/terminal[@value='+']/following-sibling::terminal[@value='17']/following-sibling::terminal[@value='25'])