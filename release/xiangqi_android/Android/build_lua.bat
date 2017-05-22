@echo on

SET TRUNK=%~dp0
pushd %TRUNK%
cd ..

SET TOOLS=%TRUNK%\..\tools
SET TOOL_LUAC=%TOOLS%\luac.exe
SET TOOL_ENCODE=%TOOLS%\BinaryEncoder.exe
rem goto compile_lua
rem goto encode_lua
echo "copy new images"

rd %TRUNK%\assets\scripts /s /q
rd %TRUNK%\assets\images /s /q
rd %TRUNK%\assets\audio /s /q

xcopy Resource\images\*.* %TRUNK%\assets\images\  /e /d /q /y
xcopy Resource\scripts\*.* %TRUNK%\assets\scripts\  /e /d /q /y
xcopy Resource\audio\*.ogg %TRUNK%\assets\audio\  /e /d /q /y
xcopy Resource\scripts\*.* scripts_back\  /e /d /q /y

:compile_lua
echo "compile_lua"

pushd %TRUNK%\assets\scripts\

for /r %%i in (*.lua) do (
	echo %%i
	%TOOL_LUAC% -s -o %%~dpi\%%~nxi %%i 
)

popd
echo "Lua files compiled!"
echo "The compiled files is in script_compiled folder which is in the same directory as scripts"
:encode_lua
echo "encode_lua"
pushd %TRUNK%\assets\scripts\
for /r %%i in (*.lua) do (
	echo %%i
	%TOOL_ENCODE% %%~fi
	del %%~fi
	rename %%~dpi%%~ni.bylua %%~ni.lua
)
echo "All Lua files encoded!"
echo "The encoded files is in script_encoded folder which is in the same directory as scripts"
popd
pause
