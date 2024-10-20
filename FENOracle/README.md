# Local oracle for FEN  strings
We use python-chess package.

Installation :
```bash
python3 -m venv venv
source venv/bin/activate
pip install python-chess
```

Usage :
```bash
source venv/bin/activate
python3 validate_fen.py your-fen-string
```

Example: `python3 validate_fen.py "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" #VALID`
