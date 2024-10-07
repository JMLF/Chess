# Task3 : Rapport d'Analyse Fuzzing FEN paser

Installation du Fuzzer
```smalltalk
Metacello new
  baseline: 'Phuzzer';
  repository: 'github://alamvic/phuzzer:main';
  onConflictUseIncoming;
  load.
```

### Definition de la grammaire :
Pour commencer il nous faut une grammaire qui implemente les règles de la notation [FEN](https://fr.wikipedia.org/wiki/Notation_Forsyth-Edwards).
Definition grammaire [BNF](https://fr.wikipedia.org/wiki/Forme_de_Backus-Naur)
```BNF
FEN ::= PiecePlacement ' ' SideToMove ' ' CastlingAbility ' ' EnPassantTargetSquare ' ' HalfMoveClock ' ' FullMoveNumber

PiecePlacement ::= Rank ('/' Rank){7}
"PiecePlacement représente la configuration des pièces sur l'échiquier, ligne par ligne."
"Il doit y avoir exactement 7 '/' séparant les 8 rangées."

Rank ::= (Piece | Digit){1,8}
"Chaque Rank doit contenir entre 1 et 8 caractères, qui peuvent être des pièces ou des chiffres"

Piece ::= 'P' | 'N' | 'B' | 'R' | 'Q' | 'K' | 'p' | 'n' | 'b' | 'r' | 'q' | 'k'
"Les pièces en majuscules représentent les blancs et en minuscules les noirs."
"Les types de pièces sont pion (P/p), cavalier (N/n), fou (B/b), tour (R/r), reine (Q/q), et roi (K/k)"

Digit ::= '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8'
"Digit représente le nombre de cases vides consécutives dans une rangée."

SideToMove ::= 'w' | 'b'
"SideToMove représente le joueur qui doit jouer le prochain coup : 'w' pour blanc et 'b' pour noir"

CastlingAbility ::= ('K' | 'Q' | 'k' | 'q')* | '-'
"CastlingAbility indique les roques disponibles : 'K' (petit roque blanc), 'Q' (grand roque blanc), 'k' (petit roque noir), 'q' (grand roque noir)."
" '-' lorsque aucun roque n'est possible."

EnPassantTargetSquare ::= File Digit | '-'
"EnPassantTargetSquare indique une cible de prise en passant (par exemple 'e3'), ou '-' si aucune n'est disponible"

HalfMoveClock ::= Digit+
"HalfMoveClock représente le nombre de demi-coups depuis le dernier coup de pion ou la dernière capture"

FullMoveNumber ::= Digit+
"FullMoveNumber représente le nombre total de coups complets depuis le début de la partie"

File ::= 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h'
"File représente les colonnes de l'échiquier, de 'a' à 'h'."
```

### Fuzzing sans grammaire 
Le chess game utilise le FENPaser de MyG-Chess-Importer, nous pouvons donc essayer de lance un jeu avec une string aléatoire :

```smalltalk
board := MyChessGame fromFENString: 'my_random_string'.
board size: 800@600.
space := BlSpace new.
space root addChild: board.
space pulse.
space resizable: true.
space show.
```

Ce n'est evidemment pas très concluant, sur les string basique nous avons le plus souvent `errorKeyNotFound`.
Esayont d'automatiser le tout pour tester un grand nombre de combinaison : 

```smalltalk
fuzzer := PzRandomFuzzer new.
runner := PzBlockRunner on: [:input |
[
    MyChessGame fromFENString: input.
]
    on: Error do: [:ex |           
        Transcript
        show: 'Erreur lors du parsing de FEN: ', input, ' - ', ex messageText; cr.
    ].
].

fuzzer run: runner times: 50.
```

La sortie transcript nous montre bien qu'aucune string aléatoire n'a passé l'étape du parsing

```
Erreur lors du parsing de FEN: (>1   06/++2.1.!/.=: !"<=+ 08:*">&:@!?/23%<+-@+' 590#0.;?@,0<:700994:;#/)7 59<6 23&2$! - key $( not found in DictionaryErreur lors du parsing de FEN:  (0,!)12@9=)?,$:5>+.:6+': - Assertion failedErreur lors du parsing de FEN: .+30&"2  :/"#0!+2(,2>1,8,5>- =.89 +#8 3*4:&4&<#;4;9185%#=-/0+6098@@: - key $. not found in DictionaryErreur lors du parsing de FEN: 4<3&#<,,/), 83*5::)6@8%=-#!80<>119@'=.9# ?!!&1, - key $< not found in DictionaryErreur lors du parsing de FEN: 8(-(!%,+(?076=!24"('?'+/7=@$9!@;,'33"!6$@7*?+ 2 - Assertion failedErreur lors du parsing de FEN: 8>,($,?=,=831<@+9>'=-&1$+44(/51+3+"-.<6>'921-"?-5.@>)!7'1-7 /1;3%#<=6,%5! - Assertion failedErreur lors du parsing de FEN: (/:61:;)4?,9?7($/+"4%/3;3 (#0095=.?8'),56! @9+;28:-41%@2%8,? @3+$.4&+<<4-+4+4: - key $( not found in DictionaryErreur lors du parsing de FEN: #. /8"6"!,%=""%4& ,=2:@?>43%*2$3:(1!,8&;9='49-@ 48<?)2+56?- - key $# not found in DictionaryErreur lors du parsing de FEN: +'32;>&'8"(!,8?:?)3$ - key $+ not found in DictionaryErreur lors du parsing de FEN: &#,)-+=!-?9"&00*9(>&@):%(1=/=;1"'79@3-6,13* - key $& not found in DictionaryErreur lors du parsing de FEN: '$4:=.#0-+!"-+,2881;801:<5>819$0= - key $' not found in DictionaryErreur lors du parsing de FEN: <@)./0-#&29*.;3;2+=!.#3( - key $< not found in DictionaryErreur lors du parsing de FEN: "#-#/+3--(0@'0?3@& )*+5<&<&!9 - key $" not found in DictionaryErreur lors du parsing de FEN: (%*2<9>64@":>1);* 9=-508 -56-=(3(?"$@10..9+:2 - key $( not found in DictionaryErreur lors du parsing de FEN: @&4=*>1$%=1:@<>+=#*'$/9:715%6&2(3,="3 - key $@ not found in DictionaryErreur lors du parsing de FEN: <1?%?;(>"/</@!=,$$<'@:?>35*."1$3">?$".$ / (: 7-+416+66/7%,64#>>)$#!+#<8*>2;.)>*;040 - key $< not found in DictionaryErreur lors du parsing de FEN: <:*%*# 0-).=825?:<?34;;&-,12>96)$@1:!7%;1"8>3+*!@10 9*;4 - key $< not found in DictionaryErreur lors du parsing de FEN: &':+>3+-=51'/$:.0 6,,%=##-6-57"5(5,@!/0 "*%=!$!) %,+ - key $& not found in DictionaryErreur lors du parsing de FEN: (4:"?:+=?24,-!.0"/=;)'6< =0%%5<7);<"&&$(*:;,4,9@"</$&&- - key $( not found in DictionaryErreur lors du parsing de FEN: <4(;$$9:<,&*)$4(#6&0'@3= - key $< not found in DictionaryErreur lors du parsing de FEN: 5;:6=+&"5= -&?11 - key $; not found in DictionaryErreur lors du parsing de FEN: /37&<*20 7"<9657>#"0$5/4?$.3?7+;!'%!*.1;36=80='!05<6#6(1)@3/0'3+:)@2  '36 %,/+;;53(>0)"#)-1@+9 - key $& not found in DictionaryErreur lors du parsing de FEN: 9)@>;=53;+932=5=85-@+&67$0>(?%.((549 - key $) not found in DictionaryErreur lors du parsing de FEN: 7*;<1)3$/*02@..:15:;4;9/>;:53 - key $* not found in DictionaryErreur lors du parsing de FEN: 8<&=+3')#>#$@77%8*(2$5;44 " !=3<9@.!:,8,9,(,4$$# -$! ; =*)1)8(@%!4<.69?)(6*>='9197=:--8&&  - Assertion failedErreur lors du parsing de FEN: 0;797@<:>.77 - key $; not found in DictionaryErreur lors du parsing de FEN: 8@-#"8)=>#.4=4596 890=:"4#42" "<.-6)3,6+@-%26@79&1<;>5+,45):21)!44  @-6$:@;,)8521;01 : - Assertion failedErreur lors du parsing de FEN: ;8<+4$9>>'*+*2>-/> - key $; not found in DictionaryErreur lors du parsing de FEN: 84!+21!?"4&*9%;)50-7+(6'-'1+@)9;%*(6+=/-2(5&>#&@!$)+83),< - Assertion failedErreur lors du parsing de FEN: ;!%=%';03(28' =7801%31)>8$>>0:'=) /@7877-5--2&!4(6/@4./86,'3;@3/8))7,3.=6/ /@@8))7$*-#=<?88%7"@7>5,. - key $; not found in DictionaryErreur lors du parsing de FEN: 4">?$$+;%->.362,1.@7"&;4= - key $" not found in DictionaryErreur lors du parsing de FEN: =$$&< +(!.6"69 (:6,!04,:!6#@;<$#,'49-&@3.9+"$#,>5-#'0180?!8<5;3*88-85'&/ - key $= not found in DictionaryErreur lors du parsing de FEN: @1@(4:31;>@3'0@/>12;&==#$0+>!=42.&.@%"-5,(%79<-),)+"%6,,8/=(0@6.(6$:1&)@0*93;;6@!<28%<2%<@ 77&*8415. - key $@ not found in DictionaryErreur lors du parsing de FEN: =(62<"+@#6)%)==.&)"++!(2;6817>-*/4'4=<8.>))..5'::),- 8 - key $= not found in DictionaryErreur lors du parsing de FEN: $2?2#%2>,.'8,"  - key $$ not found in DictionaryErreur lors du parsing de FEN: @05/00-6?4!+)2-0&$;,9=3,%648)>04 >8+-%6?:)? - key $@ not found in DictionaryErreur lors du parsing de FEN: =-'<-"@8;9=$.>#&>60..+&4>3(:(5&5#'-?-'7)2+58-'8/2 8;0&<>52 - key $= not found in DictionaryErreur lors du parsing de FEN: *<)@#,7&=&'973)93?-@;;7-5'+1'<2>% - key $* not found in DictionaryErreur lors du parsing de FEN: '<=" 8,407$!1!83*:,6<4>/,)%0%&<#&4/57)!30"0&0'18;&*942>?3@4$1,1#(8$>/- 25$&#??!08;#$(!5< - key $' not found in DictionaryErreur lors du parsing de FEN: -?'*1=?<@:;0;#=5#..7*:<% -3*>*#/,%$?9?9-7%0/6+<#%/++>5-+9?:+<',"18,#)9 - key $- not found in DictionaryErreur lors du parsing de FEN: &-,/40,'9-0' - key $& not found in DictionaryErreur lors du parsing de FEN: @7&#%#!64-<5&$,0=,1&/%@7@'"166::9;#,/.>3"1=!$41@"?30 - key $@ not found in DictionaryErreur lors du parsing de FEN: 163!.(3:=9>0#*078'%.&2:6( #*/ 2/%=+663,11$?=<8#7+#6<?*/=$$!2?@5.>2/3#?. !'$-*'%3)=.) >383&"94-@ - key $! not found in DictionaryErreur lors du parsing de FEN: @80?37+).$89-72@)$'!:*;&3 - key $@ not found in DictionaryErreur lors du parsing de FEN: )%1)45- "22,:&<+79 *=:68@(' 2;+!1@ ,(4/,/'*,<! """/#.013..,0*8!3<#+.2-=?+&(*#:=+6?0=3'<"&@@.#@?*7 - key $) not found in DictionaryErreur lors du parsing de FEN: 4-&)4?%41;1(?=#'.4$&59(=+18?@40$"+&=?#"8->)=,..5<7>:10 - key $- not found in DictionaryErreur lors du parsing de FEN: ).8>)*";-*@6)8*"'4##$84#2#65;#)#@2%2,/0,;!); - key $) not found in DictionaryErreur lors du parsing de FEN: 3/895@$%&0,)*.7>$72=:&52'6*>!.3/;3%)<3/.!9-'/5 5= - Assertion failedErreur lors du parsing de FEN: ,> ,:?'="3!77=&&9:3;%945-0>* - key $, not found in DictionaryErreur lors du parsing de FEN: 8<0<#$>,'!%441&3//=;-)8)126!40&)> '74$,2 3 - Assertion failed
```

Mais nous pouvons deja voir que toutes ne trigger pas les même exception, nous avons `key not found in Dictionary` et `Assertion failed` par exemple.

Dans notre cas, le parser s'arrete trop rapidement, les assertion failed proviennent de

```smalltalk
expectString: expectedString

    | parsedToken |
    parsedToken := stream next: expectedString size.
    self assert: parsedToken = expectedString
```

Et les keynotfound proviennent de :

```smalltalk
parsePiece	

    | identifier |
    identifier := stream next.
    ^ pieces at: identifier

"Avec"
pieces := Dictionary new.
pieces at: $P put: 'White pawn'.
pieces at: $N put: 'White knight'.
pieces at: $B put: 'White bishop'.
pieces at: $R put: 'White rook'.
pieces at: $Q put: 'White queen'.
pieces at: $K put: 'White king'.

pieces at: $p put: 'Black pawn'.
pieces at: $n put: 'Black knight'.
pieces at: $b put: 'Black bishop'.	
pieces at: $r put: 'Black rook'.
pieces at: $q put: 'Black queen'.	
pieces at: $k put: 'Black king'.
```
Ce qui veux dire que nous ne passons même par la moitié du code du parser 

```smalltalk
parse

    | game |
    game := MyFENGame new.
  
    "Parse piece et le assert proviennent des deux lignes suivante"
    game ranks: self parseRanks.
    self expectString: ' '.
    
    "On ne parcours jamais le code suivant"
    game sideToMove: self parseSideToMove.
    self expectString: ' '.
    game castlingAbility: self parseCastlingAbility.
    self expectString: ' '.
    game enPassantTargetSquare: self parseEnPassant.
    self expectString: ' '.
    game halfMoveClock: self parseNumber.
    self expectString: ' '.
    game moveCount: self parseNumber.

    ^ game
```

Nous allons devoir spécialiser le fuzzer en utilisant au choix la grammaire definie precedemment ou des mutation de string FEN valides.

### Mutation fuzzing
Il nous faut un corpus de FEN valide pour les muter, nous nous baserons sur la [source](https://gist.github.com/peterellisjones/8c46c28141c162d1d8a0f0badbc9cff9)

On utilisera :

```bash
SRC="https://gist.githubusercontent.com/peterellisjones/8c46c28141c162d1d8a0f0badbc9cff9/raw/b11af5a3dd978724ac2d4a531217133b9a3ad9ba/Chess%2520Perft%2520test%2520positions"

curl $SRC | jq ".[] | .fen" | sed "s/\$/,/g"
```

pour extraire les FEN strings, ce qui nous donne :

```smalltalk
corpus := {
    'r6r/1b2k1bq/8/8/7B/8/8/R3K2R b KQ - 3 2'.
    '8/8/8/2k5/2pP4/8/B7/4K3 b - d3 0 3'.
    'r1bqkbnr/pppppppp/n7/8/8/P7/1PPPPPPP/RNBQKBNR w KQkq - 2 2'.
    'r3k2r/p1pp1pb1/bn2Qnp1/2qPN3/1p2P3/2N5/PPPBBPPP/R3K2R b KQkq - 3 2'.
    '2kr3r/p1ppqpb1/bn2Qnp1/3PN3/1p2P3/2N5/PPPBBPPP/R3K2R b KQ - 3 2'.
    'rnb2k1r/pp1Pbppp/2p5/q7/2B5/8/PPPQNnPP/RNB1K2R w KQ - 3 9'.
    '2r5/3pk3/8/2P5/8/2K5/8/8 w - - 5 4'.
    'rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8'.
    'r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10'.
    '3k4/3p4/8/K1P4r/8/8/8/8 b - - 0 1'.
    '8/8/4k3/8/2p5/8/B2P2K1/8 w - - 0 1'.
    '8/8/1k6/2b5/2pP4/8/5K2/8 b - d3 0 1'.
    '5k2/8/8/8/8/8/8/4K2R w K - 0 1'.
    '3k4/8/8/8/8/8/8/R3K3 w Q - 0 1'.
    'r3k2r/1b4bq/8/8/8/8/7B/R3K2R w KQkq - 0 1'.
    'r3k2r/8/3Q4/8/8/5q2/8/R3K2R b KQkq - 0 1'.
    '2K2r2/4P3/8/8/8/8/8/3k4 w - - 0 1'.
    '8/8/1P2K3/8/2n5/1q6/8/5k2 b - - 0 1'.
    '4k3/1P6/8/8/8/8/K7/8 w - - 0 1'.
    '8/P1k5/K7/8/8/8/8/8 w - - 0 1'.
    'K1k5/8/P7/8/8/8/8/8 w - - 0 1'.
    '8/k1P5/8/1K6/8/8/8/8 w - - 0 1'.
    '8/8/2k5/5q2/5n2/8/5K2/8 b - - 0 1'
}.
```

On defini notre mutation fuzzer :

```smalltalk
mutationFuzzer := PzMutationFuzzer new.
mutationFuzzer seed: corpus.
```

On fait notre runner :

```smalltalk
runner := PzBlockRunner on: [ :fen |
    [
        | parsedPosition |
        parsedPosition := MyFENParser parse: fen.
        "Par la suite nous ajouterons des assertion, pour le moment nous verifions simplement que les string ne declanche pas d'exception"
    ]
    on: Error do: [ :ex | 
        Transcript show: 'Erreur lors du parsing de FEN: ', fen, ' - ', ex messageText; cr.
    ].
].
```

Pour run :

```smalltalk
corpus := {
    'r6r/1b2k1bq/8/8/7B/8/8/R3K2R b KQ - 3 2'.
    '8/8/8/2k5/2pP4/8/B7/4K3 b - d3 0 3'.
    'r1bqkbnr/pppppppp/n7/8/8/P7/1PPPPPPP/RNBQKBNR w KQkq - 2 2'.
    'r3k2r/p1pp1pb1/bn2Qnp1/2qPN3/1p2P3/2N5/PPPBBPPP/R3K2R b KQkq - 3 2'.
    '2kr3r/p1ppqpb1/bn2Qnp1/3PN3/1p2P3/2N5/PPPBBPPP/R3K2R b KQ - 3 2'.
    'rnb2k1r/pp1Pbppp/2p5/q7/2B5/8/PPPQNnPP/RNB1K2R w KQ - 3 9'.
    '2r5/3pk3/8/2P5/8/2K5/8/8 w - - 5 4'.
    'rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8'.
    'r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10'.
    '3k4/3p4/8/K1P4r/8/8/8/8 b - - 0 1'.
    '8/8/4k3/8/2p5/8/B2P2K1/8 w - - 0 1'.
    '8/8/1k6/2b5/2pP4/8/5K2/8 b - d3 0 1'.
    '5k2/8/8/8/8/8/8/4K2R w K - 0 1'.
    '3k4/8/8/8/8/8/8/R3K3 w Q - 0 1'.
    'r3k2r/1b4bq/8/8/8/8/7B/R3K2R w KQkq - 0 1'.
    'r3k2r/8/3Q4/8/8/5q2/8/R3K2R b KQkq - 0 1'.
    '2K2r2/4P3/8/8/8/8/8/3k4 w - - 0 1'.
    '8/8/1P2K3/8/2n5/1q6/8/5k2 b - - 0 1'.
    '4k3/1P6/8/8/8/8/K7/8 w - - 0 1'.
    '8/P1k5/K7/8/8/8/8/8 w - - 0 1'.
    'K1k5/8/P7/8/8/8/8/8 w - - 0 1'.
    '8/k1P5/8/1K6/8/8/8/8 w - - 0 1'.
    '8/8/2k5/5q2/5n2/8/5K2/8 b - - 0 1'
}.

mutationFuzzer := PzMutationFuzzer new.
mutationFuzzer seed: corpus.

runner := PzBlockRunner on: [ :fen |
    [
        | parsedPosition |
        parsedPosition := MyFENParser parse: fen.
    ]
    on: Error do: [ :ex | 
        Transcript show: 'Erreur lors du parsing de FEN: ', fen, ' - ', ex messageText; cr.
    ].
].

mutationFuzzer run: runner times: 1000.
```

Mais avant, verifions si l'on peut parser notre corpus sans faire de mutations en modifiant les parametres du fuzzer :

```smalltalk
corpus := {
'r6r/1b2k1bq/8/8/7B/8/8/R3K2R b KQ - 3 2'.
'8/8/8/2k5/2pP4/8/B7/4K3 b - d3 0 3'.
'r1bqkbnr/pppppppp/n7/8/8/P7/1PPPPPPP/RNBQKBNR w KQkq - 2 2'.
'r3k2r/p1pp1pb1/bn2Qnp1/2qPN3/1p2P3/2N5/PPPBBPPP/R3K2R b KQkq - 3 2'.
'2kr3r/p1ppqpb1/bn2Qnp1/3PN3/1p2P3/2N5/PPPBBPPP/R3K2R b KQ - 3 2'.
'rnb2k1r/pp1Pbppp/2p5/q7/2B5/8/PPPQNnPP/RNB1K2R w KQ - 3 9'.
'2r5/3pk3/8/2P5/8/2K5/8/8 w - - 5 4'.
'rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8'.
'r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10'.
'3k4/3p4/8/K1P4r/8/8/8/8 b - - 0 1'.
'8/8/4k3/8/2p5/8/B2P2K1/8 w - - 0 1'.
'8/8/1k6/2b5/2pP4/8/5K2/8 b - d3 0 1'.
'5k2/8/8/8/8/8/8/4K2R w K - 0 1'.
'3k4/8/8/8/8/8/8/R3K3 w Q - 0 1'.
'r3k2r/1b4bq/8/8/8/8/7B/R3K2R w KQkq - 0 1'.
'r3k2r/8/3Q4/8/8/5q2/8/R3K2R b KQkq - 0 1'.
'2K2r2/4P3/8/8/8/8/8/3k4 w - - 0 1'.
'8/8/1P2K3/8/2n5/1q6/8/5k2 b - - 0 1'.
'4k3/1P6/8/8/8/8/K7/8 w - - 0 1'.
'8/P1k5/K7/8/8/8/8/8 w - - 0 1'.
'K1k5/8/P7/8/8/8/8/8 w - - 0 1'.
'8/k1P5/8/1K6/8/8/8/8 w - - 0 1'.
'8/8/2k5/5q2/5n2/8/5K2/8 b - - 0 1'
}.

mutationFuzzer := PzMutationFuzzer new.
mutationFuzzer maxMutations: 0. "On demande à avoir 0 modification sur nos strings"
mutationFuzzer minMutations: 0.
mutationFuzzer seed: corpus.

runner := PzBlockRunner on: [ :fen |
    [
        | parsedPosition |
        parsedPosition := MyFENParser parse: fen.
    ]
    on: Error do: [ :ex | 
        Transcript show: 'Erreur lors du parsing de FEN: ', fen, ' - ', ex messageText; cr.
        "On rethrow l'execption pour que ça le marque en fail"
        ex pass 
    ].
].

mutationFuzzer run: runner times: 1000.
```
En réalité aucun de nos strings ne passe, nous avons sur chaque un `SizeMismatch: collections size do not match`. 
Si l'on explore, l'erreur vient de la deserialization des rank :

```smalltalk
ranks: aCollection

    board := Dictionary new.
    aCollection reversed with: (1 to: 8) do: [ :rankPieces :rank |
    "L'erreur vient de la partie suivante"
    rankPieces with: ($a to: $h) do: [ :piece :column |
    board at: column asString , rank asString put: piece ] ]

"Elle est thow depuis la classe collection"

with: otherCollection do: twoArgBlock
    "Evaluate twoArgBlock with corresponding elements from this collection and otherCollection."

    "(Array streamContents: [:stream | #(1 2 3) with: #(4 5 6) do: [:a :b | stream nextPut: (a + b)]]) >>> #(5 7 9)"
    
    otherCollection size = self size ifFalse: [self errorSizeMismatch].
    1 to: self size do:
        [:index |
        twoArgBlock value: (self at: index)
        value: (otherCollection at: index)]
```
Le problème étant que le parser ne comprend pas `2k5`, il lui faudrait `11k11111` par exemple.
Si nous essayons sur une string respectant cela nous allons beaucoup plus loin `8/8/11k11111/8/8/8/8/8 b - - 0 1`.
Nous avons toujours une erreur mais pour moi nous somme maintenant face à un bug du parser que nous verrons par la suite.

### Grammar fuzzing 
