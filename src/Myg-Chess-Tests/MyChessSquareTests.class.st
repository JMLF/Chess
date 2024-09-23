Class {
	#name : 'MyChessSquareTests',
	#superclass : 'TestCase',
	#category : 'Myg-Chess-Tests',
	#package : 'Myg-Chess-Tests'
}

{ #category : 'tests' }
MyChessSquareTests >> testDownReturnRightSquare [

	| square board |
	board := MyChessBoard empty.

	square := board at: 'd5'.

	self assert: square down equals: square + (0 @ -1)
]

{ #category : 'tests' }
MyChessSquareTests >> testLeftReturnRightSquare [

	| square board |
	board := MyChessBoard empty.

	square := board at: 'd5'.

	self assert: square left equals: square + (-1 @ 0)
]

{ #category : 'tests' }
MyChessSquareTests >> testRightReturnRightSquare [

	| square board |
	board := MyChessBoard empty.

	square := board at: 'd5'.

	self assert: square right equals: square + (1 @ 0)
]

{ #category : 'tests' }
MyChessSquareTests >> testUpReturnRightSquare [

	| square board |
	board := MyChessBoard empty.

	square := board at: 'd5'.

	self assert: square up equals: square + (0 @ 1)
]
