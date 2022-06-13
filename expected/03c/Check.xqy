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

declare variable $funDecl :=  aa:funDecl("romeOrNumber->String", 1, true(), /drracket);

aa:assertPresent("Es ist nicht das korrekte Sprachniveau ('beginner') eingestellt oder Teachpacks fehlen ('universe', 'image').",
  aa:studentLanguage("beginner", ('"image.rkt"', '"universe.rkt"'), /drracket)),

aa:assertPresent("Die Funktion romeOrNumber->String mit einem Parameter ist nicht definiert.",
  $funDecl),

aa:assertPresent("Es sind keine Tests für die Function romeOrNumber->String definiert.",
  aa:precedingTests($funDecl)),

aa:assertPresent("Es ist kein Kommentar für die Funktion romeOrNumber->String angegeben",
  aa:functionComment($funDecl)),

aa:assertTrue("Für die Funktion romeOrNumber->String ist die Signatur nicht oder nicht korrekt dokumentiert.",
  aa:funDocMatchesSignature($funDecl,
("RomeOrArabic"), "String")),

aa:assertTrue("Die Dokumentation für die Funktion romeOrNumber->String enthält keine Beschreibung für alle parameter.",
  aa:funDocContainsParams($funDecl)),
  
aa:assertTrue("Eckige Klammern sind nur für die Fälle von cond-Ausdrücken erlaubt.",
  aa:squareParensOnlyInCond(/drracket)),
  
aa:assertTrue("Geben Sie Fälle von cond-Ausdrücken in eckigen Klammern an", aa:condCasesSquare(/drracket)),
 
aa:assertTrue("Der Datentyp Besucher ist nicht korrekt als Kommentar definiert. Zählen Sie als Strichliste alle möglichen Typen auf, ein Fall pro Zeile.", aa:intervalTypeComment(/drracket, "RomeOrArabic", 2, ("Number", "String"))),

aa:assertTrue("Die Tests decken nicht alle Fälle ab. Sie benötigen für jeden möglichen Typ des Arguments einen Test.", count(aa:precedingTests($funDecl)) = 2),

aa:assertTrue("Verwenden Sie in der Implementierung von romeOrNumber->String einen passenden Typ-Test.", not(empty($funDecl//terminal[@value="number?"]) and empty($funDecl//terminal[@value="string?"])))