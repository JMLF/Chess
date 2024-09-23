Class {
	#name : 'MyKnightTests',
	#superclass : 'TestCase',
	#category : 'Myg-Chess-Tests',
	#package : 'Myg-Chess-Tests'
}

{ #category : 'tests' }
MyKnightTests >> testId [
	self assert: MyKnight new id equals: 'N'
]
