@echo off
rem ��ȡ������
for /f "tokens=1-15" %%a in (a.txt) do (
    call build_apk.bat %%a %%b %%c %%d %%e %%f %%g %%h %%i %%j %%k %%l %%m
)