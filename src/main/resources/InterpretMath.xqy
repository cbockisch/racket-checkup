xquery version "3.0";

(:~
: User: Nick
: Date: 17.06.2022
: Time: 14:05
: To change this template use File | Settings | File Templates.
:)

module namespace mathe = "https://plt.bitbucket.io/autoassess";


(:
  + wird interpretiert
:)
declare function mathe:interpretPlus($var){

    mathe:plus($var, count($var), 0)
};

declare function mathe:plus($seq, $count, $res){

    if ($count = 0) then (
        <terminal value="{$res}"></terminal>
    )
    else mathe:plus($seq, $count - 1, $res + number($seq[$count]))
};


(:
  - wird interpretiert
:)
declare function mathe:interpretMinus($var){

    mathe:minus($var, count($var), $var[1])
};

declare function mathe:minus($seq, $count, $res){

    if ($count = 1) then (
        <terminal value="{$res}"></terminal>
    )
    else mathe:minus($seq, $count - 1, $res - number($seq[$count]))
};


(:
  / wird interpretiert
:)
declare function mathe:interpretDivision($var){

    mathe:division($var, count($var), $var[1])
};

declare function mathe:division($seq, $count, $res){

    if ($count = 1) then (
        <terminal value="{$res}"></terminal>
    )
    else mathe:division($seq, $count - 1, $res / number($seq[$count]))
};


(:
  * wird interpretiert
:)
declare function mathe:interpretMultiplikation($var){

    mathe:multiplikation($var, count($var), 1)
};

declare function mathe:multiplikation($seq, $count, $res){

    if ($count = 0) then (
        <terminal value="{$res}"></terminal>
    )
    else mathe:multiplikation($seq, $count - 1, $res * number($seq[$count]))
};


(:
< wird interpretiert
:)
declare function mathe:interpretSmaller($var){
    <terminal value="{number($var[1]) < number($var[2])}"></terminal>
};


(:
> wird interpretiert
:)
declare function mathe:interpretBigger($var){
    <terminal value="{number($var[1]) > number($var[2])}"></terminal>
};


(:
= wird interpretiert
:)
declare function mathe:interpretEqual($var){
    <terminal value="{number($var[1]) = number($var[2])}"></terminal>
};



