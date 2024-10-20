Class {
	#name : 'FENOracle',
	#superclass : 'Object',
	#instVars : [
		'pythonScriptPath'
	],
	#category : 'Myg-Chess-FenOracle',
	#package : 'Myg-Chess-FenOracle'
}

{ #category : 'initialization' }
FENOracle >> initialize [ 
    super initialize.
    pythonScriptPath := '../FENOracle/validate_fen.py'. 
]
