xquery version "1.0";

import module namespace aa='https://plt.bitbucket.io/autoassess' at '../DrRacketFunctions.xqy';

declare function aa:index-of-node
  ( $nodes as node()* ,
    $nodeToFind as node() )  as xs:integer* {

  for $seq in (1 to count($nodes))
  return $seq[$nodes[$seq] is $nodeToFind]
 } ;
 
declare function aa:precedingTests($progElemem as element()*) as element()* {
  let $test := $progElemem/preceding-sibling::*[1][self::paren]/terminal[@value="check-expect"]/parent::element()
  return if (fn:empty($test)) then ()
    else 
    ((aa:precedingTests($test), $test))
};

declare function aa:functionComment($funDecl) as element()* {
  let $tests := aa:precedingTests($funDecl)
  let $comment := if (fn:empty($tests)) 
    then
      ($funDecl/preceding-sibling::*[1][self::comment])
    else
      (fn:head($tests)/preceding-sibling::*[1][self::comment])
  return $comment
};

declare function aa:findFirstCall($name as xs:string, $progElem as element()*, $includeSelf) {
  let $temp :=
    if ($includeSelf)
    then
      (($progElem/descendant-or-self::paren/terminal[@value=$name])[1])
    else
      (($progElem/descendant::paren/terminal[@value=$name])[1])

  return $temp/parent::paren
};

declare function aa:funDocMatchesSignature($funDecl as element()*, $parameterTypes as xs:string*, $returnType as xs:string) as xs:boolean{
  matches(aa:functionComment($funDecl)/text(),
    concat(";\s*", string-join($parameterTypes, "\s*"), "\s*->\s*", $returnType))
};

declare function aa:funDocContainsParam($funDecl as element()*, $param as xs:string) {
  matches(aa:functionComment($funDecl)/text(),
    concat("(^|[^\w*])", $param, "([^\w*]|$)"))
};

declare function aa:funDocContainsParams($funDecl as element()*) {
  let $undocumented :=
    for $param in $funDecl/paren[1]/terminal[1]/following-sibling::terminal/@value
    where not(aa:funDocContainsParam($funDecl, data($param)))
    return $param
  return empty($undocumented)
};

declare function aa:assertTrue($msg as xs:string, $pred) {
  if ($pred = true()) then ()
  else (
        <p>{$msg}</p>
  )  
};

declare function aa:squareParensOnlyInCond($r as element()) {
  let $cond-cases := $r//paren/terminal[@value="cond"]/parent::paren/paren
let $square-parens := $r//paren[@type="square"]
let $violations := for $square-paren in $square-parens
       return if (empty(aa:index-of-node($cond-cases,$square-paren))) then ($square-paren) else ()
  return empty($violations)
};

aa:assertPresent("Es ist nicht das korrekte Sprachniveau ('beginner') eingestellt oder Teachpacks fehlen ('universe', 'image').",
  aa:studentLanguage("beginner", ('"image.rkt"'), /drracket)),

aa:assertPresent("Die Funktion max3 mit drei Parametern ist nicht definiert.",
  aa:funDecl("max3", 3, true(), /drracket)),

aa:assertPresent("Es sind keine Tests für die Function max3 definiert.",
  aa:precedingTests(aa:funDecl("max3", 3, true(), /drracket))),

aa:assertPresent("Es ist kein Kommentar für die Funktion max3 angegeben",
  aa:functionComment(aa:funDecl("max3", 3, true(), /drracket))),

aa:assertPresent("Die Funktion max3 enthält keinen geschachtelten if-Ausdruck.",
  aa:findFirstCall("if",aa:findFirstCall("if", aa:funBody(aa:funDecl("max3", 3, true(), /drracket)), true()), false())),

aa:assertTrue("Für die Funktion max3 ist die Signatur nicht oder nicht korrekt dokumnentiert.",
  aa:funDocMatchesSignature(aa:funDecl("max3", 3, true(), /drracket),
("Number", "Number", "Number"), "Number")),

aa:assertTrue("Die Dokumentation für die Funktion max3 enthält keine Beschreibung für alle parameter.",
  aa:funDocContainsParams(aa:funDecl("max3", 3, true(), /drracket))),
  
aa:assertTrue("Eckige Klammern sind nur für die Fälle von cond-Ausdrücken erlaubt",
  aa:squareParensOnlyInCond(/drracket))