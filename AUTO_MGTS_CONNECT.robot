*** Settings ***

Library    Collections
Library    SSHLibrary
Library    OperatingSystem
Library    String
Library    BuiltIn
Variables         /opt/product/AUTOMATION/TEST_AUTOMATION_FRAMEWORK/IMS_SOLARIS_IPV6_EXP/CONFIG/AUTO_MGTS_DETAILS.py

*** Variables ***


*** Keyword ***

Connect MGTS Server
    Open Connection   ${MGTS_HOST}    prompt=${MGTS_STARTPROMPT}    encoding=${ENCODING}    alias=${MGTS_ALIAS}    timeout=300
    Login   ${MGTS_USERNAME}    ${MGTS_PASSWORD}
    Enable SSH Logging    MGTS_LOGS.txt

Connect MGTS with PublicKey
    Open Connection   ${MGTS_HOST}    prompt=${MGTS_STARTPROMPT}    encoding=${ENCODING}    alias=${MGTS_ALIAS}    timeout=300
    Login With Public Key    ${MGTS_USERNAME}    ${ID_RSA}
    Enable SSH Logging    ${AUTOMATION_TEMP_PATH}MGTS_LOGS.txt
    Start MGTS    ${MGTS_ASSSIGNMENT}    

Close Mgts Connection
    MGTS Stop

Start MGTS    [Arguments]    ${MGTS_ASSSIGNMENT}
    [Documentation]   MGTS START
    Switch Connection    ${MGTS_ALIAS}
    Write    export PS1="MGTS$"
    Set Client Configuration    prompt=MGTS$
    Write    . mgts_im3_env
    ${output}=    Read Until Prompt
    Write    run_mgts_script
    ${output}=    Read Until Prompt
    Should Contain    ${output}    MGTS scripting session started successfully
    Write    shelfConnect ${MGTS_SHELF}
    ${output}=    Read Until Prompt
    Should Contain    ${output}    Connected to ${MGTS_SHELF}
    Write    networkExecute ${MGTS_ASSSIGNMENT}
    ${output}=    Read Until Prompt
    Should Contain    ${output}    Build Complete
    Write    networkDownload ${MGTS_ASSSIGNMENT}
    ${output}=    Read Until Prompt
    Should Contain    ${output}    Download Complete
    MGTS Seq List

MGTS Seq List
    [Documentation]   GET MGTS Sequence list
    Switch Connection    ${MGTS_ALIAS}
    ${stdout}=    SSHLibrary.Execute Command    rm -f ${MGTS_LOGPATH}${MGTS_ASSSIGNMENT}.txt 
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -seqlist -log ${MGTS_LOGPATH}${MGTS_ASSSIGNMENT}.txt
    ${output}=    Read Until Prompt
    Create File   ${AUTOMATION_TEMP_PATH}sm.txt   ${output}    UTF-8

MGTS State Machine PASS FAIL SET
    [Documentation]   Setting Pass and Fail Actions for State Machine
    Switch Connection    ${MGTS_ALIAS}
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -passed
    ${output}=    Read Until Prompt
    Create File   ${AUTOMATION_TEMP_PATH}sm_pass.txt   ${output}    UTF-8
    ${smpass} =    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}sm_pass.txt    ${STATE_MACHINE}
    @{sm_pass} =    Split String    ${smpass}
    Set Test Variable    ${SM_PASSTATUS}    ${sm_pass[0]}    
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -failed
    ${output}=    Read Until Prompt
    Create File   ${AUTOMATION_TEMP_PATH}sm_fail.txt   ${output}    UTF-8
    ${smfail} =    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}sm_fail.txt    ${STATE_MACHINE}
    @{sm_fail} =    Split String    ${smfail}
    Set Test Variable    ${SM_FAILSTATUS}    ${sm_fail[0]}
    [Return]    ${SM_PASSTATUS}    ${SM_FAILSTATUS}

RUN MGTS State Machine
    [Documentation]   RUN MGTS State Machine
    Switch Connection    ${MGTS_ALIAS}
    ${stdout}=    SSHLibrary.Execute Command    rm -f ${MGTS_LOGPATH}${STATE_MACHINE}.txt
    ${SM_SEQ} =    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}sm.txt    ${STATE_MACHINE}
    @{SM_SEQLIST} =    Split String    ${SM_SEQ}
    Set Test Variable    ${SEQ}    ${SM_SEQLIST[1]}
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -sequence ${SEQ} -run -log ${MGTS_LOGPATH}${STATE_MACHINE}.txt
    ${output}=    Read Until Prompt

Verify MGTS State Machine
    [Documentation]   Verifying MGTS EXECUTION Status COMPLETION
    Switch Connection    ${MGTS_ALIAS}
    FOR    ${index}    IN RANGE    ${SM_RANGE}
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -qlist
    ${SM_STATE}=    Read Until Prompt
    Create File   ${AUTOMATION_TEMP_PATH}sm_status.txt   ${SM_STATE}    UTF-8
    ${SM_EXIST} =    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}sm_status.txt    ${STATE_MACHINE}
    @{SM_PRES} =    Split String    ${SM_EXIST}
    ${SM_LEN} =    Get Length   ${SM_PRES} 
    log    Length=${SM_LEN}
    ${SMSTAT}=    Set Variable If
    ...    ${SM_LEN}==0    EXIT
    Set Test Variable    ${SM_EXITSTAT}    ${SMSTAT}
    Exit For Loop If    '${SMSTAT}'=='EXIT'
    Sleep    ${SM_DURATION}s
    END

MGTS State Machine STOP
    [Documentation]   MGTS State Machine STOP
    Switch Connection    ${MGTS_ALIAS}
    BuiltIn.Run Keyword And Continue On Failure    Run Keyword If    '${SM_EXITSTAT}'=='CONT'
    ...    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -sequence ${SEQ} -stop

MGTS Stop
    [Documentation]   MGTS STOP
    Switch Connection    ${MGTS_ALIAS}
    Write    shelfDisconnect ${MGTS_SHELF}
    ${output}=    Read Until Prompt
    Should Contain    ${output}    Disconnected from ${MGTS_SHELF}
    Write    stop_mgts_script
    Close Connection

RUN MGTS ASSOCIATION    [Arguments]    ${ASSOCATION}
    [Documentation]   RUN MGTS ASSOCATION State Machine
    Switch Connection    ${MGTS_ALIAS}
    ${SM_SEQ} =    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}sm.txt    ${ASSOCATION}
    @{SM_SEQLIST} =    Split String    ${SM_SEQ}
    ${SEQ}=    Set Variable    ${SM_SEQLIST[1]}
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -sequence ${SEQ} -run
    ${output}=    Read Until Prompt
    FOR    ${index}    IN RANGE    ${SM_RANGE}
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -qlist
    ${SM_STATE}=    Read Until Prompt
    Create File   ${AUTOMATION_TEMP_PATH}sm_status.txt   ${SM_STATE}    UTF-8
    ${SM_EXIST} =    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}sm_status.txt    ${ASSOCATION}
    @{SM_PRES} =    Split String    ${SM_EXIST}
    ${SM_LEN} =    Get Length   ${SM_PRES} 
    log    Length=${SM_LEN}
    ${SMSTAT}=    Set Variable If
    ...    ${SM_LEN}==0    EXIT
    ${SM_EXITSTAT}=    Set Variable    ${SMSTAT}
    Exit For Loop If    '${SMSTAT}'=='EXIT'
    Sleep    ${SM_DURATION}s
    END
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -passed
    ${output}=    Read Until Prompt
    Create File   ${AUTOMATION_TEMP_PATH}sm_pass.txt   ${output}    UTF-8
    ${smpass} =    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}sm_pass.txt    ${ASSOCATION}
    @{sm_pass} =    Split String    ${smpass}
    ${SM_PASSTATUS}=    Set Variable    ${sm_pass[0]}    
    Write    shelfPASM ${MGTS_SHELF} -node ${MGTS_NODE} -failed
    ${output}=    Read Until Prompt
    Create File   ${AUTOMATION_TEMP_PATH}sm_fail.txt   ${output}    UTF-8
    ${smfail} =    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}sm_fail.txt    ${ASSOCATION}
    @{sm_fail} =    Split String    ${smfail}
    ${SM_FAILSTATUS}=    Set Variable    ${sm_fail[0]}
    [Return]    ${SM_PASSTATUS}    ${SM_FAILSTATUS}

MGTS LOG COPY
    [Timeout]    1 minute
    [Documentation]   MGTS LOG COPY
    Switch Connection    ${MGTS_ALIAS}
    ${MGTS_LOG_FILE}=    Set Variable    ${result_path}MGTS_${STATE_MACHINE}_${TIMESTAMP}.txt   
    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Get File    ${MGTS_LOGPATH}${STATE_MACHINE}.txt    ${MGTS_LOG_FILE}
/