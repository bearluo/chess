rem 读取所有列
for /f "tokens=1-15" %%a in (a.txt) do (
    call lib\build_apk.bat %%a %%b %%c %%d %%e %%f %%g %%h %%i %%j %%k %%l %%m
)
pause