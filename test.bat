@echo off
rem Build, then run the CPU, assembler and INTERP/4 tests. The last two skip
rem without Intel's images (see intel\README.md).
setlocal
pushd "%~dp0" || exit /b 1
call m.bat || goto failed
if "%PYTHON%"=="" set "PYTHON=python"
for %%t in (cpu asm interp) do (
    "%PYTHON%" tests\%%t.py || goto failed
)
popd
exit /b 0
:failed
set "result=%errorlevel%"
popd
exit /b %result%
