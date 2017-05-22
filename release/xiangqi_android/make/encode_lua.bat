@echo on
call config.bat

pushd %LUA_DIR%\..

if exist scripts_encoded (
	del /q scripts_encoded\*.* 
) else (
	mkdir scripts_encoded
)

xcopy %LUA_DIR%\*.* scripts_encoded /E /s

popd

pushd %LUA_DIR%\..\scripts_encoded

for /r %%i in (*.lua) do (
	%TOOL_ENCODE% %%~fi
	del %%~fi
	rename %%~dpi%%~ni.bylua %%~ni.lua
)

popd

echo "All Lua files encoded!"
echo "The encoded files is in script_encoded folder which is in the same directory as scripts"
pause

 
