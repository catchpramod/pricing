SET spath=%~dp0
echo %spath:~0,-1%
cd %spath%
cmd /k python DumpPayerCompass.py