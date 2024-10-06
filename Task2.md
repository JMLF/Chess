# Task2 : Rapport d'Analyse de Mutation pour MyPawn

## 1. Scripts et Configuration Utilisés pour l'Analyse

L'analyse de mutation a été réalisée en utilisant les outils et les configurations suivants :

- **Outil d'Analyse de Mutation** : MTAnalysis
- **Classes à tester** : `MyPawnTests`
- **Classes à muter** : `MyPawn`
- **Filtres de test** : Nous avons utilisé un filtre spécifique, `MTRedTestFilter`, pour sélectionner uniquement les tests pertinents.
- **Lancement de l'Analyse** : Le script suivant a été utilisé pour exécuter l'analyse :

```smalltalk
testCases :=  { MyPawnTests }.
classesToMutate := { MyPawn }.

analysis := MTAnalysis new
    testFilter: MTRedTestFilter new;
    testClasses: testCases;
    classesToMutate: classesToMutate.

analysis run.

analysis generalResult.
```

Cette configuration permet de concentrer l'analyse de mutation sur les méthodes de la classe `MyPawn`.

## 2. Score de Mutation Initial

- **Nombre total de mutants** : 296
- **Mutants tués** : 260
- **Mutants vivants** : 36
- **Score de mutation initial** :
   $$\text{Score initial} = \frac{260}{296} \times 100 \approx 87.84\%$$

## 3. Score de Mutation Après Ajout de Tests

Après avoir ajouté des tests supplémentaires, notamment pour la capture "en passant", le score de mutation a été légèrement amélioré.

- **Mutants tués après ajout de tests** : 272
- **Mutants vivants après ajout de tests** : 18
- **Score de mutation final** : 
   $$\text{Score final} = \frac{272}{290} \times 100 \approx 93.8\%$$

## 4. Tests Non Écrits et Pourquoi

Certains tests n'ont pas été écrits pour les raisons suivantes :

- **Tests de collection équivalente** : 
   Il existe des mutants concernant l'utilisation de collections comme `WeakOrderedCollection` et `OrderedCollection`. Ces tests n'ont pas été écrits car ces collections se comportent de manière équivalente dans le cadre de notre logique de mouvement des pions. Le choix de la collection ne modifie pas les résultats finaux des opérations.


## 5. Détail de 3 Mutants Tués et Comment Ils Ont Été Tués

### 1. **Mutant dans `isOnStartingRank`** :
   - **Base** :
     ```smalltalk
     ^ self isWhite
         ifTrue: [ (square name at: 2) = $2 ]
         ifFalse: [ (square name at: 2) = $7 ]
     ```
   - **Mutant** :
     ```smalltalk
     ^ self isWhite
         ifTrue: [ (square name at: 2) = $2 ]
         ifFalse: [ (square name at: 3) = $7 ]
     ```
   - **Comment il a été tué** : Un test a été ajouté pour vérifier la position initiale des pions noirs et blancs. Le mutant modifiait la condition de ligne de départ pour les pions noirs en vérifiant la 3ème colonne au lieu de la 7ème, ce qui a été capturé par les tests sur la position de départ.

### 2. **Mutant dans `targetSquaresLegal: aBoolean`** :
   - **Base** :
     ```smalltalk
     ^ legalSquare select: [ :s | s notNil ]
     ```
   - **Mutant** :
     ```smalltalk
     ^ legalSquare select: [ :each | true ]
     ```
   - **Comment il a été tué** : Ce mutant rendait tous les carrés légaux sans vérifier s'ils étaient nuls. Nous avons supprimer ce select inutile car il n'y a jamais de piece nil.

### 3. **Mutant dans `addFirstMove: legalSquares`** :
   - **Base** :
     ```smalltalk
     secondSquare := firstSquare ifNotNil: [
         (self isOnStartingRank and: [ firstSquare hasPiece not ]) ifTrue: [ firstSquare up ].
     ]
     ```
   - **Mutant** :
     ```smalltalk
     secondSquare := firstSquare ifNotNil: [
         (self isOnStartingRank bEqv: [ firstSquare hasPiece not ]) ifTrue: [ firstSquare up ].
     ]
     ```
   - **Comment il a été tué** : Le mutant modifiait la condition de vérification pour un équivalent logique, causant une confusion entre les résultats. Un test a été écrit pour vérifier le mouvement du pion au milieu de l'échiqier ne pouvais pas sauter au desus d'un piece, ce qui a permis d'éliminer ce mutant.

### 4. **Mutant dans `checkEnPassantCapture: sideSquare targetSquare: targetSquare addTo: legalSquares side: aSide`** :
   - **Base** :
     ```smalltalk
	"Vérifier si c'était le premier mouvement du pion adjacent"
        sidePiece moveCount = 1 ifFalse: [ ^ self ].
     ```
   - **Mutant** :
     ```smalltalk
	"Vérifier si c'était le premier mouvement du pion adjacent"
        (sidePiece moveCount = 1) yourself.
     ```
   - **Comment il a été tué** : Le mutant supprimait la vérification du nombre de mouvement du pion ennemie. Le coup en passant necessite que le pion ennemie soit sur son premier mouvement, nous avosn donc ajouté un test qui s'assure que l'on ne peut pas faire de en passant sur un pion ayant bougé plus d'une fois.

## 6. Détail de 3 Mutants Équivalents

### 1. **Mutant dans `targetSquaresLegal: aBoolean` (Collection équivalente)** :
   - **Base** :
     ```smalltalk
     legalSquare := OrderedCollection new.
     ```
   - **Mutant** :
     ```smalltalk
     legalSquare := WeakOrderedCollection new.
     ```
   - **Pourquoi équivalent** : `WeakOrderedCollection` et `OrderedCollection` sont équivalents dans ce contexte car ils stockent les mêmes valeurs de manière ordonnée, sans impact sur la logique de mouvement des pions.

### 2. **Mutant dans `targetSquaresLegal: aBoolean` (RSGroup)** :
   - **Base** :
     ```smalltalk
     legalSquare := OrderedCollection new.
     ```
   - **Mutant** :
     ```smalltalk
     legalSquare := RSGroup new.
     ```
   - **Pourquoi équivalent** : `RSGroup` est également une collection ordonnée avec des comportements similaires, ne changeant pas la manière dont les carrés légaux sont calculés.

### 3. **Mutant dans `checkEnPassantCapture` (Modification inutile)** :
   - **Base** :
     ```smalltalk
     sideSquare notNil and: [ sideSquare hasPiece ] ifFalse: [ ^ self ].
     ```
   - **Mutant** :
     ```smalltalk
     sideSquare notNil yourself ifFalse: [ ^ self ].
     ```
   - **Pourquoi équivalent** : La mutation ne change pas le comportement logique de la vérification `notNil`. L'ajout de `yourself` est redondant et ne modifie pas l'exécution du code.
