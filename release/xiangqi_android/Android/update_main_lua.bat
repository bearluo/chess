set LUA_MAIN_FILE = "assets\scripts\main.lua"
set LUA_MAIN_FILE_COPY = "..\make\main.lua"

set APPID_COPY = APPID
set APPKEY_COPY = APPKEY
set BID_COPY = BID
set SID_COPY = SID
set LOGINTYPE_COPY = LOGINGTYPE

(for /f  %%i in ('type "%a%"') do (
set s=%%i
call set s=!s:%APPID_COPY%=%APPID%!
call set s=!s:%APPKEY_COPY%=%APPKEY%!
call set s=!s:%BID_COPY%=%BID%!
call set s=!s:%SID_COPY%=%SID%!
call set s=!s:%LOGINTYPE_COPY%=%LOGINTYPE%!
echo !s!))>"%b%"