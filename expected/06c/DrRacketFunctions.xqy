module namespace aa='https://plt.bitbucket.io/autoassess';


declare function aa:assertPresent($msg as xs:string, $e as node()*)
{
  if (fn:empty($e)) then (
    <p>{$msg}</p>
  )
  else ()  
};


declare function aa:assertNotPresent($msg as xs:string, $e as node()*)
{
  if (fn:empty($e)) then ( )
  else (
      <p>{$msg}</p>
  )  
};


declare function aa:value-intersect( $arg1 as xs:anyAtomicType*, $arg2 as xs:anyAtomicType* ) as xs:anyAtomicType*
{
  distinct-values($arg1[.=$arg2])
};
 

declare function aa:studentLanguage($level as xs:string, $reqTeachpacks as xs:string*, $r as element())
{
  let $reader := $r/conf[@lang="#reader"]
  let $lib := $reader/following-sibling::paren[1]/terminal[@value=concat('"htdp-', $level, '-reader.ss"')]
  let $teachpacks := $lib/parent::node()/parent::node()/paren[2]//terminal[@value='teachpacks']/parent::node()
  let $teachpacksSeq := aa:value-intersect($teachpacks/paren/paren/terminal[2]/attribute::value/string(), $reqTeachpacks)
  let $teachpacksOrdered := for $item in $teachpacksSeq
     order by $item
     return $item
  let $reqTeachpacksOrdered := for $item in $reqTeachpacks
     order by $item
     return $item
  return if (deep-equal($teachpacksOrdered, $reqTeachpacksOrdered)) then (
    $reader
  )
  else ()
};


declare function aa:funDecl($name as xs:string, $args as xs:integer, $onlyTopLevel as xs:boolean, $r as element()*)
{
  let $functionNameDeclaration := 
    if ($onlyTopLevel)
    then ($r/paren/terminal[@value="define"]/following-sibling::paren/terminal[@value=$name])
    else ($r//paren/terminal[@value="define"]/following-sibling::paren/terminal[@value=$name])
  
  for $decl in $functionNameDeclaration
    where (count($decl/following-sibling::terminal) = $args)
    return $decl/parent::node()/parent::node()
};


declare function aa:funComment($funDecl as element()*)
{
  $funDecl/preceding-sibling::*[1][self::comment]
};


declare function aa:funBody($funDecl as element()*)
{
  $funDecl/paren[1]/following-sibling::*[not(self::comment)][1]
};

declare function aa:funCall($name as xs:string, $args as xs:integer, $r as element()*)
{
  let $calls := $r//paren/terminal[@value=$name]

  for $call in $calls
    where (count($call/following-sibling::*[not(self::comment)]) = $args)
    return $call/parent::node()
};

declare function aa:index-of-node($nodes as node()*, $nodeToFind as node())  as xs:integer*
{
  for $seq in (1 to count($nodes))
  return $seq[$nodes[$seq] is $nodeToFind]
};
 
 
declare function aa:precedingTests($progElemem as element()*) as element()*
{
  let $test := $progElemem/preceding-sibling::*[1][self::paren]/terminal[starts-with(@value,"check-")]/parent::element()
  return if (fn:empty($test)) then ()
    else 
    ((aa:precedingTests($test), $test))
};


declare function aa:functionComment($funDecl) as element()*
{
  let $tests := aa:precedingTests($funDecl)
  let $comment := if (fn:empty($tests)) 
    then
      ($funDecl/preceding-sibling::*[1][self::comment])
    else
      (fn:head($tests)/preceding-sibling::*[1][self::comment])
  return $comment
};


declare function aa:findFirstCall($name as xs:string, $progElem as element(), $includeSelf)
{
  let $temp :=
    if ($includeSelf)
    then
      (($progElem/descendant-or-self::paren/terminal[@value=$name])[1])
    else
      (($progElem/descendant::paren/terminal[@value=$name])[1])

  return $temp/parent::paren
};


declare function aa:funDocMatchesSignature($funDecl as element()*, $parameterTypes as xs:string*, $returnType as xs:string) as xs:boolean
{
  matches(aa:functionComment($funDecl)/text(),
    concat(".*;\s*", string-join($parameterTypes, "\s*"), "\s*->\s*", $returnType, ".*"), "si")
};

declare function aa:funDocMatchesSignature2($funDecl as element()*, $typeParam as xs:string, $parameterTypes as xs:string*, $returnType as xs:string) as xs:boolean
{
  matches(aa:functionComment($funDecl)/text(),
    concat(".*;\s*", $typeParam, "\s*", string-join($parameterTypes, "\s*"), "\s*->\s*", $returnType, ".*"), "si")
};

declare function aa:funDocContainsParam($funDecl as element()*, $param as xs:string)
{
  matches(aa:functionComment($funDecl)/text(),
    concat("(^|[^\w*])", $param, "([^\w*]|$)"))
};


declare function aa:funDocContainsParams($funDecl as element()*)
{
  let $undocumented :=
    for $param in $funDecl/paren[1]/terminal[1]/following-sibling::terminal/@value
    where not(aa:funDocContainsParam($funDecl, data($param)))
    return $param
  return empty($undocumented)
};


declare function aa:assertTrue($msg as xs:string, $pred)
{
  if ($pred = true())
    then ()
    else (<p>{$msg}</p>)  
};


declare function aa:squareParensOnlyInCond($r as element())
{
  let $cond-cases := $r//paren/terminal[@value="cond"]/parent::paren/paren
  let $square-parens := $r//paren[@type="square"]
  let $violations :=
    for $square-paren in $square-parens
      return
        if (empty(aa:index-of-node($cond-cases,$square-paren))) 
          then ($square-paren) 
          else ()
  return empty($violations)
};


declare function aa:condCasesSquare($r as element())
{
 let $cond-cases := $r//paren/terminal[@value="cond"]/parent::paren/paren
 return
   if (not(empty($cond-cases[@type="round"])))
     then false()
     else true()
};


declare function aa:enumTypeComment($r as node(), $typename as xs:string, $elements as xs:string*)
{
  for $comment in ($r//comment/text())
    where 
      matches($comment, concat(".*", $typename, ".*"))
        and count($elements) = count(
          for $keyword in $elements
            where matches($comment, concat('.*;\s*-\s*', $keyword, '.*'))
            return $keyword)
  return $comment
};


declare function aa:enumTypeTests($funDecl as element()*, $elements as xs:string*)
{
  let $tests := aa:precedingTests($funDecl)
  return count($tests) >= count($elements)
    and count($elements) = count(
      for $element in $elements
        where $tests//terminal[@value=$element]
        return $element)
};


declare function aa:intervalTypeComment($r as node(), $typename as xs:string, $numOfIntervals, $constants as xs:string*)
{
  for $comment in ($r//comment[contains(text(), $typename)])
    let $cases := tokenize($comment, ".*;\s*-\s*")
    return (count($cases) >= $numOfIntervals + 1)
           and
           count(for $const in $constants
              where contains($comment, $const)
              return $const) = count($constants)
};


declare function aa:intervalTypeTests($funDecl as element()*, $numOfTests, $constants as xs:string*)
{
  let $tests := aa:precedingTests($funDecl)
  return count($tests) >= $numOfTests
    and count($constants) = count(
      for $const in $constants
        where $tests//terminal[@value=$const]
        return $const) 
};


declare function aa:sumTypeComment($r as node(), $typename as xs:string, $numOfIntervals, $constants as xs:string*)
{
  for $comment in ($r//comment[contains(text(), $typename)])
    let $cases := tokenize($comment, ".*;\s*-\s*")
    return (count($cases) >= $numOfIntervals + 1)
           and count($constants) = count(
             for $const in $constants
               where contains($comment, $const)
               return $const)
};
