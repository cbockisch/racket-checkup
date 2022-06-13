xquery version "1.0";

import module namespace aa='https://plt.bitbucket.io/autoassess' at '../DrRacketFunctions.xqy';

declare function aa:index-of-node
  ( $nodes as node()* ,
    $nodeToFind as node() )  as xs:integer* {

  for $seq in (1 to count($nodes))
  return $seq[$nodes[$seq] is $nodeToFind]
 } ;
 
declare function aa:precedingTests($progElemem as element()*) as element()* {
  let $test := $progElemem/preceding-sibling::*[1][self::paren]/terminal[starts-with(@value,"check-")]/parent::element()
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

declare function aa:findFirstCall($name as xs:string, $progElem as element(), $includeSelf) {
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
    concat(".*;\s*", string-join($parameterTypes, "\s*"), "\s*->\s*", $returnType, ".*"), "s")
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
  if ($pred) then ()
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

declare function aa:condCasesSquare($r as element()) {
   let $cond-cases := $r//paren/terminal[@value="cond"]/parent::paren/paren
   return if (not(empty($cond-cases[@type="round"])))
     then false()
     else true()
};

declare function aa:enumTypeComment($r as node(), $typename as xs:string, $elements as xs:string*) {
  for $comment in ($r//comment/text())
    where 
        matches($comment, concat(".*", $typename, ".*")) and
        count((for $keyword in $elements
          where matches($comment, concat('.*;\s*-\s*', $keyword, '.*'))
          return $keyword)) = count($elements)
  return $comment
};

declare function aa:enumTypeTests($funDecl as element()*, $elements as xs:string*) {
let $tests := aa:precedingTests($funDecl)
return count($tests) >= count($elements) and
       count(for $element in $elements
         where $tests//terminal[@value=$element]
         return $element) = count($elements)
};

declare function aa:intervalTypeComment($r as node(), $typename as xs:string, $numOfIntervals, $constants as xs:string*) {
  for $comment in ($r//comment[contains(text(), $typename)])
    let $cases := tokenize($comment, ".*;\s*-\s*")
    return (count($cases) >= $numOfIntervals + 1)
           and
           count(for $const in $constants
              where contains($comment, $const)
              return $const) = count($constants)
};

declare function aa:intervalTypeTests($funDecl as element()*, $numOfTests, $constants as xs:string*) {
let $tests := aa:precedingTests($funDecl)
return count($tests) >= $numOfTests and
       count(for $const in $constants
         where $tests//terminal[@value=$const]
         return $const) = count($constants)
};

declare function aa:sumTypeComment($r as node(), $typename as xs:string, $numOfIntervals, $constants as xs:string*) {
  for $comment in ($r//comment[contains(text(), $typename)])
    let $cases := tokenize($comment, ".*;\s*-\s*")
    return (count($cases) >= $numOfIntervals + 1)
           and
           count(for $const in $constants
              where contains($comment, $const)
              return $const) = count($constants)
};
declare variable $funDecl :=  aa:funDecl("preis", 1, true(), /drracket);

declare variable $const120 :=
  /drracket//paren/terminal[@value='define']/following-sibling::terminal[2][@value="120"]/preceding-sibling::terminal[1]/attribute::value/string();

declare variable $const140 :=
  /drracket//paren/terminal[@value='define']/following-sibling::terminal[2][@value="140"]/preceding-sibling::terminal[1]/attribute::value/string();
  
declare variable $const160 :=
  /drracket//paren/terminal[@value='define']/following-sibling::terminal[2][@value="160"]/preceding-sibling::terminal[1]/attribute::value/string();

aa:assertPresent("Es ist nicht das korrekte Sprachniveau ('beginner') eingestellt oder Teachpacks fehlen ('universe', 'image').",
  aa:studentLanguage("beginner", ('"image.rkt"', '"universe.rkt"'), /drracket)),

aa:assertPresent("Die Funktion preis mit einem Parameter ist nicht definiert.",
  $funDecl),

aa:assertPresent("Es sind keine Tests für die Function preis definiert.",
  aa:precedingTests($funDecl)),

aa:assertPresent("Es ist kein Kommentar für die Funktion preis angegeben",
  aa:functionComment($funDecl)),

aa:assertTrue("Für die Funktion preis ist die Signatur nicht oder nicht korrekt dokumentiert.",
  aa:funDocMatchesSignature($funDecl,
("Besucher"), "Number")),

aa:assertTrue("Die Dokumentation für die Funktion preis enthält keine Beschreibung für alle parameter.",
  aa:funDocContainsParams($funDecl)),
  
aa:assertTrue("Eckige Klammern sind nur für die Fälle von cond-Ausdrücken erlaubt.",
  aa:squareParensOnlyInCond(/drracket)),
  
aa:assertTrue("Geben Sie Fälle von cond-Ausdrücken in eckigen Klammern an", aa:condCasesSquare(/drracket)),

aa:assertTrue("Definieren Sie eine Konstante für die Grenzwerte (120 und 140).",
  (not(empty($const120) or empty($const140)))),
 
aa:assertTrue("Der Datentyp Besucher ist nicht korrekt als Kommentar definiert. Zählen Sie als Strichliste alle Intervalle auf, ein Fall pro Zeile. Benutzen Sie zuvor definierte Konstanten für die Intervallgrenzen.", aa:intervalTypeComment(/drracket, "Besucher", 3, ($const120, $const140))),

aa:assertTrue("Die Tests decken nicht alle Fälle ab. Sie benötigen für jedes Interval mindestens: einen Test für einen typischen Wert, sowie einen Test pro einschließendem Grenzwert (d.h. Vergleich in der Intervalldefinition mittels &lt;= oder &gt;=). Verwenden Sie zuvor definierte Konstanten für Grenzwerte.", aa:intervalTypeTests($funDecl, 5, ($const120, $const140)))