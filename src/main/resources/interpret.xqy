

(:
-Unnötige Zeilen entfernen
-vielleicht irgendwann, je nach Anforderung auf Sprachniveau überprüfen
:)
declare function local:interpretDrracket($drracket as node()*) {
    <drracket>
        {local:checkFinished($drracket/node()[attribute::line>3])}
    </drracket>
};


(:
überprüft ob node ein terminal ist
:)
declare function local:checkFinished($var){

 if (fn:name($var) = "terminal") then (
              <terminal>
                {$var/@value}
              </terminal>
                  )
             else(
                local:nestedFunction($var)
             )
};


(:
findet auswertbare kinder von "paren" einträgen
rekursiv werden diese an dispatch übergeben
:)
declare function local:nestedFunction($var){

    if (local:isSequenzTerminal($var/child::*, count($var/child::*)))then(
        local:dispatch($var/child::*)
    )
    else(
        local:checkFinished(<paren>
            {insert-before(remove($var/child::*, local:findFirstParen($var/child::*,1)),
             local:findFirstParen($var/child::*,1),
             local:nestedFunction($var/child::*[local:findFirstParen($var/child::*,1)]))}
                </paren>
                )
    )
};


(:
Überprüft ob eine Sequenz nur aus terminalen besteht
:)
declare function local:isSequenzTerminal($seq, $counter){
    if($counter = 1) then(
        name($seq[$counter]) = "terminal"
    )
    else(
        name($seq[$counter]) = "terminal" and local:isSequenzTerminal($seq, $counter - 1)
    )
};


(:
findet das erste "paren" in einer Sequenz
:)
declare function local:findFirstParen($var, $counter as xs:integer)
as xs:integer{
    if($counter = (count($var) + 1)) then (-1)
    else (
        if(name($var[$counter])="paren") then(
            $counter
        )
        else(
            local:findFirstParen($var, $counter + 1)
        )
    )
};


(:
 -verteilt auf weitere Funktionen
 -bisher nur Grundrechenarten
 :)
declare function local:dispatch($var){


    if($var/@value = "+")then(
        local:interpretPlus($var/following-sibling::terminal/@value)
    )
    else(
    if($var/@value = "-")then(
        local:interpretMinus($var/following-sibling::terminal/@value)
    )
    else(
    if($var/@value = "*")then(
        local:interpretMultiplikation($var/following-sibling::terminal/@value)
    )
    else(
    if($var/@value = "/")then(
        local:interpretDivision($var/following-sibling::terminal/@value)
    )
    else(
    if($var/@value = "<")then(
        local:interpretSmaller($var/following-sibling::terminal/@value)
    )
    else(
    if($var/@value = ">")then(
        local:interpretBigger($var/following-sibling::terminal/@value)
    )
    else(
    if($var/@value = "=")then(
        local:interpretEqual($var/following-sibling::terminal/@value)
    )
    else(
    if($var/@value = "if")then(
        local:interpretIf($var)
    )
    else(
        $var
    )
    )
    )
    )
    )
    )
    )
    )
};














declare function local:interpretSmaller($var){
    <terminal value="{number($var[1]) < number($var[2])}"></terminal>
};

declare function local:interpretBigger($var){
    <terminal value="{number($var[1]) > number($var[2])}"></terminal>
};

declare function local:interpretEqual($var){
    <terminal value="{number($var[1]) = number($var[2])}"></terminal>
};


(:

:)
declare function local:interpretIf($var){

    if($var[2]/@value = "true") then(
        $var[3])
    else(
        $var[4]
    )
};


(:
  + wird interpretiert
:)
declare function local:interpretPlus($var){

       local:plus($var, count($var), 0)
};

declare function local:plus($seq, $count, $res){

    if($count = 0) then (
    <terminal value="{$res}"></terminal>
    )
    else local:plus($seq, $count - 1, $res + number($seq[$count]))
};


(:
  - wird interpretiert
:)
declare function local:interpretMinus($var){

       local:minus($var, count($var), $var[1])
};

declare function local:minus($seq, $count, $res){

    if($count = 1) then (
    <terminal value="{$res}"></terminal>
    )
    else local:minus($seq, $count - 1, $res - number($seq[$count]))
};



(:
  / wird interpretiert
:)
declare function local:interpretDivision($var){

       local:division($var, count($var), $var[1])
};

declare function local:division($seq, $count, $res){

    if($count = 1) then (
    <terminal value="{$res}"></terminal>
    )
    else local:division($seq, $count - 1, $res / number($seq[$count]))
};


(:
  * wird interpretiert
:)
declare function local:interpretMultiplikation($var){

       local:multiplikation($var, count($var), 1)
};

declare function local:multiplikation($seq, $count, $res){

    if($count = 0) then (
    <terminal value="{$res}"></terminal>
    )
    else local:multiplikation($seq, $count - 1, $res * number($seq[$count]))
};



declare variable $d := local:interpretDrracket(./drracket);


$d