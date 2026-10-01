*** Settings ***

Library    Collections
Library    SSHLibrary    5min
Library    OperatingSystem
Library    String
Library    BuiltIn

*** Variables ***


*** Keyword ***

Connect Application Server
    Open Connection   ${APP_HOST}    prompt=${APP_PROMPT}    encoding=${ENCODING}    alias=${APP_ALIAS}    timeout=300
    Login    ${APP_USERNAME}    ${APP_PASSWORD}
    Enable SSH Logging    APP_LOGS.txt
    ${FILE_EXIST}=    Execute Command    ls ${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT}
    Should Be Equal    ${FILE_EXIST}    ${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT}
    ${stdout}=     Execute Command    pgrep ${APP_BINARY}
    Should Not Be Empty    ${stdout}
    Create File    pidfile.txt    ${stdout}
    ${TC_TIMESTAMP}=    Getting date time


Connect Application with PublicKey
    Open Connection   ${APP_HOST}    prompt=${APP_PROMPT}    encoding=${ENCODING}    alias=${APP_ALIAS}    timeout=300
    Login With Public Key    ${APP_USERNAME}    ${ID_RSA}
    Enable SSH Logging    APP_LOGS.txt
    ${FILE_EXIST}=    Execute Command    ls ${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT}
    Should Be Equal    ${FILE_EXIST}    ${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT}
    ${stdout}=     Execute Command    pgrep ${APP_BINARY}
    Should Not Be Empty    ${stdout}
    Create File    ${AUTOMATION_PATH}pidfile.txt    ${stdout}
    ${TC_TIMESTAMP}=    Getting date time
    Create File    ${TIMESTAMP_FILE_PATH}timestamp.txt    ${TC_TIMESTAMP}
    OperatingSystem.Empty Directory    ${SEAGULL_LOGPATH}


Close Application Server Connection
    BuiltIn.Run Keyword If    ${REMOTE_START_TYPE}==${1}    KILL ALL APPLICATION
    Close All Connections

Suite Execution Time Set
    ${GETTIME}=    OperatingSystem.Get File    ${AUTOMATION_TEMP_PATH}timestamp.txt
    Set Suite Variable    ${TIMESTAMP}    ${GETTIME}

Getting date time
    ${t} =    Get Time
    ${results}=    Convert Date    ${t}    result_format=%Y_%m_%d_%H_%M_%S
    [return]    ${results}

Check Application Status
    ${rc} =     Execute Command    pgrep ${APP_BINARY}

Execute Automation SHELL_PRE    [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${shellpre_result}   ${shellpre_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} SHELL_PRE ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers   ${shellpre_rc}    0    
    [Return]    ${shellpre_result}

Execute DB Precondition   [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${predb_result}   ${predb_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} PRE ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers    ${predb_rc}    0
    [Return]    ${predb_result}

Execute Automation Start    [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    Switch Connection    ${APP_ALIAS}
    Start Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} start ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH} &

Execute Automation ShellOncall    [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${shelloncall_result}   ${shelloncall_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} SHELL_ONCALL ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers     ${shelloncall_rc}    0    
    [Return]    ${shelloncall_result}

Execute DB Oncallcondition   [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${oncalldb_result}   ${oncalldb_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} ONCALL_DB ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers    ${oncalldb_rc}    0
    [Return]    ${oncalldb_result}

Execute Automation Stop    [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${stop_result}   ${stop_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} stop ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers    ${stop_rc}    0    
    [Return]    ${stop_result}

Execute DB Postcondition   [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${postdb_result}   ${postdb_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} POSTQRY ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers    ${postdb_rc}    0
    [Return]    ${postdb_result}

Execute Automation SHELL_POST    [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${shellpost_result}   ${shellpost_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} SHELL_POST ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers   ${shellpost_rc}    0    
    [Return]    ${shellpost_result}

Execute Automation PCAP    [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${pcap_result}   ${pcap_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} PCAP ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers     ${pcap_rc}    0    
    [Return]    ${pcap_result}

Execute Automation CDR    [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    3 minute
    Switch Connection    ${APP_ALIAS}
    ${cdr_result}   ${cdr_rc}=    Execute Command    .${REMOTE_AUTOPATH}${/}${REMOTE_AUTOSCRIPT} ${TESTCASE_ID} CDR ${AUTO_REL} ${TIMESTAMP} ${AUTO_REV} ${REMOTE_AUTOPATH}    return_stdout=True    return_rc=True
    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Integers     ${cdr_rc}    0    
    [Return]    ${cdr_result}

Execute Automation DIRCOPY    [Arguments]    ${TESTCASE_ID}    ${TIMESTAMP}
    [Timeout]    1 minute
    Switch Connection    ${APP_ALIAS}
    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Directory Should Exist    ${APP_AUTOLOGPATH}${/}${AUTO_REL}${/}${AUTO_REV}/${TIMESTAMP}/${TESTCASE_ID}
    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Get Directory    ${APP_AUTOLOGPATH}${/}${AUTO_REL}${/}${AUTO_REV}/${TIMESTAMP}/${TESTCASE_ID}    ${AUTOMATION_FAILPATH}${/}${AUTO_REL}${/}${AUTO_REV}${/}${TIMESTAMP}${/}${TESTCASE_ID}${/}
  
