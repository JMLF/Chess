# Task1 : Rapport de Refactorisation des Tests MyPawnTests

## 1. Fonctionnalités à Tester pour la Refactorisation

Les principales fonctionnalités des mouvements et règles de capture des pions d'échecs ont été identifiées dans cette refactorisation. Ces fonctionnalités incluent :

- **Mouvement des pions** :
  - Les pions se déplacent d'une case vers l'avant, mais ne peuvent pas se déplacer en arrière ni sur les côtés.
  - Les pions peuvent avancer de deux cases lors de leur premier mouvement depuis leur position initiale.

- **Capturer les pièces adverses** :
  - Les pions capturent en diagonale d'une case vers l'avant (vers le haut pour les pions blancs, vers le bas pour les pions noirs).
  - Les pions ne peuvent pas capturer en avançant droit devant eux ou en diagonale si la case cible est inoccupée ou occupée par un pion de la même couleur.

- **Capture en passant** :
  - Les pions peuvent capturer "en passant" sous certaines conditions (lorsqu'un pion adverse se déplace de deux cases vers l'avant depuis sa position initiale et se retrouve à côté du pion).

- **Limites du plateau** :
  - Les pions placés sur les bords du plateau (colonnes `a` et `h`) ne doivent pas pouvoir sortir des limites du plateau.

- **Sauter par-dessus d'autres pièces** :
  - Les pions ne peuvent pas sauter par-dessus d'autres pièces lorsqu'ils avancent.

## 2. Tests Écrits et Leur Objectif

Les tests suivants ont été écrits pour vérifier la validité de ces fonctionnalités :

### **Mouvements de base des pions**
- `testBlackPawnCannotGoBackward` et `testWhitePawnCannotGoBackward` : Vérifient que les pions ne peuvent pas se déplacer en arrière.
- `testBlackPawnCannotGoToTheSide` et `testWhitePawnCannotGoToTheSide` : Assurent que les pions ne peuvent pas se déplacer latéralement.
- `testFirstMoveForBlack` et `testFirstMoveForWhite` : Vérifient que les pions peuvent avancer de deux cases depuis leur position initiale.
- `testRegularMoveForBlack` et `testRegularMoveForWhite` : Confirment que les pions peuvent avancer d'une seule case.

### **Capturer les pièces adverses**
- `testBlackCannotEatOponentForward` et `testWhiteCannotEatOponentForward` : Vérifient que les pions ne peuvent pas capturer en avançant directement devant eux.
- `testBlackMovesDownLeftWithOponentObstacle`, `testBlackMovesDownRightWithOponentObstacle`, `testWhiteMovesUpLeftWithOponentObstacle`, et `testWhiteMovesUpRightWithOponentObstacle` : Vérifient que les pions peuvent capturer en diagonale lorsqu'une pièce adverse se trouve sur la case cible.
- `testBlackMovesDownLeftWithSameColorObstacle`, `testBlackMovesDownRightWithSameColorObstacle`, `testWhiteMovesUpLeftWithSameColorObstacle`, et `testWhiteMovesUpRightWithSameColorObstacle` : Assurent que les pions ne peuvent pas capturer des pièces de la même couleur en diagonale.

### **Restrictions aux bords du plateau**
- `testBorderBlackPawnAtLeftCannotGoAtLeft`, `testBorderBlackPawnAtRightCannotGoAtRight`, `testBorderWhitePawnAtLeftCannotGoAtLeft`, et `testBorderWhitePawnAtRightCannotGoAtRight` : Vérifient que les pions situés sur les bords du plateau ne peuvent pas sortir des limites.

### **Sauter par-dessus d'autres pièces**
- `testBlackPawnCannotJumpAboveAnotherBlackPawn`, `testBlackPawnCannotJumpAboveAnotherWhitePawn`, `testWhitePawnCannotJumpAboveAnotherBlackPawn`, et `testWhitePawnCannotJumpAboveAnotherWhitePawn` : Vérifient que les pions ne peuvent pas sauter par-dessus d'autres pièces (de la même couleur ou adverses).

### **Capture en passant**
- `testBlackPawnEnPassantCapture` et `testWhitePawnEnPassantCapture` : Vérifient que les pions peuvent correctement effectuer une capture en passant lorsque les conditions sont réunies.

### **Conditions aux frontières**
- `testBlackPawnCannotMoveForwardOutsideTheBoard` et `testWhitePawnCannotMoveForwardOutsideTheBoard` : Assurent que les pions ne peuvent pas sortir du plateau lorsqu'ils atteignent la dernière rangée.

### **Autres Tests**
- `testId` : Un simple test pour vérifier que l'identifiant du pion est correctement représenté.

## 3. Tests Non Écrits et Pourquoi

- **Cas limites avec la promotion** : 
  - Aucun test n'a été écrit pour la promotion des pions (lorsqu'un pion atteint la dernière rangée). Cette fonctionnalité n'est pas incluse dans la portée de cette refactorisation, car les méthodes se concentrent uniquement sur les mouvements réguliers, la capture et la capture en passant.

- **Tests liés au timing** : 
  - Aucun test n'a été écrit pour les conditions basées sur les tours (comme s'assurer que le pion ne peut se déplacer qu'au tour de son joueur), car ces vérifications relèveraient de la logique du jeu plutôt que des règles de mouvement d'un seul pion.

