Class {
	#name : 'MyFENGrammar',
	#superclass : 'GncBaseGrammar',
	#instVars : [
		'ntPiecePlacement',
		'ntRank',
		'ntPiece',
		'ntSideToMove',
		'ntFEN',
		'ntFile',
		'ntEnPassantTargetSquare',
		'ntHalfMoveClock',
		'ntFullMoveNumber',
		'ntCastlingOption',
		'ntCastlingAbility',
		'ntRankElement',
		'ntCastling'
	],
	#category : 'Myg-Chess-Fuzzing',
	#package : 'Myg-Chess-Fuzzing'
}

{ #category : 'initialization' }
MyFENGrammar >> defineGrammar [
	"The superclass defines how to generate numbers"

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
]
