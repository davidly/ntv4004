@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0" || exit /b 1
cl /nologo /std:c++14 /EHsc /O2 /Ob3 /GL /W4 /D_CRT_SECURE_NO_WARNINGS ntv4004.cxx i4004.cxx /Fe:ntv4004.exe /link /LTCG
set "result=%errorlevel%"
if "%result%"=="0" (
    cl /nologo /std:c++14 /EHsc /O2 /Ob3 /GL /W4 /D_CRT_SECURE_NO_WARNINGS intel\pdp10.cxx /Fe:intel\pdp10.exe /link /LTCG
    set "result=!errorlevel!"
)
popd
exit /b %result%
