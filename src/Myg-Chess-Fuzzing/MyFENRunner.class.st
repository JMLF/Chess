Class {
	#name : 'MyFENRunner',
	#superclass : 'PzRunner',
	#category : 'Myg-Chess-Fuzzing',
	#package : 'Myg-Chess-Fuzzing'
}

{ #category : 'running' }
MyFENRunner >> value: input [

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
]
