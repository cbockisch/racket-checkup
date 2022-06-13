module namespace aa='https://plt.bitbucket.io/autoassess';

declare function aa:assertPresent($msg as xs:string, $e as node()*) {
  if (fn:empty($e)) then (
    <p>{$msg}</p>
  )
  else ()  
};

declare function aa:assertNotPresent($msg as xs:string, $e as node()*) {
  if (fn:empty($e)) then ( )
  else (
      <p>{$msg}</p>
  )  
};

declare function aa:value-intersect( $arg1 as xs:anyAtomicType*, $arg2 as xs:anyAtomicType* ) as xs:anyAtomicType* {
  distinct-values($arg1[.=$arg2])
 } ;
 
declare function aa:studentLanguage($level as xs:string, $reqTeachpacks as xs:string*, $r as element()) {
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
declare function aa:funDecl($name as xs:string, $args as xs:integer, $onlyTopLevel as xs:boolean, $r as element()*) {
  
  let $functionNameDeclaration := 
    if ($onlyTopLevel)
    then ($r/paren/terminal[@value="define"]/following-sibling::paren/terminal[@value=$name])
    else ($r//paren/terminal[@value="define"]/following-sibling::paren/terminal[@value=$name])
  
  for $decl in $functionNameDeclaration
    where (count($decl/following-sibling::terminal) = $args)
    return $decl/parent::node()/parent::node()
};

declare function aa:funComment($funDecl as element()*) {
  $funDecl/preceding-sibling::*[1][self::comment]
};

declare function aa:funBody($funDecl as element()*) {
  $funDecl/paren[1]/following-sibling::*[not(self::comment)][1]
};

declare function aa:funCall($name as xs:string, $args as xs:integer, $r as element()*) {
  let $calls := $r//paren/terminal[@value=$name]

  for $call in $calls
    where (count($call/following-sibling::*[not(self::comment)]) = $args)
    return $call/parent::node()
};

