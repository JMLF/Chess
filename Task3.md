# Task3 : Rapport d'Analyse Fuzzing FEN paser

Installation du Fuzzer
```smalltalk
Metacello new
  baseline: 'Phuzzer';
  repository: 'github://alamvic/phuzzer:main';
  onConflictUseIncoming;
  load.
```

## Deinition de l'oracle :
Pour verifier que les strings généré par les differentes méthodes de fuzzing sont valide ou invalide nous avons besoin d'un systeme externe au 
parser pour les verifier.

Nous avons mis en place un programme [python qui verifie la validité des FEN](./FENOracle/).

Pour qu'il fonctionne vous devrez installer sur votre machine un paquet python dans le venv :

```bash 
cd FENOracle
source venv/bin/activate
pip install python-chess

# Test 
python3 validate_fen.py "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" #VALID`
```

Nous faisont appel à ce script depuis un classe pharo `FenOracle`.
Pour qu'elle fonctionne vous devez changer dans sa méthode initilize le chemin vers le python du venv et le chemin vers le script :

```smalltalk 
initialize 
    super initialize.
    pythonPath := '/home/marius/Documents/fac/Chess/FENOracle/venv/bin/python'. "Need to be in venv in order to access python-chess package"
    scriptPath := '/home/marius/Documents/fac/Chess/FENOracle/validate_fen.py'.
```

Une fois fait vous pouvez la tester depuis un playground :

```smalltalk
oracle := FENOracle new.
oracle validateFEN: '8/8/2k5/5q2/5n2/8/5K2/8 b - - 0 1'
```
Vous devriez avoir le retour true ainsi qu'un affichage dans le transcript. Si ce n'est pas le cas, les chemins ne sont pas bon.

Sortie transcript :
```
Commande: /home/marius/Documents/fac/Chess/FENOracle/venv/bin/python /home/marius/Documents/fac/Chess/FENOracle/validate_fen.py "8/8/2k5/5q2/5n2/8/5K2/8 b - - 0 1"
Sortie: VALID
```

## Création d'un runner
Nous voulons que nos génération passe via un runner custom qui nous renvoi `FAIL` dans le cas ou le parser échoue sur une string que l'oracle 
arrive à lire. 
`PASS` dans le cas ou le parser arrive à lire un fen validé par l'oracle et `PASS-FAIL` dans le cas ou le parser échoue sur une fen invalidé par 
l'oracle (résultat attendu, sinon FAIL).

Ce runner est défini dans le package Myg-Chess-Fuzzing et dans la classe MyFENRunner : 

```smalltalk
value: input
    | oracle isValid |
    oracle := FENOracle new.

    isValid := oracle validateFEN: input.
    [
        | parsedPosition |
        parsedPosition := MyFENParser parse: input ]
    on: Error	
    do: [ :ex |
        isValid ifFalse: [
            ^ self expectedFailureWith: {
                input.
            ex  } ].
        ^ self failureWith: {
            input.
        ex  } ].
    ^ self successWith: {
        input.
        isValid }
```

Usage : 

```smalltalk
mutationFuzzer := PzMutationFuzzer new.mutationFuzzer maxMutations: 0. mutationFuzzer minMutations: 0.mutationFuzzer seed: corpus."Définir le runner avec la logique de validation intégrée"runner := MyFENRunner new.mutationFuzzer run: runner times: 1000.
```

## Definition de la grammaire :

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

Voici la grammaire implémentée en Gnocoo :

```smalltalk
defineGrammar
	super defineGrammar.

	ntFEN --> ntPiecePlacement , ' ' , ntSideToMove , ' ' , ntCastling , ' ' , ntEnPassantTargetSquare , ' ' , ntHalfMoveClock , ' '
	, ntFullMoveNumber.

	ntPiecePlacement --> ntRank , '/' , ntRank , '/' , ntRank , '/' , ntRank , '/' , ntRank , '/' , ntRank , '/' , ntRank , '/' , ntRank.
	ntRankElement --> ntPiece | ntDigit.
	ntRank --> ntRankElement , ntRankElement , ntRankElement , ntRankElement , ntRankElement , ntRankElement , ntRankElement , ntRankElement.
	ntPiece --> 'P' | 'N' | 'B' | 'R' | 'Q' | 'K' | 'p' | 'n' | 'b' | 'r' | 'q' | 'k'.
	ntDigit --> '1'.
	ntSideToMove --> 'w' | 'b' .
	ntCastling --> ntCastlingAbility | '-'.
	ntCastlingAbility --> ntCastlingOption | ntCastlingOption , ntCastlingAbility.
	ntCastlingOption --> 'K' | 'Q' | 'k' | 'q'.
	ntEnPassantTargetSquare --> ntFile , ntDigit | '-'.
	ntFile --> 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h'.
	ntHalfMoveClock --> ntDigit | ntDigit , ntHalfMoveClock.
	ntFullMoveNumber --> ntDigit | ntDigit , ntFullMoveNumber.

	^ ntFEN
```

Avec les opérateurs disponibles dans Gnocoo, nous n'avons pas pu implémenter exactement la grammaire prévue, par exemple, il n'y a pas d'opérateur de répétition.

Nous n'avons pas eu le temps de le faire, mais l'idée aurait été de continuer avec cette grammaire grossière pour déterminer, avec le fuzzer, s'il ne parse pas les FEN non valides. Ensuite, nous aurions pu affiner petit à petit la grammaire pour nous rapprocher le plus possible de ce que le parser FEN attend, afin d'explorer chaque branche d'exécution et chercher des bugs en profondeur.

## Fuzzing
Nous avons toutes les bases pour commencer le fuzzing. Nous allons explorer plusieurs approche :

- aléatoire
- mutation
- Avec grammaire

### Fuzzing aléatoire 

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
Erreur lors du parsing de FEN: (>1   06/++2.1.!/.=: !"<=+ 08:*">&:@!?/23%<+-@+' 590#0.;?@,0<:700994:;#/)7 59<6 23&2$! - key $( not found in Dictionary
Erreur lors du parsing de FEN:  (0,!)12@9=)?,$:5>+.:6+': - Assertion failed
Erreur lors du parsing de FEN: .+30&"2  :/"#0!+2(,2>1,8,5>- =.89 +#8 3*4:&4&<#;4;9185%#=-/0+6098@@: - key $. not found in Dictionary
Erreur lors du parsing de FEN: 4<3&#<,,/), 83*5::)6@8%=-#!80<>119@'=.9# ?!!&1, - key $< not found in Dictionary
Erreur lors du parsing de FEN: 8(-(!%,+(?076=!24"('?'+/7=@$9!@;,'33"!6$@7*?+ 2 - Assertion failed
Erreur lors du parsing de FEN: 8>,($,?=,=831<@+9>'=-&1$+44(/51+3+"-.<6>'921-"?-5.@>)!7'1-7 /1;3%#<=6,%5! - Assertion failed
Erreur lors du parsing de FEN: (/:61:;)4?,9?7($/+"4%/3;3 (#0095=.?8'),56! @9+;28:-41%@2%8,? @3+$.4&+<<4-+4+4: - key $( not found in Dictionary
Erreur lors du parsing de FEN: #. /8"6"!,%=""%4& ,=2:@?>43%*2$3:(1!,8&;9='49-@ 48<?)2+56?- - key $# not found in Dictionary
Erreur lors du parsing de FEN: +'32;>&'8"(!,8?:?)3$ - key $+ not found in Dictionary
Erreur lors du parsing de FEN: &#,)-+=!-?9"&00*9(>&@):%(1=/=;1"'79@3-6,13* - key $& not found in Dictionary
Erreur lors du parsing de FEN: '$4:=.#0-+!"-+,2881;801:<5>819$0= - key $' not found in Dictionary
Erreur lors du parsing de FEN: <@)./0-#&29*.;3;2+=!.#3( - key $< not found in Dictionary
Erreur lors du parsing de FEN: "#-#/+3--(0@'0?3@& )*+5<&<&!9 - key $" not found in Dictionary
Erreur lors du parsing de FEN: (%*2<9>64@":>1);* 9=-508 -56-=(3(?"$@10..9+:2 - key $( not found in Dictionary
Erreur lors du parsing de FEN: @&4=*>1$%=1:@<>+=#*'$/9:715%6&2(3,="3 - key $@ not found in Dictionary
Erreur lors du parsing de FEN: <1?%?;(>"/</@!=,$$<'@:?>35*."1$3">?$".$ / (: 7-+416+66/7%,64#>>)$#!+#<8*>2;.)>*;040 - key $< not found in Dictionary
Erreur lors du parsing de FEN: <:*%*# 0-).=825?:<?34;;&-,12>96)$@1:!7%;1"8>3+*!@10 9*;4 - key $< not found in Dictionary
Erreur lors du parsing de FEN: &':+>3+-=51'/$:.0 6,,%=##-6-57"5(5,@!/0 "*%=!$!) %,+ - key $& not found in Dictionary
Erreur lors du parsing de FEN: (4:"?:+=?24,-!.0"/=;)'6< =0%%5<7);<"&&$(*:;,4,9@"</$&&- - key $( not found in Dictionary
Erreur lors du parsing de FEN: <4(;$$9:<,&*)$4(#6&0'@3= - key $< not found in Dictionary
Erreur lors du parsing de FEN: 5;:6=+&"5= -&?11 - key $; not found in Dictionary
Erreur lors du parsing de FEN: /37&<*20 7"<9657>#"0$5/4?$.3?7+;!'%!*.1;36=80='!05<6#6(1)@3/0'3+:)@2  '36 %,/+;;53(>0)"#)-1@+9 - key $& not found in Dictionary
Erreur lors du parsing de FEN: 9)@>;=53;+932=5=85-@+&67$0>(?%.((549 - key $) not found in Dictionary
Erreur lors du parsing de FEN: 7*;<1)3$/*02@..:15:;4;9/>;:53 - key $* not found in Dictionary
Erreur lors du parsing de FEN: 8<&=+3')#>#$@77%8*(2$5;44 " !=3<9@.!:,8,9,(,4$$# -$! ; =*)1)8(@%!4<.69?)(6*>='9197=:--8&&  - Assertion failed
Erreur lors du parsing de FEN: 0;797@<:>.77 - key $; not found in Dictionary
Erreur lors du parsing de FEN: 8@-#"8)=>#.4=4596 890=:"4#42" "<.-6)3,6+@-%26@79&1<;>5+,45):21)!44  @-6$:@;,)8521;01 : - Assertion failed
Erreur lors du parsing de FEN: ;8<+4$9>>'*+*2>-/> - key $; not found in Dictionary
Erreur lors du parsing de FEN: 84!+21!?"4&*9%;)50-7+(6'-'1+@)9;%*(6+=/-2(5&>#&@!$)+83),< - Assertion failed
Erreur lors du parsing de FEN: ;!%=%';03(28' =7801%31)>8$>>0:'=) /@7877-5--2&!4(6/@4./86,'3;@3/8))7,3.=6/ /@@8))7$*-#=<?88%7"@7>5,. - key $; not found in Dictionary
Erreur lors du parsing de FEN: 4">?$$+;%->.362,1.@7"&;4= - key $" not found in Dictionary
Erreur lors du parsing de FEN: =$$&< +(!.6"69 (:6,!04,:!6#@;<$#,'49-&@3.9+"$#,>5-#'0180?!8<5;3*88-85'&/ - key $= not found in Dictionary
Erreur lors du parsing de FEN: @1@(4:31;>@3'0@/>12;&==#$0+>!=42.&.@%"-5,(%79<-),)+"%6,,8/=(0@6.(6$:1&)@0*93;;6@!<28%<2%<@ 77&*8415. - key $@ not found in Dictionary
Erreur lors du parsing de FEN: =(62<"+@#6)%)==.&)"++!(2;6817>-*/4'4=<8.>))..5'::),- 8 - key $= not found in Dictionary
Erreur lors du parsing de FEN: $2?2#%2>,.'8,"  - key $$ not found in Dictionary
Erreur lors du parsing de FEN: @05/00-6?4!+)2-0&$;,9=3,%648)>04 >8+-%6?:)? - key $@ not found in Dictionary
Erreur lors du parsing de FEN: =-'<-"@8;9=$.>#&>60..+&4>3(:(5&5#'-?-'7)2+58-'8/2 8;0&<>52 - key $= not found in Dictionary
Erreur lors du parsing de FEN: *<)@#,7&=&'973)93?-@;;7-5'+1'<2>% - key $* not found in Dictionary
Erreur lors du parsing de FEN: '<=" 8,407$!1!83*:,6<4>/,)%0%&<#&4/57)!30"0&0'18;&*942>?3@4$1,1#(8$>/- 25$&#??!08;#$(!5< - key $' not found in Dictionary
Erreur lors du parsing de FEN: -?'*1=?<@:;0;#=5#..7*:<% -3*>*#/,%$?9?9-7%0/6+<#%/++>5-+9?:+<',"18,#)9 - key $- not found in Dictionary
Erreur lors du parsing de FEN: &-,/40,'9-0' - key $& not found in Dictionary
Erreur lors du parsing de FEN: @7&#%#!64-<5&$,0=,1&/%@7@'"166::9;#,/.>3"1=!$41@"?30 - key $@ not found in Dictionary
Erreur lors du parsing de FEN: 163!.(3:=9>0#*078'%.&2:6( #*/ 2/%=+663,11$?=<8#7+#6<?*/=$$!2?@5.>2/3#?. !'$-*'%3)=.) >383&"94-@ - key $! not found in Dictionary
Erreur lors du parsing de FEN: @80?37+).$89-72@)$'!:*;&3 - key $@ not found in Dictionary
Erreur lors du parsing de FEN: )%1)45- "22,:&<+79 *=:68@(' 2;+!1@ ,(4/,/'*,<! """/#.013..,0*8!3<#+.2-=?+&(*#:=+6?0=3'<"&@@.#@?*7 - key $) not found in Dictionary
Erreur lors du parsing de FEN: 4-&)4?%41;1(?=#'.4$&59(=+18?@40$"+&=?#"8->)=,..5<7>:10 - key $- not found in Dictionary
Erreur lors du parsing de FEN: ).8>)*";-*@6)8*"'4##$84#2#65;#)#@2%2,/0,;!); - key $) not found in Dictionary
Erreur lors du parsing de FEN: 3/895@$%&0,)*.7>$72=:&52'6*>!.3/;3%)<3/.!9-'/5 5= - Assertion failed
Erreur lors du parsing de FEN: ,> ,:?'="3!77=&&9:3;%945-0>* - key $, not found in Dictionary
Erreur lors du parsing de FEN: 8<0<#$>,'!%441&3//=;-)8)126!40&)> '74$,2 3 - Assertion failed
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

Ces résultats ne sont pas réprésentatif, la génération aléatoire est trop éloigné du format attendu par le parser nous ne pourrons rien en tirer pour le moment.
Nous allons donc devoir spécialiser le fuzzer en utilisant au choix la grammaire definie precedemment ou des mutations de string FEN valides.

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

runner := MyFENRunner new.

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

runner := MyFENRunner new.

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

**Nous allons donc commencer par fixer ce bug.**
Le problème provient de la fonction `ranks:` de MyFENGame, la fonction attend une collection de 8 items mais lorsque nous avons 2k5.
la collection est d'une taille 3 avec {$2 'whiteKnight' $5}, nous devont le transformer en {'empty' 'empty' 'whiteKnight' 'empty' 'empty' 'empty' ...}.

Fonction avant :
```smalltalk
ranksback: aCollection	board := Dictionary new.	aCollection reversed with: (1 to: 8) do: [ :rankPieces :rank |		rankPieces with: ($a to: $h) do: [ :piece :column |			board at: column asString , rank asString put: piece ] ]
```

Fonction fixé :
```smalltalk
ranks: aCollection    "Initialise le board à partir d'une collection de collections représentant les rangées d'échecs.    Les chiffres dans les collections représentent des cases vides à étendre."    | board columnLetters expandedCollection |    board := Dictionary new.    columnLetters := $a to: $h.    "Pour chaque rangée, étendre les chiffres en cases vides"    expandedCollection := aCollection reversed collect: [:rankPieces |        | expandedPieces |        expandedPieces := OrderedCollection new.        rankPieces do: [:item |            (item isCharacter and: [item isDigit])                ifTrue: [                    (item digitValue) timesRepeat: [expandedPieces add: 'empty']                ]                ifFalse: [                                       (item = 'empty')                         ifTrue: [expandedPieces add: 'empty']                        ifFalse: [expandedPieces add: item]                ].        ].        expandedPieces    ].    "Vérifier que chaque rangée a exactement 8 éléments après expansion"    expandedCollection doWithIndex: [:rankPieces :rank |        (rankPieces size = 8) ifFalse: [            self error: 'La taille ne fait pas 8' ].        rankPieces with: columnLetters do: [:piece :column |            board at: (column asString , rank asString) put: piece        ].    ].    ^ board
```

Nous n'avons plus l'erreur `SizeMissmatch` nous pouvons passer à la suite.

**Nous avons toujours une erreur mais nous somme maintenant face à un bug du parser !**
Si l'on parse la string précédente nous avons l'erreur `Assertion Failed` sur :

```smalltalk
parse	

    | game |
    game := MyFENGame new.

    game ranks: self parseRanks.
    self expectString: ' '.
    game sideToMove: self parseSideToMove.
    self expectString: ' '.
    game castlingAbility: self parseCastlingAbility.
    
    "L'erreur provient du call suivant"
    self expectString: ' '.

    game enPassantTargetSquare: self parseEnPassant.
    self expectString: ' '. 
    game halfMoveClock: self parseNumber.
    self expectString: ' '.
    game moveCount: self parseNumber.
    
    ^ game

```

Nous attendons un ' ' mais nous avons le caractère '-' à la place :

```smalltalk
expectString: expectedString

	| parsedToken |
	parsedToken := stream next: expectedString size.
	self assert: parsedToken = expectedString
```

Et c'est normal puisque que dans notre string nous n'avons pas de cast (rock), nous avons '-' ce qui nous fait passer dans la premiere partie du code :

```smalltalk
parseCastlingAbility

    "Nous somme dans le cas de la ligne sivante, mais comme nous pouvons le constater on fait juste un return sans deplacer le curseur du string ce qui nous laisse sur le même caractère"
    self peek = $- ifTrue: [ ^ 'NO CASTLING' ].

    "On devrait avoir : self peek = $- ifTrue: [stream next. ^ 'NO CASTLING' ]."

    ^ (1 to: 4) collect: [ :i | self parseAnyOf: #( $k $K $q $Q ) ]
```

Un fois ces deux bug fix, nous pouvons relancer pour avoir de nouveaux résultats.

```
#('PASS' #('K1k5/8/P7/8/8/8/8/8 w - - 0 1' true) 
#('FAIL' an Array('r6r/1b2k1bq/8/8/7B/8/8/R3K2R b KQ - 3 2' Error: Expected one of #($k $K $q $Q)) 
#('PASS' #('8/8/1P2K3/8/2n5/1q6/8/5k2 b - - 0 1' true)) 
#('PASS' #('r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10' true)) 
#('PASS' #('8/k1P5/8/1K6/8/8/8/8 w - - 0 1' true)) 
#('PASS' #('3k4/3p4/8/K1P4r/8/8/8/8 b - - 0 1' true)) 
#('PASS' #('8/8/4k3/8/2p5/8/B2P2K1/8 w - - 0 1' true)) 
#('PASS' #('8/P1k5/K7/8/8/8/8/8 w - - 0 1' true)) 
#('PASS' #('2K2r2/4P3/8/8/8/8/8/3k4 w - - 0 1' true)) 
#('FAIL' an Array('r6r/1b2k1bq/8/8/7B/8/8/R3K2R b KQ - 3 2' Error: Expected one of #($k $K $q $Q)) 
#('PASS' #('8/k1P5/8/1K6/8/8/8/8 w - - 0 1' true)) 
#('PASS' #('8/8/1P2K3/8/2n5/1q6/8/5k2 b - - 0 1' true)) 
#('FAIL' an Array('8/8/1k6/2b5/2pP4/8/5K2/8 b - d3 0 1' Error: Expected one of (3 to: 6)) 
#('PASS' #('r1bqkbnr/pppppppp/n7/8/8/P7/1PPPPPPP/RNBQKBNR w KQkq - 2 2' true)) 
#('FAIL' an Array('3k4/8/8/8/8/8/8/R3K3 w Q - 0 1' Error: Expected one of #($k $K $q $Q)) 
#('PASS' #('8/k1P5/8/1K6/8/8/8/8 w - - 0 1' true)) 
#('PASS' #('4k3/1P6/8/8/8/8/K7/8 w - - 0 1' true)) 
#('PASS' #('8/P1k5/K7/8/8/8/8/8 w - - 0 1' true)) 
#('PASS' #('3k4/3p4/8/K1P4r/8/8/8/8 b - - 0 1' true)) 
#('PASS' #('8/8/1P2K3/8/2n5/1q6/8/5k2 b - - 0 1' true)) 
#('PASS' #('8/8/4k3/8/2p5/8/B2P2K1/8 w - - 0 1' true)) 
#('PASS' #('4k3/1P6/8/8/8/8/K7/8 w - - 0 1' true)) 
#('FAIL' an Array('8/8/1k6/2b5/2pP4/8/5K2/8 b - d3 0 1' Error: Expected one of (3 to: 6)))
```

Nous avons des Fen qui passent !
Nous avons deux nouveaux bugs `Error: Expected one of (3 to: 6)` et `Error: Expected one of #($k $K $q $Q)`. 
Malheuresement par manque de temps nous n'irons pas plus loin dans la correction de ceux-ci.

Essayons en ajoutant des mutations sur notre corpus :

```smalltalk
mutationFuzzer maxMutations: 5. mutationFuzzer minMutations: 0.
```

Forcement, nous avons beaucoup de fen générés qui ne respecte pas le format et qui sont donc en PASS-FAIL (fen invalide sur l'oracle et erreur du parser)

```
an Array(an Array('PASS-FAIL' an Array('rnbq1k1r/pp1Pbppp/2p5/8/2Bu/8/PPP1NnPP/RNBQK2R w KQ - 1 8' KeyNotFound: key $u not found in Dictionary)) 
an Array('FAIL' an Array('rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8' Error: Expected one of #($k $K $q $Q))) 
an Array('PASS-FAIL' an Array('5k2//8/8/8/8/8/4K2R w K - 0 1' KeyNotFound: key Character value: 24 not found in Dictionary)) 
an Array('FAIL' an Array('rnb2k1r/pp1Pbppp/2p5/q7/2B5/8/PPPQNnPP/RNB1K2R w KQ - 3 9' Error: Expected one of #($k $K $q $Q))) 
#('PASS' #('r3k2r/1b4bq/8/8/8/8/7B/R3K2R w KQkq - 0 1' true)) 
an Array('PASS-FAIL' an Array('5k2//88/8''8/8I/4K2R w K -0 1' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('r3k2r/1b4bq/8/8/8/8/7B/VR3J2R w KMQkq - 0 1' KeyNotFound: key $V not found in Dictionary)) 
an Array('PASS-FAIL' an Array('r3k2*r/8/3Q4/8/8/5q2/8/R3K2R b KQkq - 0 1' KeyNotFound: key $* not found in Dictionary)) 
an Array('PASS-FAIL' an Array('8/8/1P2K3/8/2n5/16//5k2 b - - 0 5' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('8/8/4k3/8o/2p5/8/B2P2K1 w - - 0 1' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('uk2/8/8/8r/8/8/8/4K>2R w K - 0 1' KeyNotFound: key $u not found in Dictionary)) 
an Array('PASS-FAIL' an Array('8/8/8./2k5/2pP4/8/B7l/4K3 b - d3 0 3' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('rnbq1k1r/pp1Pbppp/2p5/8/2eB5?8/PPPNfnPP/RNBQK2R w KQ(- 1 8' KeyNotFound: key $e not found in Dictionary)) 
#('PASS' #('8/8/4k3/8/2p5/8/B2P2K1/8 w - - 0 1' true)) 
an Array('PASS-FAIL' an Array('r3k2r/8/3Q4/8/8/5q2/8/R3K2R b KPkq - 0 ' Error: Expected one of #($k $K $q $Q))) 
an Array('FAIL' an Array('8/8/8/2k5/2pP4/8/B7/4K3 b - d3 0 3' Error: Expected one of (3 to: 6))) 
an Array('PASS-FAIL' an Array('2r5/3pk3/2P5/8/2K5//8 w -/ 5 4' KeyNotFound: key Character value: 15 not found in Dictionary)) 
an Array('PASS-FAIL' an Array('3k4/8/8/88/8/8/R3K3 w Q - 0 1' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('2r5/3:pk3/8/2P5/8/2K5/8/8 w - - 5 4' KeyNotFound: key $: not found in Dictionary)) 
an Array('PASS-FAIL' an Array('r4rk1/1pp1qppp/p1n:p1n2/2b1p1B1/2B1P1b1N/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10' KeyNotFound: key $: not found in Dictionary)) an Array('PASS-FAIL' an Array('r3k2dr/1b4bq/8/8/y8/8/7B/R3K2R w KQkq - 0 1' KeyNotFound: key $d not found in Dictionary)) 
an Array('PASS-FAIL' an Array('r4r0/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RKB1 w - - )0 10' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('2kr3r/p1ppqpb1/bn2Qnp1/3PN3/1p2P3/2N5/PPPBBPPP/2R3K2R b KQ - 3 2' Error: La taille ne fait pas 8)) 
an Array('FAIL' an Array('3k4/8/8/8/8/8/8/R3K3 w Q - 0 1' Error: Expected one of #($k $K $q $Q))) 
an Array('PASS-FAIL' an Array('4k3/1R6/p8/8/8/8/K/80w- - 0 1' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('r1bqkbNr/pppppppp/n7/8/8-P7/1PPPPPPPT/RNBQIBNR w KQkq 1- 2 2' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('8/8/1k6/2b/2pP4/8/5K2/8 b - d=3 0 W1' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('8/8}/1P2K3/82vn5/1q6/8/5k2 b - - 01' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('8/P1k5/K7/8/8/8/8/8 w  - 0 q' Error: Expected one of #($k $K $q $Q))) 
an Array('PASS-FAIL' an Array('8/k1P5/8/1K6/88/8/8 w - - 0 !' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('rnbq1kW1r/pp1Pbppp/2p5/8/2B5/8/P"PP1NnPP/RNBQK2R w KQ - 1 8' KeyNotFound: key $W not found in Dictionary)) 
an Array('PASS-FAIL' an Array('8/8/1P2K3b/8/2n5?/1q6/8/5k2 b - - 0 1' KeyNotFound: key $? not found in Dictionary)) 
an Array('PASS-FAIL' an Array('8/8/2k5/5q2/}5n2+8/5K2/8 (b - - 0 1' KeyNotFound: key $} not found in Dictionary)) 
#('PASS' #('8/8/4k3/8/2p5/8/B2P2K1/8 w - - 0 1' true)) 
an Array('PASS-FAIL' an Array('r3k2r/xB1b4bq/8/8/8/8/7B/R3K2R w KQkq -n 0 1T' KeyNotFound: key $x not found in Dictionary)) 
#('PASS' #('2K2r2/4P3/8/8/8/8/8/3k4 w - - 0 1' true)) 
an Array('PASS-FAIL' an Array('8/8/4k;//2p5/8/B2Po2K1/8 w - - 0 1' KeyNotFound: key $; not found in Dictionary)) 
#('PASS' #('8/P1k5/K7/8/8/8/8/8 w - - 0 1' true)) 
an Array('PASS-FAIL' an Array('rnb2K1r/pp1Pbrpp/2p5/q7/2B5/8/PPPQNnPP-/RNB1K2R w KQ - 3 9' KeyNotFound: key $- not found in Dictionary)) 
an Array('PASS-FAIL' an Array('3k4/3p4/8G/K1P4r/8/8n/88 b - - 0 1' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('8/8/1P27K3/8/2n5/1q6/8/5k2 b --0,0 1' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('r6r1bk1bq/8/8?7B/8/8/R2K2R b KQ - 3 2' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('8/k1P5/!8/K6//8/8/8 w$- - 0 1' KeyNotFound: key $! not found in Dictionary)) 
an Array('PASS-FAIL' an Array('4k3/1P6/8/8/8/:/K7/8 w - - 0 1' KeyNotFound: key $: not found in Dictionary)) 
an Array('PASS-FAIL' an Array('8/k1cP5/8/1K6/8/8/8/8 w - - 0 1' KeyNotFound: key $c not found in Dictionary)) 
an Array('PASS-FAIL' an Array('rnbq1kb/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('r3k2rp1pp1pb1/bn2!Qnp1/2qPN3/1p2Pg3/2N5/PPPBBPPP/R3K2R b KQ{q - 3 "' KeyNotFound: key $! not found in Dictionary)) 
an Array('PASS-FAIL' an Array('2kr3r/p1ppqpb1/bn2Ynp1/3PN3/1p2P3/2N5/PPPB5BPPP/R3K2R b KQ - 3 2' KeyNotFound: key $Y not found in Dictionary)) 
an Array('PASS-FAIL' an Array('rnb2k1r/pp1#Pbppp/2p5/q7/2B5/8/PPPQNnPP/ROB1K2R w K - 3 9' KeyNotFound: key $# not found in Dictionary)) 
an Array('PASS-FAIL' an Array('8/8/2k5/5q2/5n2/85K2/8 b - - 0 1' AssertionFailure: Assertion failed)))
```

Ce qui nous interesse ici ce sont les FAIL. Puisque nous n'avons pas fix les bugs précédemment ce sont les même. Nous pouvons constater que certaines 
fen généré sont en PASS et pour ce qui est des PASS-FAIL nous avons des erreurs proche des générations aléatoires.

### Grammar fuzzing 

De la même façon que le fuzzing avec mutation, essayons le fuzzing avec notre grammaire :

```smalltalk
fuzzer := PzGrammarFuzzer on: MyFENGrammar new.

runner := MyFENRunner new.

fuzzer run: runner times: 50.
```

Comme dit dans la section création de la grammaire, celle-ci est trop imprécise. Pour qu'elle soit pleinement exploitable il nous faudrait l'affiner.
Pour le moment, toutes les générations sont en PASS-FAIL :

```
an Array(an Array('PASS-FAIL' an Array('RN1nRp11/11BQ1KNR/bp141RBN/111KR0Kn/nn0Q1nNQ/111Kn115/qk1RBnPr/1r571nqn w - a1 417 1' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('Q2q5696q/Qr51nPRK/111rn7n1/511b1Qb6/R1471k1p/p113KB1Q/21K1r118/bQbkQ1b1 w k d2 10 6' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('K191181K/Q11501p1/k1NprBB8/q11K4k1P/B1811Q11/B19Kr1bB/KK1Nnq28/k11pKb11 w Q - 188 5' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('Nq8B5Bn7/r1bbp131/P1811PB4/Nk1bn15q/17QNP141/1brnnK41/2Rn6Qk6r/1b1161QQ w - - 1 11' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('NB1nQK6B/1BpbqrPq/nP85Nk1R/q1kK1N1b/bk115bQq/qb15b1Q8/q1B11P16/11111p11 b KQQ - 1 0' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('KpN1nRPN/8R112B69/B31p11NQ/Pn11prrK/P1Pn91q1/kp1R1bRr/r1bkP15N/QP621BK5 b KQK - 1 1' AssertionFailure: Assertion failed)) an Array('PASS-FAIL' an Array('7P11111b/rNQr181q/11qQRpq7/N1K1Rp11/p1RnKbq3/P515r6Q1/bPK312K1/Qpn9b06p b kQ - 11 7' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('6B5rkn15/rnb41R1k/16P1NqN3/8NnrK7Q1/66KKP131/Bk12rq96/KKr101nb/111161r1 b Qq d1 3 5' AssertionFailure: Assertion failed)) an Array('PASS-FAIL' an Array('4Q11qBB1/p111p0n1/1103b1Q8/b2R116kK/1n2R1111/q1rKr1bB/7k1b1kk1/b1nRR2n1 b - - 2511 1' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('N4r5nn18/N161971Q/KrK8rbN3/36NbK1pk/161112n1/1P10k51q/1p1r4rQR/1qK11q1R w QKq - 3 3' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('9RQ1kQ09/pPPKB1k2/12RQN111/2p91qn1N/Nqrr1N31/Q1r5q1rR/3803RbrR/kQ1831kP w - b4 01 11' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('bp28RBk1/6nqQbP6p/knnBr1kp/197p1rk2/r66B5Q7p/5r111PB2/1pR6RPK0/81111p6n b - - 1 1' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('pbp1BQ41/kk0057nK/nk01kN30/bKB131qn/1111p31N/1pB1Rk10/19P1n10k/1N3B6Q11 w - b1 112 3' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('2p16rrqN/NpN19111/PpB1111K/11kp1Q0b/r195BBN1/n1pkP1K1/191p1241/14R1R198 w - - 1 1' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('kbrBKPPN/8111N11B/r18bRKp1/111Pnr96/1R7bRpqp/777nQQ2Q/810N1QNb/QQ1p3Q1K w - f1 0 1' AssertionFailure: Assertion failed)) 
an Array('PASS-FAIL' an Array('N11rn1K0/p6Pkq11b/1KN1r119/K16B9k11/RqQ111kR/15Q1qkqN/P8611BK2/NPN810P2 w k - 1 8' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('P18nnB2P/1r1R11R6/1qrq110K/n131N1P8/11p8rNPk/nnN1q112/Qkr31r9q/91QR01n1 b - - 2 813' Error: La taille ne fait pas 8)) 
an Array('PASS-FAIL' an Array('k1RBqq6b/B0nR1PBR/19011bK8/p1715n17/59k102R1/0nn7np10/qNR1N31Q/9qKPp11r b kQ - 9 11' Error: La taille ne fait pas 8)) 
```

Nous ne pouvons pas en l'etat trouver des bugs interessant avec.
