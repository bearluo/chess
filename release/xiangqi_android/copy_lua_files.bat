@echo off

SET TRUNK=%~dp0

SET ASSETS_DIR=%TRUNK%\Android\assets
SET LUA_DIR=%TRUNK%\Resource

pushd %ASSETS_DIR%

if exist scripts (
 	rd /s /Q scripts
	rd /s /Q images
)

xcopy %LUA_DIR%\scripts\*.* scripts\  /e
xcopy %LUA_DIR%\images\*.* images\  /e

popd

echo "Lua files copy finished!"
