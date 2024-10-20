import sys
import chess

def main():
    if len(sys.argv) != 2:
        print("Usage: python validate_fen.py '<FEN_STRING>'")
        sys.exit(1)
    
    fen = sys.argv[1]
    try:
        board = chess.Board(fen)
        if board.is_valid():
            print("VALID")
        else:
            status = board.status()
            errors = []
            if status & chess.STATUS_NO_WHITE_KING:
                errors.append("No white king")
            if status & chess.STATUS_NO_BLACK_KING:
                errors.append("No black king")
            if status & chess.STATUS_TOO_MANY_KINGS:
                errors.append("Too many kings")
            if status & chess.STATUS_TOO_MANY_WHITE_PAWNS:
                errors.append("Too many white pawns")
            if status & chess.STATUS_TOO_MANY_BLACK_PAWNS:
                errors.append("Too many black pawns")
            if status & chess.STATUS_PAWNS_ON_BACKRANK:
                errors.append("Pawns on back rank")
            if status & chess.STATUS_TOO_MANY_WHITE_PIECES:
                errors.append("Too many white pieces")
            if status & chess.STATUS_TOO_MANY_BLACK_PIECES:
                errors.append("Too many black pieces")
            if status & chess.STATUS_BAD_CASTLING_RIGHTS:
                errors.append("Bad castling rights")
            if status & chess.STATUS_INVALID_EP_SQUARE:
                errors.append("Invalid en passant square")
            if status & chess.STATUS_OPPOSITE_CHECK:
                errors.append("Opposite check")
            if status & chess.STATUS_EMPTY:
                errors.append("Empty board")
            if status & chess.STATUS_RACE_CHECK:
                errors.append("Race check")
            if status & chess.STATUS_RACE_OVER:
                errors.append("Race over")
            if status & chess.STATUS_RACE_MATERIAL:
                errors.append("Race material")
            if status & chess.STATUS_TOO_MANY_CHECKERS:
                errors.append("Too many checkers")
            if status & chess.STATUS_IMPOSSIBLE_CHECK:
                errors.append("Impossible check")
            
            print("INVALID: " + ", ".join(errors))
    except ValueError as e:
        print("INVALID: " + str(e))

if __name__ == "__main__":
    main()
