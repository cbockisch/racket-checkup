import module namespace mathe = 'https://plt.bitbucket.io/autoassess' at 'src/main/resources/InterpretMath.xqy';


declare variable $allDefines := ./drracket/*[attribute::line > 3]/*[attribute::value = "define"]/parent::*;

declare variable $allOuterParens := ./drracket/*[attribute::line > 3];

declare variable $allConstants := for $x in $allDefines[..]/*[2]/self::*
where name($x) = "terminal"
return $x/parent::*;

declare variable $allFunctions := for $x in $allDefines[..]/*[2]/self::*
where name($x) = "paren"
return $x/parent::*;

(:
TODO

nach einander funktionen/constanten einführen

keine Namen mehrfach vergeben

local/lambda

globale variablen verändern?
Wenn vereinfachende Annahmen -> notizen, sonderlösung finden

:)

(:
-Unnötige Zeilen entfernen
-vielleicht irgendwann, je nach Anforderung auf Sprachniveau überprüfen
:)
declare function local:interpretDrracket($drracket as node()*) {
    <drracket>
        {local:checkFinished($drracket)}
    </drracket>
};


(:
überprüft ob es mehrere äußere Klammern in $var gibt
:)
declare function local:checkFinished($var){

    if (count($var) > 1) then (
        local:checkIsTerminal(local:removeDefine($var, 1))
    )
    else (
        local:checkIsTerminal($var)
    )
};


(:
überprüft ob node ein terminal ist
:)
declare function local:checkIsTerminal($var){

    if (fn:name($var) = "terminal") then (
        <terminal>
            {$var/@value}
        </terminal>
    )
    else (
        local:nestedFunction($var)
    )
};

(:
entfernt rekursiv alle Konstanten und Funktionen aus dem Programm

TODO
- Hierbei sollten lokale Definitionen ausgenommen werden
- Sollte nacheinander eingefügt werden
    (Prüfen ob Funktion/Konstante andere Funktion/Konstante nutzen darf
:)
declare function local:removeDefine($original, $counter){

    if ($counter > count($allDefines)) then (
        $original
    )
    else (
        if ($original[1]/child::*[1]/@value = "define") then (
            local:removeDefine(remove($original, 1), $counter + 1)
        )
        else (
            local:removeDefine($original, $counter + 1)
        )
    )
};


(:
-findet auswertbare kinder von "paren" einträgen
rekursiv werden diese an dispatch übergeben

-findet außerdem Funktionen und Konstanten
übergibt diese an Funktionen in denen sie ersetzt werden
:)
declare function local:nestedFunction($var){

    if (local:isSeqFunction($var/child::*, 1)) then (
        local:nestedFunction(
                local:replaceFunction($var/child::*, 1))
    )
    else (
        if (local:isInSequenzConstant($var/child::*, 1, 1)) then (
            local:nestedFunction(
                    local:replaceConstant($var/child::*, 1, 1))
        )
        else (
            if (local:isSequenzTerminal($var/child::*, count($var/child::*))) then (
                local:dispatch($var/child::*)
            )
            else (
                local:checkFinished(<paren>
                    {insert-before(remove($var/child::*, local:findFirstParen($var/child::*, 1)),
                            local:findFirstParen($var/child::*, 1),
                            local:nestedFunction($var/child::*[local:findFirstParen($var/child::*, 1)]))}
                </paren>
                )
            )
        )
    )
};


(:
Überprüft ob eine Sequenz eine Selbstdefinierte Funktion ist
:)
declare function local:isSeqFunction($seq, $counterFunc){
    if ($counterFunc > count($allFunctions)) then (
        false()
    )
    else (
        if ($seq[1]/@value = $allFunctions[$counterFunc]/child::*[2]/child::*[1]/@value) then (
            true()
        )
        else (
            false() or local:isSeqFunction($seq, $counterFunc + 1)
        )
    )
};

(:
Überprüft ob in einer Sequenz eine Konstante enthalten ist
:)
declare function local:isInSequenzConstant($var, $counterSequenz, $counterDefine){

    if ($counterSequenz > count($var)) then (
        false()
    )
    else (
        if ($counterDefine > count($allDefines)) then (
            false() or local:isInSequenzConstant($var, $counterSequenz + 1, 1)
        )
        else (
            if ($var[$counterSequenz]/@value = $allDefines[$counterDefine]/child::*[2]/@value) then (
                true()
            )
            else (
                false() or local:isInSequenzConstant($var, $counterSequenz, $counterDefine + 1)
            )
        )
    )
};


(:
Ersetzt einen Funktionsnamen durch den Funktionsbody
:)
declare function local:replaceFunction($seq, $counterFunc){

    if ($counterFunc > count($allFunctions)) then (
        $seq
    )
    else (
        if ($seq[1]/@value = $allFunctions[$counterFunc]/child::*[2]/child::*[1]/@value) then (

            local:replaceVarInFunction(insert-before(remove($seq, 1), 1,
                    $allFunctions[$counterFunc]/child::*[3]), 2,
                    $allFunctions[$counterFunc]/child::*[2]/child::*)
        )
        else (
            local:replaceFunction($seq, $counterFunc + 1)
        )
    )
};


(:
Ersetzt rekursiv alle Variablen im Funktionskopf mit konkreten Werten
:)
declare function local:replaceVarInFunction($seq, $counterV, $fHead){

    if ($counterV > count($fHead)) then (
        local:removeVars($seq, count($seq)))
    else (

        local:replaceVarInFunction(insert-before(remove($seq, 1), 1,
                local:replaceThisVar($seq[1]/child::*, $fHead[$counterV], 1, $seq[$counterV])), $counterV + 1, $fHead)
    )
};


(:
Ersetzt eine Variable im Funktionsbody, Der Funktionsbody wird dabei baumartig durchlaufen
:)
declare function local:replaceThisVar($seq, $replaced, $counterSeq, $toReplace){

    if ($seq[$counterSeq]/@value = $replaced/@value) then (
        local:replaceThisVar(insert-before(remove($seq, $counterSeq), $counterSeq, $toReplace), $replaced,
                $counterSeq + 1, $toReplace)
    )
    else (
        if (name($seq[$counterSeq]) = "paren") then (
            local:replaceThisVar(insert-before(remove($seq, $counterSeq), $counterSeq,
                    local:replaceThisVar($seq[$counterSeq]/child::*, $replaced, 1, $toReplace))
                    , $replaced, $counterSeq + 1, $toReplace)
        )
        else (
            if ($counterSeq > count($seq)) then (
                <paren>{$seq}</paren>
            )
            else (
                local:replaceThisVar($seq, $replaced, $counterSeq + 1, $toReplace)
            )
        )
    )
};


(:
Enfernt die Variablen aus der Sequenz in welcher der Funktionsbody eingesetzt wurde
und die Variablen in diesen Body eingesetzt wurden
:)
declare function local:removeVars($seq, $counter){

    if ($counter = 1) then (
        $seq
    )
    else (
        local:removeVars(remove($seq, $counter), $counter - 1)
    )
};


(:
findet Konstanten in einer Sequenz und ersetzt diese
:)
declare function local:replaceConstant($seq, $counterSequenz, $counterConst){

    if ($seq[$counterSequenz]/@value = $allConstants[$counterConst]/child::*[2]/@value) then (
        <paren>
            {insert-before(remove($seq, $counterSequenz), $counterSequenz, $allConstants[$counterConst]/child::*[3])}
        </paren>
    )
    else (
        if (count($allConstants) < $counterConst) then (
            local:replaceConstant($seq, $counterSequenz + 1, 1)
        )
        else (
            local:replaceConstant($seq, $counterSequenz, $counterConst + 1)
        )
    )
};


(:
Überprüft ob eine Sequenz nur aus Terminalen besteht
:)
declare function local:isSequenzTerminal($seq, $counter){
    if ($counter = 1) then (
        name($seq[$counter]) = "terminal"
    )
    else (
        name($seq[$counter]) = "terminal" and local:isSequenzTerminal($seq, $counter - 1)
    )
};


(:
findet das erste "paren" in einer Sequenz
:)
declare function local:findFirstParen($var, $counter as xs:integer)
as xs:integer{
    if ($counter = (count($var) + 1)) then (-1)
    else (
        if (name($var[$counter]) = "paren") then (
            $counter
        )
        else (
            local:findFirstParen($var, $counter + 1)
        )
    )
};


(:
Verteilt vorimplementierte Funktionen auf eigentliche Funktionen
:)
declare function local:dispatch($var){

    if ($var/@value = "+") then (
        mathe:interpretPlus($var/following-sibling::terminal/@value)
    )
    else (
        if ($var/@value = "-") then (
            mathe:interpretMinus($var/following-sibling::terminal/@value)
        )
        else (
            if ($var/@value = "*") then (
                mathe:interpretMultiplikation($var/following-sibling::terminal/@value)
            )
            else (
                if ($var/@value = "/") then (
                    mathe:interpretDivision($var/following-sibling::terminal/@value)
                )
                else (
                    if ($var/@value = "<") then (
                        mathe:interpretSmaller($var/following-sibling::terminal/@value)
                    )
                    else (
                        if ($var/@value = ">") then (
                            mathe:interpretBigger($var/following-sibling::terminal/@value)
                        )
                        else (
                            if ($var/@value = "=") then (
                                mathe:interpretEqual($var/following-sibling::terminal/@value)
                            )
                            else (
                                if ($var/@value = "if") then (
                                    local:interpretIf($var)
                                )
                                else (
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


(:
If wird interpretiert
:)
declare function local:interpretIf($var){

    if ($var[2]/@value = "true") then (
        $var[3])
    else (
        $var[4]
    )
};


declare variable $d := local:interpretDrracket($allOuterParens);


$d


(:

Interpreter Artikel über ansatz

Small step semantic

:)