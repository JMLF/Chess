Class {
	#name : 'MyPawn',
	#superclass : 'MyPiece',
	#category : 'Myg-Chess-Core',
	#package : 'Myg-Chess-Core'
}

{ #category : 'moveCompute' }
MyPawn >> computeFirstMove [

	| legalSquare firstSquare secondSquare |
	legalSquare := OrderedCollection new.

	firstSquare := self isWhite
		               ifTrue: [ square up hasPiece ifFalse: [ square up ] ]
		               ifFalse: [ square down hasPiece ifFalse: [ square down ] ].

	secondSquare := firstSquare ifNotNil: [
		                self isWhite
			                ifTrue: [ ((square name at: 2) = $2 and: [ firstSquare hasPiece not ]) ifTrue: [ firstSquare up ] ]
			                ifFalse: [ ((square name at: 2) = $7 and: [ firstSquare hasPiece not ]) ifTrue: [ firstSquare down ] ] ].

	firstSquare ifNotNil: [ legalSquare add: firstSquare ].
	secondSquare ifNotNil: [ legalSquare add: secondSquare ].

	^ legalSquare
]

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

	| legalSquare |
	legalSquare := OrderedCollection new.
	
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
						
						(otherPieceLastMove = toto) ifTrue: [ legalSquare add: square up right ].
						
						 ].
				(square left notNil and: [square left hasPiece]) 
					ifTrue: [ 
						|leftPiece otherPieceLastMove gameLastMove toto|
						leftPiece := square left contents.
						otherPieceLastMove := (leftPiece lastSquare) ifNotNil: [ leftPiece lastSquare name ] ifNil: [ '' ].
						gameLastMove := (square board game) lastMove.
						toto := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].
						
						(otherPieceLastMove = toto) ifTrue: [ legalSquare add: square up left ].
						
						 ].
				square up right hasPiece ifTrue: [ legalSquare add: square up right ].
				square up left hasPiece ifTrue: [ legalSquare add: square up left ].
				 ] 
			]
		ifFalse: [
			square down ifNotNil: [
				(square right notNil and: [square right hasPiece]) 
					ifTrue: [ 
						|rightPiece otherPieceLastMove gameLastMove toto|
						rightPiece := square right contents.
						otherPieceLastMove := (rightPiece lastSquare) ifNotNil: [ rightPiece lastSquare name ] ifNil: [ '' ].
						gameLastMove := (square board game) lastMove.
						toto := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].
						
						(otherPieceLastMove = toto) ifTrue: [ legalSquare add: square down right ].
						
						 ].
				(square left notNil and: [square left hasPiece]) 
					ifTrue: [ 
						|leftPiece otherPieceLastMove gameLastMove toto|
						leftPiece := square left contents.
						otherPieceLastMove := (leftPiece lastSquare) ifNotNil: [ leftPiece lastSquare name ] ifNil: [ '' ].
						gameLastMove := (square board game) lastMove.
						toto := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].
						
						(otherPieceLastMove = toto) ifTrue: [ legalSquare add: square down left ].
						
						 ].
				square down right hasPiece ifTrue: [ legalSquare add: square down right ].
				square down left hasPiece ifTrue: [ legalSquare add: square down left ].
				] ].
		
		legalSquare addAll: self computeFirstMove .

	^ legalSquare select: [ :s | s notNil ]
]
