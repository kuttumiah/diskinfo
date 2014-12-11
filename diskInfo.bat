@Echo %dbg%Off
::
:: DiskInfo Script Version 0.1
:: Developed by Robaiatul Islam Shaon
:: on 13 September 2014
::
:: This Script Lists Disk Information using Diskpart
:: logs the information of diskspace, usedspace, freespace for any specified removable device
:: Important: In order to make this Script work please run "cmd.exe" as Administrator before call it
::
:: Changelog:
:: ----------
::
:: v0.1
:: 1. Initial Release

TITLE DiskInfo
SetLocal EnableDelayedExpansion

set _lstVol=%temp%.\~lstVol.txt
set _writeVBS=%temp%.\~writeVBS.vbs

::COLOR 2F
COLOR 1B
CLS
echo ===============================================================================
echo.         
Echo              _            _    _                  _          _
Echo             ^| ^|  __      ^|_^|_ ^|_^|_               ^|_^|        ^| ^|
Echo             ^| ^| / /^ _  _ ^|_^|_^|^|_^|_^| _  _  __  __  _  _____  ^| ^|___
Echo             ^| ^|/ / ^| ^|^| ^|^| ^|  ^| ^|  ^| ^|^| ^|^| _\/_ ^|^| ^| \__  \ ^|  _  ^|
Echo             ^| ^|\ \ ^| ^|^| ^|^| ^|__^| ^|__^| ^|^| ^|^| ^|  ^| ^|^| ^| _/ __ \^| ^| ^| ^|
Echo             ^|_^| \_\^|____^|^|___/^|___/^|____^|^|_^|  ^|_^|^|_^|(____  /^|_^| ^|_^|
Echo                                                         \/
echo.                             DiskInfo Version 0.1
echo ===============================================================================

:checkPrivileges
mkdir "%windir%\AdminCheck" 2>nul
if '%errorlevel%' == '0' rmdir "%windir%\AdminCheck" & goto gotPrivileges else goto getPrivileges

:getPrivileges
ECHO.
ECHO                        Administrator Rights are required
ECHO                      Invoking UAC for Privilege Escalation
ECHO.
runadmin.vbs %0
goto EOF

:gotPrivileges

Echo.
>"%_lstVol%" Echo.List Volume
For /F "Tokens=3,4,7,8" %%I In ('Diskpart /S "%_lstVol%"^|Findstr /I /R /C:"Removable"') Do (
	If "%1" EQU "%%J" (
		If "%%I" NEQ "Removable" (
			set _deviceInfo=%%I:\diskInfo.txt
			Set _fullDiskSpace=%%K
			Set _fullDiskUnit=%%L
			For /F "Tokens=3,4*" %%a In ('Dir /-c "%%I:" ^|Findstr /I /R /C:"bytes free"') Do (
				set _freeDiskSpace=%%a
				set _freeDiskUnit=%%b
				Set _freeDiskUnit=!_freeDiskUnit:~,1!
				
				:: Convert a variable VALUE to all UPPER CASE.
				CALL :UpCase _freeDiskUnit
				GOTO:EOF

				:UpCase
				:: Subroutine to convert a variable VALUE to all UPPER CASE.
				:: The argument for this subroutine is the variable NAME.
				FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
				GOTO _freeSpaceX
				)
			)
		)
)
Goto _Cleanup

:::::::::::::::::::::::::::
::   creating VBscript   ::
:::::::::::::::::::::::::::
:_freeSpaceX

Echo Set objFSO=CreateObject("Scripting.FileSystemObject") > %_writeVBS%

Echo Dim usedDiskSpace >> %_writeVBS%
Echo Dim freeDiskSpace >> %_writeVBS%
Echo Dim usedDiskPercentage >> %_writeVBS%
Echo Dim fullDiskSpace >> %_writeVBS%
Echo Dim fullDiskUnit >> %_writeVBS%


Echo ' How to write file >> %_writeVBS%
Echo outFile="%_deviceInfo%" >> %_writeVBS%
Echo Set objFile = objFSO.CreateTextFile(outFile,True) >> %_writeVBS%

Echo fullDiskSpace=cdbl(%_fullDiskSpace%) >> %_writeVBS%
Echo fullDiskUnit="%_fullDiskUnit%" >> %_writeVBS%

:: ========================================================
:: start do-until loop to convert fullDiskSpace into bytes
::
Echo Do >> %_writeVBS%
:: ==================================
:: start if-else conditional staments
::
Echo If ((Cstr(fullDiskUnit) = "TB")) Then >> %_writeVBS%
Echo fullDiskSpace=Cdbl(fullDiskSpace)*1024 >> %_writeVBS%
Echo fullDiskUnit="GB" >> %_writeVBS%
Echo ElseIf ((Cstr(fullDiskUnit) = "GB")) Then >> %_writeVBS%
Echo fullDiskSpace=Cdbl(fullDiskSpace)*1024 >> %_writeVBS%
Echo fullDiskUnit="MB" >> %_writeVBS%
Echo ElseIf ((Cstr(fullDiskUnit) = "MB")) Then >> %_writeVBS%
Echo fullDiskSpace=Cdbl(fullDiskSpace)*1024 >> %_writeVBS%
Echo fullDiskUnit="KB" >> %_writeVBS%
Echo Elseif ((Cstr(fullDiskUnit) = "KB")) Then >> %_writeVBS%
Echo fullDiskSpace=Cdbl(fullDiskSpace)*1024 >> %_writeVBS%
Echo fullDiskSpace=FormatNumber(fullDiskSpace, 0) >> %_writeVBS%
:: final result of fullDiskSpace in Bytes
Echo fullDiskSpace=replace(fullDiskSpace, ",", "") >> %_writeVBS% ' final result of fullDiskSpace in Bytes
Echo fullDiskUnit="B" >> %_writeVBS%
Echo End If >> %_writeVBS%
::
:: end if-else conditional staments
:: ==================================
Echo Loop Until Cstr(fullDiskUnit) = "B" >> %_writeVBS%
::
:: end do-until loop to convert fullDiskSpace into bytes
:: ========================================================

:: final result of freeDiskSpace in Bytes
Echo freeDiskSpace=cdbl(%_freeDiskSpace%) >> %_writeVBS% ' final result of freeDiskSpace in Bytes
:: final result of usedDiskSpace in Bytes
Echo usedDiskSpace=cdbl(fullDiskSpace-freeDiskSpace) >> %_writeVBS% ' final result of usedDiskSpace in Bytes
:: final result of usedDiskSpace in percentage
Echo usedDiskPercentage=cint(usedDiskSpace/fullDiskSpace*100) >> %_writeVBS%


Echo finalSizes = Array(fullDiskSpace, usedDiskSpace, freeDiskSpace)  >> %_writeVBS%
Echo Dim labels >> %_writeVBS%
Echo Dim counter >> %_writeVBS%
Echo counter=1 >> %_writeVBS%

:: ======================================================================================================
:: Start For Each...Next Statement to convert fullDiskSpace, usedDiskSpace, freeDiskSpace in highest unit
::
Echo For Each item in finalSizes >> %_writeVBS%

Echo fullDiskUnit=B >> %_writeVBS%

Echo if counter = 1 Then  >> %_writeVBS%
Echo labels = "TM" >> %_writeVBS%
Echo Elseif counter = 2 then  >> %_writeVBS%
Echo labels = "UM" >> %_writeVBS%
Echo Elseif counter = 3 then  >> %_writeVBS%
Echo labels = "FM" >> %_writeVBS%
Echo End IF >> %_writeVBS%

:: ==================================
:: start if-else conditional staments
::
Echo If (Cdbl(item) ^> 1023) Then >> %_writeVBS%
Echo item=Cdbl(item)/1024 >> %_writeVBS%
Echo fullDiskUnit="KB" >> %_writeVBS%
Echo If ((Cdbl(item) ^> 1023) And (Cstr(fullDiskUnit) = "KB")) Then >> %_writeVBS%
Echo item=Cdbl(item)/1024 >> %_writeVBS%
Echo fullDiskUnit="MB" >> %_writeVBS%
Echo If ((Cdbl(item) ^> 1023) And (Cstr(fullDiskUnit) = "MB")) Then >> %_writeVBS%
Echo item=Cdbl(item)/1024 >> %_writeVBS%
Echo fullDiskUnit="GB" >> %_writeVBS%
Echo if ((Cdbl(item) ^> 1023) And (Cstr(fullDiskUnit) = "GB")) Then >> %_writeVBS%
Echo item=Cdbl(item)/1024 >> %_writeVBS%
Echo fullDiskUnit="TB" >> %_writeVBS%
Echo Else >> %_writeVBS%

Echo objFile.WriteLine(labels + " = "  + Cstr(FormatNumber(item, 2)) + " " + Cstr(fullDiskUnit))>> %_writeVBS% >> %_writeVBS%
:: To print result in console
ECHO WScript.StdOut.WriteLine(labels + " = "  + Cstr(FormatNumber(item, 2)) + " " + Cstr(fullDiskUnit))>> %_writeVBS%
Echo End If >> %_writeVBS%
Echo Else >> %_writeVBS%
Echo objFile.WriteLine(labels + " = "  + Cstr(FormatNumber(item, 2)) + " " + Cstr(fullDiskUnit))>> %_writeVBS% >> %_writeVBS%
:: To print result in console
ECHO WScript.StdOut.WriteLine(labels + " = "  + Cstr(FormatNumber(item, 2)) + " " + Cstr(fullDiskUnit))>> %_writeVBS%
Echo End If >> %_writeVBS%
Echo Else >> %_writeVBS%
Echo objFile.WriteLine(labels + " = "  + Cstr(FormatNumber(item, 2)) + " " + Cstr(fullDiskUnit))>> %_writeVBS% >> %_writeVBS%
:: To print result in console
ECHO WScript.StdOut.WriteLine(labels + " = "  + Cstr(FormatNumber(item, 2)) + " " + Cstr(fullDiskUnit))>> %_writeVBS%
Echo End If >> %_writeVBS%
Echo Else >> %_writeVBS%
Echo objFile.WriteLine(labels + " = "  + Cstr(FormatNumber(item, 2)) + " " + Cstr(fullDiskUnit))>> %_writeVBS% >> %_writeVBS%
:: To print result in console
ECHO WScript.StdOut.WriteLine(labels + " = "  + Cstr(FormatNumber(item, 2)) + " " + Cstr(fullDiskUnit))>> %_writeVBS%
Echo End If >> %_writeVBS%
::
:: end if-else conditional staments
:: ==================================
Echo counter=counter+1 >> %_writeVBS%
Echo Next >> %_writeVBS%
::
:: End For Each...Next Statement to convert fullDiskSpace, usedDiskSpace, freeDiskSpace in highest unit
:: =====================================================================================================

Echo objFile.WriteLine("PR = " + Cstr(usedDiskPercentage) + "%%")>> %_writeVBS%
:: To print result in console
ECHO WScript.StdOut.WriteLine("PR = " + Cstr(usedDiskPercentage) + "%%")>> %_writeVBS%
Echo objFile.Close >> %_writeVBS%

cscript //nologo %_writeVBS%

ECHO.
ECHO This information also written into "DiskInfo.txt" in the specified disk.
ECHO.
:_Cleanup
For %%I In ("%_writeVBS%" "%_lstVol%") Do Del %%I>Nul 2>&1
pause
Goto :EOF
:EOF
