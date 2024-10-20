Class {
	#name : 'FENOracle',
	#superclass : 'Object',
	#instVars : [
		'pythonPath',
		'scriptPath'
	],
	#category : 'Myg-Chess-FenOracle',
	#package : 'Myg-Chess-FenOracle'
}

{ #category : 'initialization' }
FENOracle >> initialize [ 
    super initialize.
    pythonPath := '/home/marius/Documents/fac/Chess/FENOracle/venv/bin/python'. "Need to be in venv in order to access python-chess package"
	 scriptPath := '/home/marius/Documents/fac/Chess/FENOracle/validate_fen.py'.
]

{ #category : 'as yet unclassified' }
FENOracle >> validateFEN: aFENString [

    | command output |

    "Bild command: python validate_fen.py eFENString"
    command := pythonPath , ' ' , scriptPath , ' "' , aFENString , '"' .

    "Run comand"
    output := LibC resultOfCommand: command.

    "Debug display"
    Transcript show: 'Commande: ', command; cr.
    Transcript show: 'Sortie: ', output; cr.

    "Return if valid or not"
    (output beginsWith: 'VALID') ifTrue: [ ^ true ].
    (output beginsWith: 'INVALID') ifTrue: [
        Transcript
            show: 'FEN invalide: ', aFENString , ' - Raison: ', output;
            cr.
        ^ false
    ].
    ^ false

]
