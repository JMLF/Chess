Class {
	#name : 'MyFENGame',
	#superclass : 'Object',
	#instVars : [
		'board',
		'sideToMove',
		'players',
		'enPassantTargetSquare',
		'halfMoveClock',
		'moveCount',
		'white',
		'black'
	],
	#category : 'Myg-Chess-Importers',
	#package : 'Myg-Chess-Importers'
}

{ #category : 'accessing' }
MyFENGame >> board [
	^ board
]

{ #category : 'accessing' }
MyFENGame >> castlingAbility: aCollection [

	aCollection do: [ :castling |
		castling = 'K' ifTrue: [ white canCastleKingside ].
		castling = 'Q' ifTrue: [ white canCastleQueenside ].
		castling = 'k' ifTrue: [ black canCastleKingside ].
		castling = 'q' ifTrue: [ black canCastleQueenside ] ]
]

{ #category : 'accessing' }
MyFENGame >> enPassantTargetSquare: aString [ 
	enPassantTargetSquare := aString
]

{ #category : 'accessing' }
MyFENGame >> halfMoveClock: anInteger [ 
	halfMoveClock := anInteger
]

{ #category : 'accessing' }
MyFENGame >> moveCount [
	^ moveCount
]

{ #category : 'accessing' }
MyFENGame >> moveCount: anInteger [ 
	moveCount := anInteger
]

{ #category : 'as yet unclassified' }
MyFENGame >> ranks: aCollection [
    "Initialise le board à partir d'une collection de collections représentant les rangées d'échecs.
    Les chiffres dans les collections représentent des cases vides à étendre."

    | board columnLetters expandedCollection |
    board := Dictionary new.
    columnLetters := $a to: $h.

    "Pour chaque rangée, étendre les chiffres en cases vides"
    expandedCollection := aCollection reversed collect: [:rankPieces |
        | expandedPieces |
        expandedPieces := OrderedCollection new.
        rankPieces do: [:item |
            (item isCharacter and: [item isDigit])
                ifTrue: [
                    (item digitValue) timesRepeat: [expandedPieces add: 'empty']
                ]
                ifFalse: [
                                       (item = 'empty') 
                        ifTrue: [expandedPieces add: 'empty']
                        ifFalse: [expandedPieces add: item]
                ].
        ].
        expandedPieces
    ].

    "Vérifier que chaque rangée a exactement 8 éléments après expansion"
    expandedCollection doWithIndex: [:rankPieces :rank |
        (rankPieces size = 8) ifFalse: [
            self error: 'La taille ne fait pas 8' ].
        rankPieces with: columnLetters do: [:piece :column |
            board at: (column asString , rank asString) put: piece
        ].
    ].

    ^ board

]

{ #category : 'accessing' }
MyFENGame >> ranksback: aCollection [

	board := Dictionary new.
	aCollection reversed with: (1 to: 8) do: [ :rankPieces :rank |
		rankPieces with: ($a to: $h) do: [ :piece :column |
			board at: column asString , rank asString put: piece ] ]
]

{ #category : 'accessing' }
MyFENGame >> sideToMove [
	^ sideToMove
]

{ #category : 'accessing' }
MyFENGame >> sideToMove: aString [ 
	sideToMove := aString
]
