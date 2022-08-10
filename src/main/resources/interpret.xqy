import module namespace mathe = 'https://plt.bitbucket.io/autoassess' at 'src/main/resources/InterpretMath.xqy';


declare variable $allDefines := ./drracket/*[attribute::line > 3]/*[attribute::value = "define"]/parent::*;

declare variable $allOuterParens := ./drracket/*[attribute::line > 3];

declare variable $allConstants := for $x in $allDefines[..]/*[2]/self::*
where name($x) = "terminal"
return $x/parent::*;

declare variable $allFunctions := for $x in $allDefines[..]/*[2]/self::*
where name($x) = "paren"
return $x/parent::*;

declare variable $allStructs := (<paren line="4" type="round">
    <terminal line="4" type="Name" value="define-struct"/>
    <terminal line="4" type="Name" value="posn"/>
    <paren line="4" type="round">
        <terminal line="4" type="Name" value="x"/>
        <terminal line="4" type="Name" value="y"/>
    </paren>
</paren>, ./drracket/*[attribute::line > 3]/*[attribute::value = "define-struct"]/parent::*);
(:
TODO

-structs !!

Wenn vereinfachende Annahmen -> notizen, sonderlösung finden

Notizen zu Problemen

Bugreport:
Single Constants does not work
wenn man seine Variablen bennent wie Funktionen welche erst weiter unten definiert sind, dann wird ein Fehler erzeugt
Funktionen bevor sie definiert wurden anpassen

:)


(:
-Unnötige Zeilen entfernen
-vielleicht irgendwann, je nach Anforderung auf Sprachniveau überprüfen
:)
declare function local:interpretDrracket($drracket as node()*) {

    if (not(local:checkIfNamesUnique(1, 2))) then (
        "sry leider doppelt benannte Funktionen/Konstanten"
    )
    else (
    (:    if (local:checkIfUsedEarly(1, 2)) then (
            "sry leider wurden irgendwo Funktionen benutzt bevor sie definiert wurden"
        )
        else ( :)
    <drracket>
        {local:checkFinished($drracket)}
    </drracket>
    )
};


(:
- Überprüft ob alle Namen der Funktionen/Konstanten unikate sind
:)
declare function local:checkIfNamesUnique($counterAll, $counterPer){

    if ($allDefines[$counterAll]/child::*[2]/@value = $allDefines[$counterPer]/child::*[2]/@value or
            $allDefines[$counterAll]/child::*[2]/@value = $allDefines[$counterPer]/child::*[2]/child::*[1]/@value or
            $allDefines[$counterAll]/child::*[2]/child::*[1]/@value = $allDefines[$counterPer]/child::*[2]/@value or
            $allDefines[$counterAll]/child::*[2]/child::*[1]/@value = $allDefines[$counterPer]/child::*[2]/child::*[1]/@value)
    then (
        false()
    )
    else (
        if ($counterAll > count($allDefines)) then (
            true()
        )
        else (
            if ($counterPer > count($allDefines)) then (
                local:checkIfNamesUnique($counterAll + 1, $counterAll + 2)
            )
            else (
                local:checkIfNamesUnique($counterAll, $counterPer + 1)
            )
        )
    )
};

(:
(:
- Überprüft ob Funktionen nur Funktionen aufrufen, welche bereits definiert wurden
:)
declare function local:checkIfUsedEarly($counterAll, $counterPer){

    if ($counterAll > count($allDefines)) then (
        false()
    )
    else (
        if ($counterPer > count($allDefines)) then (
            false() or local:checkIfUsedEarly($counterAll + 1, $counterAll + 2)
        )
        else (
            if (name($allDefines[$counterPer]/child::*[2]) = "terminal") then (
                local:containsThis($allDefines[$counterAll], $allDefines[$counterPer]/child::*[2]/@value)
                        or local:checkIfUsedEarly($counterAll, $counterPer + 1)
            )
            else (
                local:containsThis($allDefines[$counterAll],
                        $allDefines[$counterPer]/child::*[2]/child::*[1]/@value)
                        or local:checkIfUsedEarly($counterAll, $counterPer + 1)
            )
        )
    )
};
:)

(:
gibt an ob ein bestimmtes Value irgendwo in einer Sequenz auftaucht
:)
declare function local:containsThis($seq, $value){
    $seq/descendant-or-self::*/@value = $value
};


(:
überprüft ob es mehrere äußere Klammern in $seq gibt
:)
declare function local:checkFinished($seq){

    if (count($seq) > 1) then (
        local:checkIsTerminal(local:removeDefine($seq, 1))
    )
    else (
        local:checkIsTerminal($seq)
    )
};


(:
überprüft ob node ein terminal ist
:)
declare function local:checkIsTerminal($seq){

    if (fn:name($seq) = "terminal") then (
        <terminal>
            {$seq/@value}
        </terminal>
    )
    else (
        local:nestedFunction($seq)
    )
};

(:
entfernt rekursiv alle Konstanten und Funktionen aus dem Programm

TODO
- Hierbei sollten lokale Definitionen ausgenommen werden
:)
declare function local:removeDefine($seq, $counter){

    if ($counter > count($allDefines) + count($allStructs) - 1) then (
        $seq
    )
    else (
        if ($seq[1]/child::*[1]/@value = "define" or
                $seq[1]/child::*[1]/@value = "define-struct") then (
            local:removeDefine(remove($seq, 1), $counter + 1)
        )
        else (
            local:removeDefine($seq, $counter + 1)
        )
    )
};


(:
-findet auswertbare kinder von "paren" einträgen
rekursiv werden diese an dispatch übergeben

-findet außerdem Funktionen und Konstanten
übergibt diese an Funktionen in denen sie ersetzt werden
:)
declare function local:nestedFunction($seq){

    if (local:isSeqIf($seq/child::*)) then (
        local:checkFinished(local:interpretIf($seq/child::*))
    )
    else (
        if (local:isSeqCond($seq/child::*)) then (
            local:nestedFunction(
                    local:replaceCondWithIf($seq/child::*, 2))
        )
        else (
            if (local:isSeqFunction($seq/child::*, 1)) then (
                local:nestedFunction(local:replaceFunction($seq/child::*, 1))
            )
            else (
                if (local:isInSequenzConstant($seq/child::*, 1, 1)) then (
                    local:nestedFunction(local:replaceConstant($seq/child::*, 1, 1))
                )
                else (
                    if (local:isForDispatch($seq)) then (
                        local:dispatch($seq/child::*)
                    )
                    else (
                        local:checkFinished(<paren>
                            {insert-before(remove($seq/child::*, local:findFirstParen($seq/child::*, 1)),
                                    local:findFirstParen($seq/child::*, 1),
                                    local:nestedFunction($seq/child::*[local:findFirstParen($seq/child::*, 1)]))}
                        </paren>
                        )
                    )
                )
            )
        )
    )
};


declare function local:isForDispatch($seq){

    local:isSequenzTerminal($seq/child::*, count($seq/child::*)) or
            (:
  Sonderfälle in denen überprüft wird ob der ggf. geschachtelte Struct fertig ausgewertet ist
  :)
    local:isStructPredReady($seq/child::*) or

            local:isNestedStruct($seq/child::*)

};


declare function local:isNestedStruct($seq){

    local:isStructSizeRigth($seq) and
            local:terminalOrStruct($seq, 2)

};


declare function local:isStructPredReady($seq){
(:
    hier wird gecheckt ob der Aufruf nach diesem struct korrekt ist
    :)
    count(local:getStruct(substring($seq[1]/@value, 1, string-length($seq[1]/@value) - 1))) = 1
    (:
    hier wird überprüft ob der Rest nur aus terminalen und structs besteht
    :)
            and
            local:terminalOrStruct($seq[2]/child::*, 2)
};


declare function local:terminalOrStruct($seq, $counter){

    if ($counter > count($seq)) then (
        true()
    )
    else (
        if (name($seq[$counter]) = "terminal") then (
            true() and local:terminalOrStruct($seq, $counter + 1)
        )
        else (
            if (name($seq[$counter]) = "paren" and local:isStruct($seq[$counter]/child::*[1], 1)) then (
                true()
                        and
                        local:terminalOrStruct($seq[$counter]/child::*, 2)
                        and
                        local:isStructSizeRigth($seq[$counter]/child::*)
            )
            else (
                false()
            )
        )
    )


};


declare function local:isStruct($var, $counter){

    if ($counter > count($allStructs)) then (
        false()
    )
    else (
        if (concat("make-", $allStructs[$counter]/child::*[2]/@value) = $var[1]/@value) then (
            true()
        )
        else (
            local:isStruct($var, $counter + 1)
        )
    )
};


declare function local:isStructSizeRigth($var){
    ((count(local:getStruct(substring($var[1]/@value, 6))/child::*[3]/child::*) + 1) = count($var))
            and
            count(local:getStruct(substring($var[1]/@value, 6))/child::*[3]/child::*) > 0
};


declare function local:getStruct($structName){
    $allStructs/*[attribute::value = $structName]/parent::*
};


(:


:)
declare function local:replaceCondWithIf($seq, $counter){

    if ($seq[$counter]/child::*[1]/@value = "else" or
            $seq[$counter]/child::*[1]/@value = "true") then (
        $seq[$counter]/child::*[2]
    )
    else (
        if ($counter > count($seq)) then (
            <terminal value="cond: all question results were false"></terminal>
        )
        else (
            <paren>
                <terminal value="if"></terminal>
                {$seq[$counter]/child::*}
                {local:replaceCondWithIf($seq, $counter + 1)}
            </paren>
        )
    )
};


declare function local:isSeqCond($seq){
    $seq[1]/@value = "cond"
};


declare function local:isSeqIf($seq){
    $seq[1]/@value = "if"
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
If wird interpretiert
:)
declare function local:interpretIf($var){

    if (local:checkFinished($var[2])/@value = "true") then (
        $var[3]
    )
    else (
        $var[4]
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
                                if (local:isStruct($var, 1)) then (
                                    local:interpretStruct($var)
                                )
                                else (
                                    if (local:isStructPredReady($var)) then (
                                        substring($var[1]/@value, 1, string-length($var[1]/@value) - 1)
                                                = substring($var[2]/child::*[1]/@value, 6)
                                                and
                                                local:interpretStructPred($var[2]/child::*, 2)
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
    )
};


declare function local:interpretStructPred($var, $counter){

    local:isStructSizeRigth($var)  and
            (
                if($counter > count($var)) then (
                    true()
                )
                else(
                    if(name($var[$counter]) = "paren") then (
                        local:interpretStructPred($var[$counter]/child::*, 2)
                    )
                    else(
                        local:interpretStructPred($var, $counter + 1)
                    )
                )
            )

};


declare function local:interpretStruct($var){
    if ( count(local:getStruct(substring($var[1]/@value, 6))/child::*[3]/child::*) + 1 = count($var)
    and not($var/@value = "not the correct struct Struktur")) then (
        <paren>
            {$var}
        </paren>
    )
    else (
        <terminal value= "not the correct struct Struktur"></terminal>
    )
};


declare variable $d := local:interpretDrracket($allOuterParens);


$d


(:

Interpreter Artikel über ansatz

Small step semantic

:)