@echo off
set channelConfig_path=assets\scripts\channelConfig.lua

echo #################渠道打包工具v2.0.0 by bearluo ################
set APPID=%1
set APPKEY=%2
set BID=%3
set UMENG_CHANNEL=%4
set PROJECT_RELEASE=%5
set GETUI_CHANNEL=%6
if %1@==@ (
	set APPID=0
) else (
	set APPID=%1
)
if %2@==@ (
	set APPKEY=0
) else (
	set APPKEY=%2
)
if %3@==@ (
	set BID=_empty
) else (
	set BID=%3
)
if %4@==@ (
	set UMENG_CHANNEL=0
) else (
	set UMENG_CHANNEL=%4
)
if %5@==@ (
	set PROJECT_RELEASE=release
) else (
	set PROJECT_RELEASE=%5
)
if %6@==@ (
	set GETUI_CHANNEL=0
) else (
	set GETUI_CHANNEL=%6
)
if %7@==@ (
	set SID=PhpConfig.SID_GOOGLEPLAY
) else (
	set SID=%7
)
if %8@==@ (
	set LOGINTYPE=PhpConfig.TYPE_YOUKE
) else (
	set LOGINTYPE=%8
)
del ant.properties
(echo #)>>ant.properties
(echo #)>>ant.properties	
(echo #	Ant Build Config)>>ant.properties
(echo #)>>ant.properties
(echo #)>>ant.properties
(echo #key store)>>ant.properties
(echo key.store=chinesechess)>>ant.properties
(echo key.alias=chinesechess)>>ant.properties
(echo key.store.password=chinesechess)>>ant.properties
(echo key.alias.password=chinesechess)>>ant.properties
(echo #out.dir The name of the output directory. Default is 'bin'.)>>ant.properties
(echo out.apk=apk)>>ant.properties
(echo APPID=%APPID%)>>ant.properties
(echo APPKEY=%APPKEY%)>>ant.properties
(echo BID=%BID%)>>ant.properties
(echo UMENG_CHANNEL=%UMENG_CHANNEL%)>>ant.properties
(echo PROJECT_RELEASE=%PROJECT_RELEASE%)>>ant.properties
(echo GETUI_CHANNEL=%GETUI_CHANNEL%)>>ant.properties
(echo SID=%SID%)>>ant.properties
(echo LOGINTYPE=%LOGINTYPE%)>>ant.properties

del %channelConfig_path%
(echo kAppid = %APPID%)>>%channelConfig_path%
(echo kAppkey = %APPKEY%)>>%channelConfig_path%
(echo kBid = %BID%)>>%channelConfig_path%
(echo kSid = %SID%)>>%channelConfig_path%
(echo kTypePar = %LOGINTYPE%)>>%channelConfig_path%


SET TRUNK=%~dp0
pushd %TRUNK%
SET TOOLS=%TRUNK%\..\tools
SET TOOL_LUAC=%TOOLS%\luac.exe
SET TOOL_ENCODE=%TOOLS%\BinaryEncoder.exe
copy %channelConfig_path% %channelConfig_path%.tmp /y
echo compile_lua %channelConfig_path%
%TOOL_LUAC% -o %channelConfig_path% %channelConfig_path% 
echo encode_lua %channelConfig_path%
%TOOL_ENCODE% %channelConfig_path%
del %channelConfig_path%
rename %TRUNK%\assets\scripts\channelConfig.bylua channelConfig.lua
rem call update_project.bat
call ant auto-%PROJECT_RELEASE%
pause
