@echo off
del lib\package.properties
set package_name=%~nx1
set package_dir=%~dp1
echo %package_dir%
echo %package_name%
(echo apk.package.dir=%package_dir:\=\\%)>>lib\package.properties
(echo apk.package.name=%package_name:\=\\%)>>lib\package.properties

del lib\local.properties
(echo local.properties.apktool.dir=%package_dir:\=\\%)>>lib\local.properties

call ant auto-batch-decode

pause