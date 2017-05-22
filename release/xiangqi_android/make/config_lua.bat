@echo off
call config.bat

echo 在script目录下，生成以下文件

echo main.lua：程序的主入口文件，进入状态机初始状态
::main.lua
pushd %LUA_DIR%\core
echo --此文件由批处理生成，用于作为主文件  > %LUA_DIR%\main.lua
echo --Note：此文件是 ANSI 编码，注意自己转为UTF-8 >> %LUA_DIR%\main.lua
echo. >> %LUA_DIR%\main.lua
echo require^("config"^) >> %LUA_DIR%\main.lua
for /r %%i in (*.lua) do (
	echo require^("core/%%~ni"^)  >> %LUA_DIR%\main.lua
)
popd

echo config.lua：工程配置文件，可用来做一些全局配置
::config.lua
echo --此文件由批处理生成，用于作为配置文件  > %LUA_DIR%\config.lua
echo --Note：此文件是 ANSI 编码，注意自己转为UTF-8 >> %LUA_DIR%\config.lua
echo. >> %LUA_DIR%\config.lua
echo -- ResConfig is a global val to config res path and format for multi-platform.  >> %LUA_DIR%\config.lua
echo ResConfig = {} >> %LUA_DIR%\config.lua
echo ResConfig.Path = nil >> %LUA_DIR%\config.lua
echo ResConfig.FormatFileMap = {} >> %LUA_DIR%\config.lua
echo ResConfig.FormatFolderMap = {} >> %LUA_DIR%\config.lua
echo -- LanguageConfig is a global val to config language for multi-platform.  >> %LUA_DIR%\config.lua
echo LanguageConfig = {} >> %LUA_DIR%\config.lua
echo LanguageConfig.isZhHant = false; >> %LUA_DIR%\config.lua

echo statesConfig.lua：状态配置文件，在core/stateMachine中引用，完成状态跳转
::statesConfig.lua
echo --此文件由批处理生成，用于作为状态配置文件，core/stateMachine.lua 会引用这一文件，务必提交 > %LUA_DIR%\statesConfig.lua
echo --Note：此文件是 ANSI 编码，注意自己转为UTF-8 >> %LUA_DIR%\statesConfig.lua
echo. >> %LUA_DIR%\statesConfig.lua

echo States = >> %LUA_DIR%\statesConfig.lua
echo { >> %LUA_DIR%\statesConfig.lua
echo }; >> %LUA_DIR%\statesConfig.lua

echo StatesMap = >> %LUA_DIR%\statesConfig.lua
echo { >> %LUA_DIR%\statesConfig.lua
echo }; >> %LUA_DIR%\statesConfig.lua

pause