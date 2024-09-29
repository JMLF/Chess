Class {
	#name : 'MyPawn',
	#superclass : 'MyPiece',
	#category : 'Myg-Chess-Core',
	#package : 'Myg-Chess-Core'
}

{ #category : 'moveCompute' }
MyPawn >> addCaptureIfPossible: targetSquare to: legalSquares [ 
    (targetSquare notNil and: [targetSquare hasPiece and: [targetSquare contents color ~= self color] ]) 
        ifTrue: [ legalSquares add: targetSquare ]
]

{ #category : 'moveCompute' }
MyPawn >> addDiagonalCaptures: legalSquares [
	| targetSquare |
    targetSquare := self isWhite ifTrue: [ square up ] ifFalse: [ square down ].
    
    targetSquare ifNotNil: [
        self addCaptureIfPossible: targetSquare right to: legalSquares.
        self addCaptureIfPossible: targetSquare left to: legalSquares.
    ]
]

{ #category : 'moveCompute' }
MyPawn >> addEnPassantCaptures: legalSquares [

	| targetSquare |
	targetSquare := self isWhite
		                ifTrue: [ square up ]
		                ifFalse: [ square down ].

	targetSquare ifNotNil: [
		self checkEnPassantCapture: square right targetSquare: targetSquare addTo: legalSquares.
		self checkEnPassantCapture: square left targetSquare: targetSquare addTo: legalSquares ]
]

{ #category : 'moveCompute' }
MyPawn >> checkEnPassantCapture: sideSquare targetSquare: targetSquare addTo: legalSquares [

	| sidePiece otherPieceLastMove gameLastMove lastMoveEnd |
	(sideSquare notNil and: [ sideSquare hasPiece ]) ifFalse: [ ^ self ].
	sidePiece := sideSquare contents.
	otherPieceLastMove := sidePiece lastSquare ifNotNil: [ :sq | sq name ] ifNil: [ '' ].
	gameLastMove := square board game lastMove.
	lastMoveEnd := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].
	otherPieceLastMove = lastMoveEnd ifTrue: [
		legalSquares add: (self isWhite
				 ifTrue: [ targetSquare right ]
				 ifFalse: [ targetSquare left ]) ]
]

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
	
		
		self addDiagonalCaptures: legalSquare .
		legalSquare addAll: self computeFirstMove .
		self addEnPassantCaptures: legalSquare .

	^ legalSquare select: [ :s | s notNil ]
]
