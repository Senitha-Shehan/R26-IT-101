@echo off
cd /d "C:\Sliit\Year 4 Semester 1\cropguard-regional-automl"
py -3.10 -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install tensorflow==2.16.2
