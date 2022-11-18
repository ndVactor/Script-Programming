:: Nathan depcik
:: 7-21-22
:: batch file for IQAN 6
:: args 
    :: %1 type of truck
    :: %2 IQAN proj file
    :: %3 IQAN script file
    :: %4 script output file
@ECHO off 
setlocal enabledelayedexpansion

:: var
    set IDAddress=-1
    set macAdd=-1
    set pingLoop=-1
    set worOrder=0
    set name=NULL
    set outputFile="X:\Workgroup\Programming\Script Iqan\Script Programming\Output Folder\Output.htm"
    set truckConfigFile=NULL

    :: to do have c# application send args to batch file
    @REM ECHO switch%~1
    CALL :switch%~1%
    if %ERRORLEVEL% NEQ 0 goto switchDefult
    
    TIMEOUT 15

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
    for /F "usebackq tokens=1" %%B in ("temp.txt") do (
        set /a count+=1
        if !IDAddress!==-1 CALL :conditionCheck !count! %%B 
    )

:: delete txt file 
    break > temp.txt
    DEL temp.txt

:: send IQAN and script
    if %macAdd%==-1 if %IDAddress%==-1 ECHO ERROR: no module found
    goto :end
::=====================================================================================================================
:sendIQAN

    if NOT %macAdd%==-1 (
        if NOT %IDAddress%==-1 (
            Echo macAdd %macAdd% ID %IDAddress%
            IQANrun -cif Ethernet -mac %macAdd% -silent -send %IQANFile%
            ECHO success IQAN project sent
            IQANrun -cif Ethernet -mac %macAdd% -silent -script %IQANFile% %IQANscript% 
            ECHO success IQAN script sent

        )
    )
    if %macAdd%==-1 if %IDAddress%==-1 ECHO Error IQAN failed to send
    EXIT /B 

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

::switch cases   
    @REM sets file and script of each truck depending on first arg then retruns 
    @REM potentaly change to look at files to get most up to date without change

:switchPlusII
    ::plus 2
    ECHO 2100 plusII 
    set IQANfile="X:\Workgroup\Programming\3.2) Plus II\1) Current Programs\2100i V1 R67.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\plusII\PlusII.issx"
    set truckConfigFile="X:\Workgroup\Programming\Script Iqan\Script Programming\plusII\Variables.ini"
    EXIT /B
:switchPlusIII
    ::plus 3
    ECHO 2100 plusIII
    set IQANFile="X:\Workgroup\Programming\3.3) Plus III\1) Current Programs\2200i V0 R4 .idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\plusIII\plusIII.issx"
    EXIT /B
:switchRamjetII
    ::ramjet II
    ECHO ramjet II 
    set IQANFile="X:\Workgroup\Programming\7.2) RamJET II\1) Current Programs\RamJet V0 R42.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\ramjetII\ramjetII.issx"
    EXIT /B
:switchImpact
    ::impact    
    ECHO impact
    set IQANfile="X:\Workgroup\Programming\6.2) Impact\1) Current Program\Impact V0 R51.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\impact\impact.issx"
    EXIT /B
:switchHXX
    :: hxx
    ECHO HXX
    set IQANFile="X:\Workgroup\Programming\1) HXX\1) Current Program\HXX V23 R43 (TruVac Logo).idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\Hxx\HXX.issx"
    EXIT /B
:switchQX
    ::QX
    ECHO QX
    set IQANfile="X:\Workgroup\Programming\1.2) QX-HXX II\1) Current Programs\HXX II Gen 2 V0 R30(TruVac) Old CAT Pump Motor.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\QX\QX.issx"
    EXIT /B
:switchAPXX
    ::APXX
    ECHO APXX
    set IQANfile="X:\Workgroup\Programming\1.5) APXX\1) Current Program\APXX V0 R2.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\APXX\APPX.issx"
    EXIT /B
:switchFLXX
    ::flxx
    ECHO FLXX
    set IQANfile="X:\Workgroup\Programming\1.3) FLXX\1) Current Program\FLXX V0 R19.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script ProgrammingFLXX\FLXX.issx"
    EXIT /B
:switchTRXX
    ::TRXX      ::TODO change for bluetooth and when we start building
    ECHO TRXX
    set IQANfile="X:\Workgroup\Programming\1.6) TRXX\1) Current\Trailer V0 R3.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\TRXX\TRXX.issx"
    EXIT /B
:switchParadigm
    ::paradigm
    ECHO paradigm
    set IQANfile="X:\Workgroup\Programming\8) Paradigm\1) Current Program\ParaDIGm V3 R22 (TruVac).idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\paradigm\paradigm.issx"
    EXIT /B
:switchGuzzler
    ::Guzzler       ::TODO change for CAN
    ECHO Guzzler
    set IQANfile="X:\Workgroup\Programming\2) Guzzler\1) Current Program\Guzzler V0 R4.idax"
    set IQANscript="X:\Workgroup\Programming\Script Iqan\Script Programming\Guzzler\guzzler.issx"
    EXIT /B
:switchDefult
    ::defult
    ECHO Error%ERRORLEVEL%: truck type not found
    goto end

::=====================================================================================================================

:end 