@echo off
call config.bat

echo ��scriptĿ¼�£����������ļ�

echo main.lua�������������ļ�������״̬����ʼ״̬
::main.lua
pushd %LUA_DIR%\core
echo --���ļ������������ɣ�������Ϊ���ļ�  > %LUA_DIR%\main.lua
echo --Note�����ļ��� ANSI ���룬ע���Լ�תΪUTF-8 >> %LUA_DIR%\main.lua
echo. >> %LUA_DIR%\main.lua
echo require^("config"^) >> %LUA_DIR%\main.lua
for /r %%i in (*.lua) do (
	echo require^("core/%%~ni"^)  >> %LUA_DIR%\main.lua
)
popd

echo config.lua�����������ļ�����������һЩȫ������
::config.lua
echo --���ļ������������ɣ�������Ϊ�����ļ�  > %LUA_DIR%\config.lua
echo --Note�����ļ��� ANSI ���룬ע���Լ�תΪUTF-8 >> %LUA_DIR%\config.lua
echo. >> %LUA_DIR%\config.lua
echo -- ResConfig is a global val to config res path and format for multi-platform.  >> %LUA_DIR%\config.lua
echo ResConfig = {} >> %LUA_DIR%\config.lua
echo ResConfig.Path = nil >> %LUA_DIR%\config.lua
echo ResConfig.FormatFileMap = {} >> %LUA_DIR%\config.lua
echo ResConfig.FormatFolderMap = {} >> %LUA_DIR%\config.lua
echo -- LanguageConfig is a global val to config language for multi-platform.  >> %LUA_DIR%\config.lua
echo LanguageConfig = {} >> %LUA_DIR%\config.lua
echo LanguageConfig.isZhHant = false; >> %LUA_DIR%\config.lua

echo statesConfig.lua��״̬�����ļ�����core/stateMachine�����ã����״̬��ת
::statesConfig.lua
echo --���ļ������������ɣ�������Ϊ״̬�����ļ���core/stateMachine.lua ��������һ�ļ�������ύ > %LUA_DIR%\statesConfig.lua
echo --Note�����ļ��� ANSI ���룬ע���Լ�תΪUTF-8 >> %LUA_DIR%\statesConfig.lua
echo. >> %LUA_DIR%\statesConfig.lua

echo States = >> %LUA_DIR%\statesConfig.lua
echo { >> %LUA_DIR%\statesConfig.lua
echo }; >> %LUA_DIR%\statesConfig.lua

echo StatesMap = >> %LUA_DIR%\statesConfig.lua
echo { >> %LUA_DIR%\statesConfig.lua
echo }; >> %LUA_DIR%\statesConfig.lua

pause