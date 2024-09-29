Class {
	#name : 'MyPawnTests',
	#superclass : 'TestCase',
	#category : 'Myg-Chess-Tests',
	#package : 'Myg-Chess-Tests'
}

{ #category : 'black' }
MyPawnTests >> testBlackCannotEatOponentForward [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c5' put: (pawn := MyPawn black ).

	"Sould not pass with a blocking opponent"
	board at: 'c4' put: MyPawn white .

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'c4' ]) not

	
]

{ #category : 'black' }
MyPawnTests >> testBlackMovesDownLeftWithOponentObstacle [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn black).

	"Sould be able tu eat the opponent on down right"
	board at: 'b3' put: (MyPawn white).

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'b3' ])

	
]

{ #category : 'black' }
MyPawnTests >> testBlackMovesDownLeftWithSameColorObstacle [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c7' put: (pawn := MyPawn black).

	"Souldnt be able tu eat the same color on down left"
	board at: 'b6' put: (MyPawn black).

	squares := pawn targetSquares.
	self assert: (squares allSatisfy: [ :each | each name ~= 'b6' ])

	
]

{ #category : 'black' }
MyPawnTests >> testBlackMovesDownRightWithOponentObstacle [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn black).

	"Sould be able tu eat the opponent on down right"
	board at: 'd3' put: (MyPawn white).

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'd3' ]) 

	
]

{ #category : 'black' }
MyPawnTests >> testBlackMovesDownRightWithSameColorObstacle [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c7' put: (pawn := MyPawn black).

	"Souldnt be able tu eat the same color on down right"
	board at: 'd6' put: (MyPawn black).

	squares := pawn targetSquares.
	self assert: (squares allSatisfy: [ :each | each name ~= 'd6' ])

	
]

{ #category : 'black' }
MyPawnTests >> testBlackPawnCannotGoBackward [

   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e5' put: (pawn := MyPawn black ).

	squares := pawn targetSquares. 
   
	self assert: (squares anySatisfy: [:each | #('e6') includes: each name ]) not

	
]

{ #category : 'black' }
MyPawnTests >> testBlackPawnCannotGoToTheSide [

   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e7' put: (pawn := MyPawn black ).

	squares := pawn targetSquares. 
   
	self assert: (squares anySatisfy: [:each | #('d2' 'f2') includes: each name ]) not

	
]

{ #category : 'black' }
MyPawnTests >> testBlackPawnCannotJumpAboveAnotherBlackPawn [
	self testPawnCannotJumpAboveAnotherPawn: MyPawn black abovePawn: MyPawn black 
]

{ #category : 'black' }
MyPawnTests >> testBlackPawnCannotJumpAboveAnotherWhitePawn [
	self testPawnCannotJumpAboveAnotherPawn: MyPawn black abovePawn: MyPawn white 
]

{ #category : 'black' }
MyPawnTests >> testBlackPawnEnPassantCapture [ 
"Black en passant capture"

    | whitePawn blackPawn board game squares |
	game := MyChessGame freshGame .
	board := game board .
   

    "Get the white pawn at 'b2'"
    blackPawn := (board at: 'b7') contents .

    game move: blackPawn to: blackPawn square down down.
	game move: blackPawn to: blackPawn square down.
    
	whitePawn := (board at: 'c2') contents.
    game move: whitePawn to: whitePawn square up up.

    "Black pawn should be able to capture en passant at 'c3'"
    squares := blackPawn targetSquares.
    self assert: (squares anySatisfy: [ :each | each name = 'c3' ]).

    "Perform the en passant capture"
    game move: blackPawn to: blackPawn square down right.

    "Verify that the black pawn has been captured"
    self assert: (board at: 'c4') isNil.
    self assert: blackPawn square name equals: 'c3'.
]

{ #category : 'black' }
MyPawnTests >> testBorderBlackPawnAtLeftCannotGoAtLeft [
	self testBorderPawnAtLeftCannotGoAtLeft: MyPawn black 
]

{ #category : 'black' }
MyPawnTests >> testBorderBlackPawnAtRightCannotGoAtRight [
	self testBorderPawnAtRightCannotGoAtRight: MyPawn black 
]

{ #category : 'tests' }
MyPawnTests >> testBorderPawnAtLeftCannotGoAtLeft: aMyPawn [

	| board |
	board := MyChessBoard empty.
	board at: 'a4' put: aMyPawn .
	
	aMyPawn targetSquares.


]

{ #category : 'tests' }
MyPawnTests >> testBorderPawnAtRightCannotGoAtRight: aMyPawn [

	| board |
	board := MyChessBoard empty.
	board at: 'h4' put: aMyPawn .
	
	aMyPawn targetSquares.


]

{ #category : 'white' }
MyPawnTests >> testBorderWhitePawnAtLeftCannotGoAtLeft [
	self testBorderPawnAtLeftCannotGoAtLeft: MyPawn white 
]

{ #category : 'white' }
MyPawnTests >> testBorderWhitePawnAtRightCannotGoAtRight [
	self testBorderPawnAtRightCannotGoAtRight: MyPawn white
]

{ #category : 'black' }
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

{ #category : 'white' }
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
MyPawnTests >> testPawnCannotJumpAboveAnotherPawn: aMyPawn abovePawn: aOtherPawn [

	| board squareAfterJump squareAtStart squareOfOponent squares |
	
	squareAtStart := aMyPawn isWhite
		                 ifTrue: [ 'e2' ]
		                 ifFalse: [ 'e7' ].
		
	squareOfOponent := aMyPawn isWhite
		                   ifTrue: [ 'e3' ]
		                   ifFalse: [ 'e6' ].
		
	squareAfterJump := aMyPawn isWhite
		                   ifTrue: [ 'e4' ]
		                   ifFalse: [ 'e5' ].

	board := MyChessBoard empty.
	board at: squareAtStart put: aMyPawn.
	board at: squareOfOponent put: aOtherPawn.

	squares := aMyPawn targetSquares.

	self
		assert: (squares allSatisfy: [ :s | s name ~= squareAfterJump ])
		description: 'The pawn in ' , squareAtStart , ' cannot jump above the pawn in ' , squareOfOponent , ' to go at ' , squareAfterJump
]

{ #category : 'black' }
MyPawnTests >> testRegularMoveForBlack [
	"Pawn should be able to move 1 for their regular move"
   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e7' put: (pawn := MyPawn black).

	squares := pawn targetSquares.
   
	self assert: (squares anySatisfy: [ :each | each name = 'e6' ])
]

{ #category : 'white' }
MyPawnTests >> testRegularMoveForWhite [
	"Pawn should be able to move 1 for their regular move"
   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e2' put: (pawn := MyPawn white).

	squares := pawn targetSquares.

	self assert: (squares anySatisfy: [ :each | each name = 'e3' ])
]

{ #category : 'white' }
MyPawnTests >> testWhiteCannotEatOponentForward [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn white).

	"Sould not pass with a blocking opponent"
	board at: 'c5' put: MyPawn black.

	squares := pawn targetSquares.
	
	self assert: (squares anySatisfy: [ :each | each name = 'c5' ]) not

	
]

{ #category : 'white' }
MyPawnTests >> testWhiteMovesUpLeftWithOponentObstacle [
	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn white).

	"Sould be able tu eat the opponent on top left"
	board at: 'b5' put: (MyPawn black).

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'b5' ])
]

{ #category : 'white' }
MyPawnTests >> testWhiteMovesUpLeftWithSameColorObstacle [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c2' put: (pawn := MyPawn white).

	"Souldnt be able tu eat the same color on up left"
	board at: 'b3' put: (MyPawn black).

	squares := pawn targetSquares.
	self assert: (squares allSatisfy: [ :each | each name ~= 'b3' ])

	
]

{ #category : 'white' }
MyPawnTests >> testWhiteMovesUpRightWithOponentObstacle [
	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c4' put: (pawn := MyPawn white).

	"Sould be able tu eat the opponent on top right"
	board at: 'd5' put: (MyPawn black).

	squares := pawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'd5' ])
]

{ #category : 'white' }
MyPawnTests >> testWhiteMovesUpRightWithSameColorObstacle [

	| pawn squares board |
	board := MyChessBoard empty.
	board at: 'c2' put: (pawn := MyPawn white).

	"Souldnt be able tu eat the same color on up right"
	board at: 'd3' put: (MyPawn black).

	squares := pawn targetSquares.
	self assert: (squares allSatisfy: [ :each | each name ~= 'd3' ])

	
]

{ #category : 'white' }
MyPawnTests >> testWhitePawnCannotGoBackward [

   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e5' put: (pawn := MyPawn white ).

	squares := pawn targetSquares. 
   
	self assert: (squares anySatisfy: [:each | #('e4') includes: each name ]) not

	
]

{ #category : 'white' }
MyPawnTests >> testWhitePawnCannotGoToTheSide [

   | pawn squares board |
   board := MyChessBoard empty.
   board at: 'e2' put: (pawn := MyPawn white).

	squares := pawn targetSquares.
   
	self assert: (squares anySatisfy: [:each | #('d2' 'f2') includes: each name ]) not

	
]

{ #category : 'white' }
MyPawnTests >> testWhitePawnCannotJumpAboveAnotherBlackPawn [
	self testPawnCannotJumpAboveAnotherPawn: MyPawn white abovePawn: MyPawn black 
]

{ #category : 'white' }
MyPawnTests >> testWhitePawnCannotJumpAboveAnotherWhitePawn [
	self testPawnCannotJumpAboveAnotherPawn: MyPawn white abovePawn: MyPawn white
]

{ #category : 'white' }
MyPawnTests >> testWhitePawnEnPassantCapture [
	"White en passant capture"

	| whitePawn blackPawn board game squares |
	game := MyChessGame freshGame.
	board := game board.


	"Get the white pawn at 'b2'"
	whitePawn := (board at: 'b2') contents.

	game move: whitePawn to: whitePawn square up up.
	game move: whitePawn to: whitePawn square up.

	blackPawn := (board at: 'c7') contents.
	game move: blackPawn to: blackPawn square down down.

	"White pawn should be able to capture en passant at 'c6'"
	squares := whitePawn targetSquares.
	self assert: (squares anySatisfy: [ :each | each name = 'c6' ]).

	"Perform the en passant capture"
	game move: whitePawn to: whitePawn square up left.

	"Verify that the black pawn has been captured"
	self assert: (board at: 'c7') isNil.
	self assert: whitePawn square name equals: 'c6'
]
