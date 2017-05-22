@echo off
call config.bat

pushd %LUA_DIR%\..

if exist scripts_compiled (
	del /q scripts_compiled\*.* 
) else (
	mkdir scripts_compiled
)

xcopy %LUA_DIR%\*.* scripts_compiled /E /s

popd

pushd %LUA_DIR%\..\scripts_compiled


for /r %%i in (*.lua) do (
	echo %%i
	%TOOL_LUAC% -s -o %%~dpi\%%~nxi %%i 
)

popd

echo "Lua files compiled!"
echo "The compiled files is in script_compiled folder which is in the same directory as scripts"
pause

 
