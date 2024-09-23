Class {
	#name : 'MyQueenTests',
	#superclass : 'TestCase',
	#category : 'Myg-Chess-Tests',
	#package : 'Myg-Chess-Tests'
}

{ #category : 'tests' }
MyQueenTests class >> testId [
	self assert: MyQueen new id equals: 'P'
]

{ #category : 'tests' }
MyQueenTests >> testId [
	self assert: MyQueen new id equals: 'Q'
]
