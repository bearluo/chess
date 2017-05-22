compile_lua.bat 编译lua为字节码，结果放在 scripts_compile 中
encode_lua.bat 为lua加密，结果放在scripts_encode 文件夹中
如果要先编译再加密，那就要先运行 compile_lua.bat 把 scripts_compile  改为 scripts 再运行 encode_lua.bat