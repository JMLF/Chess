Class {
	#name : 'MyPawn',
	#superclass : 'MyPiece',
	#category : 'Myg-Chess-Core',
	#package : 'Myg-Chess-Core'
}

{ #category : 'accessing' }
MyPawn >> id [

	^ 'P'
]

{ #category : 'rendering' }
MyPawn >> renderPieceOn: aSquare [ 
	
	^ aSquare renderPawn: self
]

{ #category : 'rendering' }
MyPawn >> targetSquaresLegal: aBoolean [

	| legalSquares |
	legalSquares := OrderedCollection new.

	self isWhite
		ifTrue: [
			square up ifNotNil: [
				(square right notNil and: [square right hasPiece]) 
					ifTrue: [ 
						|rightPiece otherPieceLastMove gameLastMove toto|
						rightPiece := square right contents.
						otherPieceLastMove := (rightPiece lastSquare) ifNotNil: [ rightPiece lastSquare name ] ifNil: [ '' ].
						gameLastMove := (square board game) lastMove.
						toto := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].
						
						(otherPieceLastMove = toto) ifTrue: [ legalSquares add: square up right ].
						
						 ].
				(square left notNil and: [square left hasPiece]) 
					ifTrue: [ 
						|leftPiece otherPieceLastMove gameLastMove toto|
						leftPiece := square left contents.
						otherPieceLastMove := (leftPiece lastSquare) ifNotNil: [ leftPiece lastSquare name ] ifNil: [ '' ].
						gameLastMove := (square board game) lastMove.
						toto := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].
						
						(otherPieceLastMove = toto) ifTrue: [ legalSquares add: square up left ].
						
						 ].
				(square name at: 2) = $2 ifTrue: [ legalSquares add: square up up ].
				square up right hasPiece ifTrue: [ legalSquares add: square up right ].
				square up left hasPiece ifTrue: [ legalSquares add: square up left ].
				square up hasPiece ifFalse: [ legalSquares add: square up ] ] ]
		ifFalse: [
			square down ifNotNil: [
				(square right notNil and: [square right hasPiece]) 
					ifTrue: [ 
						|rightPiece otherPieceLastMove gameLastMove toto|
						rightPiece := square right contents.
						otherPieceLastMove := (rightPiece lastSquare) ifNotNil: [ rightPiece lastSquare name ] ifNil: [ '' ].
						gameLastMove := (square board game) lastMove.
						toto := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].
						
						(otherPieceLastMove = toto) ifTrue: [ legalSquares add: square down right ].
						
						 ].
				(square left notNil and: [square left hasPiece]) 
					ifTrue: [ 
						|leftPiece otherPieceLastMove gameLastMove toto|
						leftPiece := square left contents.
						otherPieceLastMove := (leftPiece lastSquare) ifNotNil: [ leftPiece lastSquare name ] ifNil: [ '' ].
						gameLastMove := (square board game) lastMove.
						toto := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].
						
						(otherPieceLastMove = toto) ifTrue: [ legalSquares add: square down left ].
						
						 ].
				(square name at: 2) = $7 ifTrue: [ legalSquares add: square down down ].
				square down right hasPiece ifTrue: [ legalSquares add: square down right ].
				square down left hasPiece ifTrue: [ legalSquares add: square down left ].
				square down hasPiece ifFalse: [ legalSquares add: square down ] ] ].

	^ legalSquares select: [ :s | s notNil ]
]
