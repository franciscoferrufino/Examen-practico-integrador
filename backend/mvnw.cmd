@echo off
setlocal

REM Configurar JAVA_HOME automaticamente si no esta definido o no contiene javac.exe
if not exist "%JAVA_HOME%\bin\javac.exe" (
    if exist "C:\Program Files\JetBrains\IntelliJ IDEA 2025.1.1.1\jbr\bin\javac.exe" (
        set "JAVA_HOME=C:\Program Files\JetBrains\IntelliJ IDEA 2025.1.1.1\jbr"
    ) else if exist "C:\Program Files\Java\jdk-21\bin\javac.exe" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-21"
    ) else if exist "C:\Program Files\Java\jdk-17\bin\javac.exe" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-17"
    )
)

set "PATH=%JAVA_HOME%\bin;%PATH%"

REM Localizar Maven en PATH o en cache de Maven Wrapper
where mvn.cmd >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    call mvn.cmd %*
    exit /b %ERRORLEVEL%
)

set "MVN_WRAPPER_CMD=%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.14\ed7edd442f634ac1c1ef5ba2b61b6d690b5221091f1a8e1123f5fadcc967520d\bin\mvn.cmd"
if exist "%MVN_WRAPPER_CMD%" (
    call "%MVN_WRAPPER_CMD%" %*
    exit /b %ERRORLEVEL%
)

set "MVN_WRAPPER_CMD_ALT=%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.9-bin\4nf9hui3q3djbarqar9g711ggc\apache-maven-3.9.9\bin\mvn.cmd"
if exist "%MVN_WRAPPER_CMD_ALT%" (
    call "%MVN_WRAPPER_CMD_ALT%" %*
    exit /b %ERRORLEVEL%
)

echo Error: No se encontro Apache Maven instalado ni en ~/.m2/wrapper/dists.
exit /b 1
