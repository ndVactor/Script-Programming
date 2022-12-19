:: Nathan depcik
:: 7-21-22
:: batch file for IQAN 6
:: args 
    :: %1 type of truck
    :: %2 simuation

::Exit codes
	:: 1
	:: 2 no module found 
	::
@ECHO off 
setlocal enabledelayedexpansion
cls
:: var
    set IDAddress=-1
    set macAdd=-1
    set pingLoop=-1
    set name=NULL
    set outputFilePath=X:\Workgroup\Programming\Script Iqan\Script Programming\Output Folder\
    set truckConfigFile=NULL
	@REM set printoutPath=C:\Users\NDepcik\Desktop\code\batchtest\moveTest\
	@REM set configPath=C:\Users\NDepcik\Desktop\code\batchtest\moveTest\
	set printoutPath=X:\Public\_ENGINEERING\_IQAN print outs\
	set configPath=X:\Public\_ENGINEERING\_IQAN Config Files\
    set outputName=Output.htm
    set varName=Variables.ini
	set defaultName=Defaults.ini
	set iniExtention=.ini
	set htmExtention=.htm

::truck type
    CALL :switch%~1%
    if %ERRORLEVEL% NEQ 0 goto switchDefult
    
    TIMEOUT 15
	
::communication type
    if /I "%~2" EQU "sim" (
        CALL :simulation 
    ) Else (
        set temp=0
        if /I "%~1" EQU "Guzzler" set "temp=1"
        if /I "%~1" EQU "TRXX" set "temp=1"
        if !Temp!==1 ( CALL :CAN) Else ( CALL :Ethernet)
        )
::HXX CHECK
	if /I "%1" EQU "HXX" (
		set /p input=HXX configured?^(Y/N^)
		if /I "%input%"=="Y" (
			ECHO sending IQAN script
			IQANrun -cif Ethernet -mac %macAdd% -silent -script %IQANFile% %IQANscript%
		)
	)
	set /p input=Transfer files?(Y/N)
	if /I "%input%"=="Y" ( 
		Echo Transfering Files) Else (goto end)
:fileManipulation
    CALL :parseINI
    CALL :renameFiles
	call :moveFiles
	Call :overwriteFiles
	goto end
    EXIT \B
::=====================================================================================================================
:Ethernet
    Echo Connection type Ethernet

:arpLoop
	:: command to txt file
		arp /a> temp.txt
	:: parse txt file for IP and mac
		set count=0
		for /F "usebackq tokens=2" %%A in ("temp.txt") do (
			set /a count+=1
			set mac[!count!]= %%A 
		)

		set count=0
		for /F "usebackq tokens=1" %%A in ("temp.txt") do (
			set /a count+=1
			if !IDAddress!==-1 CALL :conditionCheck !count! %%A 
		)

    :: delete txt file 
        break > temp.txt
        DEL temp.txt

    :: send IQAN and script
        if %macAdd%==-1 (
			if %IDAddress%==-1 (
				ECHO ERROR 2: no module found 
				pause
				Exit 2
			
			)
		)
        goto:eof

    :sendIQAN

        if NOT %macAdd%==-1 (
            if NOT %IDAddress%==-1 (
                Echo macAdd %macAdd% ID %IDAddress%
                IQANrun -cif Ethernet -mac %macAdd% -silent -send %IQANFile%
                ECHO IQAN project sent
                IQANrun -cif Ethernet -mac %macAdd% -silent -script %IQANFile% %IQANscript% 
                ECHO IQAN script sent

            )
        )
        if %macAdd%==-1 if %IDAddress%==-1 ECHO Error IQAN failed to send
        GOTO end

    :conditionCheck

        set var=%2
        set var2=%var:~0,8%
        set num=%1
        set str=ff-ff-ff-ff-ff-ff
        set temp=!mac[%~1]!

        if NOT %var%==169.254.169.254 (
            :: checks for right IP and mac is not uninitlized 
            if %var2%==169.254. (
                if NOT %temp%==ff-ff-ff-ff-ff-ff (
                    set IDAddress=%1
                    set macAdd=%temp%
                    GOTO sendIQAN
                )
                if %temp%==ff-ff-ff-ff-ff-ff (
                    if %pingLoop%==-1 (
                        ping %var%
                        set pingLoop=0
                        GOTO arpLoop
                    )
                )
            )
        )
        EXIT /B 
::*************************************************************************************************
:CAN
    Echo Connection type CAN

    IQANrun -cif CAN -silent -send %IQANFile%
    IQANrun -cif CAN -silent -script %IQANFile% %IQANscript% 
    EXIT /B
::*************************************************************************************************
:simulation
    Echo Connection type simulator

    IQANrun -cif Simulator -silent -send %IQANFile%
    IQANrun -cif Simulator -silent -script %IQANFile% %IQANscript% 
    Exit /B
::=====================================================================================================================
:switchCases   
    @REM sets file and script of each truck depending on first arg then retruns 
    @REM potentaly change to look at files to get most up to date without change

:switchPlusII
    ::plus 2
    ECHO 2100 plusII 
    set IQANfile="X:\Workgroup\Programming\3.2) Plus II\1) Current Programs\2100i V1 R70.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\plusII\PlusII.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\plusII\
    EXIT /B
:switchPlusIII
    ::plus 3
    ECHO 2100 plusIII
    set IQANFile="X:\Workgroup\Programming\3.3) Plus III\1) Current Programs\2200i V0 R4 .idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\plusIII\plusIII.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\plusIII\
    EXIT /B
:switchRamjetII
    ::ramjet II
    ECHO ramjet II 
    set IQANFile="X:\Workgroup\Programming\7.2) RamJET II\1) Current Programs\RamJet V0 R44.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\ramjetII\ramjetII.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\ramjetII\
    EXIT /B
:switchImpact
    ::impact    
    ECHO impact
    set IQANfile="X:\Workgroup\Programming\6.2) Impact\1) Current Program\Impact V0 R55.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\impact\impact.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\impact\
    EXIT /B
:switchHXX
    :: hxx
    ECHO HXX
    set IQANFile="X:\Workgroup\Programming\1) HXX\1) Current Program\HXX V23 R43 (TruVac Logo).idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\Hxx\HXX.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\Hxx\
    EXIT /B
:switchQX
    ::QX
    ECHO QX
    set IQANfile="X:\Workgroup\Programming\1.2) QX-HXX II\1) Current Programs\HXX II Gen 2 V0 R34.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\QX\QX.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\QX\
    EXIT /B
:switchAPXX
    ::APXX
    ECHO APXX
    set IQANfile="X:\Workgroup\Programming\1.5) APXX\1) Current Program\APXX V0 R3.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\APXX\APPX.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\APXX\
    EXIT /B
:switchFLXX
    ::flxx
    ECHO FLXX
    set IQANfile="X:\Workgroup\Programming\1.3) FLXX\1) Current Program\FLXX V0 R19.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\FLXX\FLXX.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\FLXX\
    EXIT /B
:switchTRXX
    ::TRXX      ::TODO change for bluetooth and when we start building
    ECHO TRXX
    set IQANfile="X:\Workgroup\Programming\1.6) TRXX\1) Current\Trailer V0 R6.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\TRXX\TRXX.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\TRXX\
    EXIT /B
:switchParadigm
    ::paradigm
    ECHO paradigm
    set IQANfile="X:\Workgroup\Programming\8) Paradigm\1) Current Program\ParaDIGm V3 R22 (TruVac).idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\paradigm\paradigm.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\paradigm\
    EXIT /B
:switchGuzzler
    ::Guzzler       ::TODO change for CAN
    ECHO Guzzler
    set IQANfile="X:\Workgroup\Programming\2) Guzzler\1) Current Program\Guzzler V0 R6.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\Guzzler\guzzler.issx"
    set truckConfigFile=X:\Workgroup\Programming\Script Iqan\Script Programming\Guzzler\
    EXIT /B
:switchDefult
    ::defult
    ECHO Error%ERRORLEVEL%: truck type not found
    goto end

::=====================================================================================================================
    :parseINI
		@REM ECHO file %truckConfigFile%%varName%
    
        for /F  "usebackq tokens=1,2 delims==" %%C in ("%truckConfigFile%%varName%") do (
                if /I "%%C"=="name" set name=%%D
                if /I "%%C"=="workOrder" set workOrder=%%D
            )

        Echo Name: %name%
        Echo Work Order: %workOrder%
        Exit /B 
    :renameFiles
	@REM change to move to output folder
		ECho Renaming Files
        Echo 	config: %truckConfigFile%%varName% %workOrder%%name%
        Echo 	IQAN:  %outputFilePath%%outputName% %workOrder%%name%

        copy /-Y "%truckConfigFile%%varName%" "%truckConfigFile%%workOrder% %name%%iniExtention%"
        copy /-Y "%outputFilePath%%outputName%" "%outputFilePath%%workOrder% %name%%htmExtention%"
        Exit /B
    :moveFiles
		@REM change to move and look at engineering folder
		set count=0
		set temp=%configPath%%workOrder% %name%%iniExtention%
		Echo Moving Files
		Call :ifExistsINI
		Echo 	Source: %truckConfigFile%%workOrder% %name%%iniExtention%
		Echo 	Target: %temp%
		move /-Y "%truckConfigFile%%workOrder% %name%%iniExtention%" "%temp%"

		set count=0
		set temp=%printoutPath%%workOrder% %name%%htmExtention%
		Call :ifExistsHTM
		Echo 	Source: %truckConfigFile%%workOrder% %name%%htmExtention%
		Echo 	Target: %temp%
		move /-Y "%outputFilePath%%workOrder% %name%%htmExtention%" "%temp%"
		EXIT /B

	:overwriteFiles
		Echo Seting Varibles to Defaults
		Echo 	Source: %truckConfigFile%%defaultName%
		Echo 	Target: %truckConfigFile%%varName%
		copy /Y "%truckConfigFile%%defaultName%" "%truckConfigFile%%varName%"
		Exit /B
::=====================================================================================================================
	@REM will need to look at public drive
	:ifExistsINI
		IF EXIST "%temp%" (
		set /a "count+=1"
		set temp=%configPath%%workOrder% %name% !count!%iniExtention%
		Call :ifExistsINI)  else (Echo 	%temp% does not exist & Exit /B)
		EXIT /B

	:ifExistsHTM
		IF EXIST "%temp%" (
		set /a "count+=1"
		set temp=%printoutPath%%workOrder% %name% !count!%htmExtention%
		Call :ifExistsHTM)  else (Echo 	%temp% does not exist & Exit /B)
		EXIT /B
::=====================================================================================================================
:end 
pause