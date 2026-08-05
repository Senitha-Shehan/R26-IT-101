@echo off
cd /d "%~dp0"
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install tensorflow==2.16.2 pillow==12.3.0
