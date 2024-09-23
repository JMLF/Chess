Class {
	#name : 'MyPawnTests',
	#superclass : 'TestCase',
	#category : 'Myg-Chess-Tests',
	#package : 'Myg-Chess-Tests'
}

{ #category : 'tests' }
MyPawnTests >> testBlackCannotEatOponentForward [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c5' put: (pawn := MyPawn black ).

	"Sould not pass with a blocking opponent"
	board at: 'c4' put: MyPawn white .

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'c4' ]) not

	
]

{ #category : 'tests' }
MyPawnTests >> testBlackMovesDownLeftWithOponentObstacle [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn black).

	"Sould be able tu eat the opponent on down right"
	board at: 'b3' put: (MyPawn white).

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'b3' ])

	
]

{ #category : 'tests' }
MyPawnTests >> testBlackMovesDownRightWithOponentObstacle [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn black).

	"Sould be able tu eat the opponent on down right"
	board at: 'd3' put: (MyPawn white).

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'd3' ]) 

	
]

{ #category : 'tests' }
MyPawnTests >> testBlackPawnCannotGoToTheSide [

   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e7' put: (pawn := MyPawn black ).

	squares := pawn targetSquares. 
   
	self assert: (squares anySatisfy: [:each | #('d2' 'f2') includes: each name ]) not

	
]

{ #category : 'tests' }
MyPawnTests >> testFirstMoveForBlack [
	"Pawn should be able to move 1 for their regular move"
   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e7' put: (pawn := MyPawn black ).

	squares := pawn targetSquares.

   
	self
       assertCollection: squares
       includesAll: (#( e6 e5) collect: [ :name | board at: name ])
]

{ #category : 'tests' }
MyPawnTests >> testFirstMoveForWhite [
	"Pawn should be able to move 1 for their regular move"
   | pawn squares board row|
   board := MyChessBoard empty.
   board at: 'e2' put: (pawn := MyPawn white).

	squares := pawn targetSquares.
   row := pawn square. 
   
	self
       assertCollection: squares
       includesAll:
           (#( e3 e4) collect: [ :name |
                board at: name ])
]

{ #category : 'tests' }
MyPawnTests >> testId [
	self assert: MyPawn new id equals: 'P'
]

{ #category : 'tests' }
MyPawnTests >> testRegularMoveForBlack [
	"Pawn should be able to move 1 for their regular move"
   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e7' put: (pawn := MyPawn black).

	squares := pawn targetSquares.
   
	self assert: (squares anySatisfy: [ :each | each name = 'e6' ])
]

{ #category : 'tests' }
MyPawnTests >> testRegularMoveForWhite [
	"Pawn should be able to move 1 for their regular move"
   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e2' put: (pawn := MyPawn white).

	squares := pawn targetSquares.

	self assert: (squares anySatisfy: [ :each | each name = 'e3' ])
]

{ #category : 'tests' }
MyPawnTests >> testWhiteCannotEatOponentForward [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn white).

	"Sould not pass with a blocking opponent"
	board at: 'c5' put: MyPawn black.

	squares := pawn targetSquares.
	
	self assert: (squares anySatisfy: [ :each | each name = 'c5' ]) not

	
]

{ #category : 'tests' }
MyPawnTests >> testWhiteMovesUpLeftWithOponentObstacle [
	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn white).

	"Sould be able tu eat the opponent on top left"
	board at: 'b5' put: (MyPawn black).

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'b5' ])
]

{ #category : 'tests' }
MyPawnTests >> testWhiteMovesUpRightWithOponentObstacle [
	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn white).

	"Sould be able tu eat the opponent on top right"
	board at: 'd5' put: (MyPawn black).

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'd5' ])
]

{ #category : 'tests' }
MyPawnTests >> testWhitePawnCannotGoToTheSide [

   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e2' put: (pawn := MyPawn white).

	squares := pawn targetSquares.
   
	self assert: (squares anySatisfy: [:each | #('d2' 'f2') includes: each name ]) not

	
]
