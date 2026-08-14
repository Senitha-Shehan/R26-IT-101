Option 1: Run directly using .venv Python executable
powershell
.\.venv\Scripts\python.exe api/main.py
or

powershell
.\.venv\Scripts\python.exe -m uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload
Option 2: Activate .venv first
powershell
.\.venv\Scripts\Activate.ps1
python api/main.py
