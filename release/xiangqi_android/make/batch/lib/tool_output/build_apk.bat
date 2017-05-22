set jdkpath=C:\Program Files\Java\jdk1.7.0_45\bin\java.exe
set storepath=release.keystore
set storepass=testres
set keypass=testres
set alias=testres
set zipalign=D:\adt-bundle-windows-x86_64-20140702\sdk\build-tools\20.0.0\zipalign.exe
"%jdkpath%" -jar AndResGuard-cli-1.1.16.jar input.apk -config config.xml -out outapk -signature "%storepath%" "%storepass%" "%keypass%" "%alias%" -zipalign "%zipalign%"