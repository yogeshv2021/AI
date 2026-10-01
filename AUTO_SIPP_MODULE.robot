*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Process

*** Variables ***

*** Keyword ***
RUN SIPP SCENARIO
    [Arguments]    ${SCENARIO_FILE}
    [Timeout]    3 minute 01 seconds
    CLEAR SIPP DIRECTORIES
    Run    ${SIPPENV}
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_PROCESS}    stderr=${SIPP_TMP}stderr.txt    stdout=${SIPP_TMP}stdout.txt
    log    sipp Exit status ${rc} and 
    ${result}=    Process.Wait For Process    ${SIPP_PROCESS}    timeout=5 secs    on_timeout=terminate
    [Return]    ${result}

RUN SIPP CLIENT SERVER
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}
    [Timeout]    3 minute 01 seconds
    CLEAR SIPP DIRECTORIES
    Run    ${SIPPENV}
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${SERVER_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_SERVER_PROCESS}    stderr=${SIPP_TMP}stderr_server.txt    stdout=${SIPP_TMP}stdout_server.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${CLIENT_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_CLIENT_PROCESS}    stderr=${SIPP_TMP}stderr_client.txt    stdout=${SIPP_TMP}stdout_client.txt
    log    sipp Exit status ${rc}

RUN SIPP CLIENT TWO SERVER
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}    ${SERVER_SCENARIO2_FILE}
    [Timeout]    3 minute 01 seconds
    CLEAR SIPP DIRECTORIES
    Run    ${SIPPENV}
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${SERVER_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_SERVER_PROCESS}    stderr=${SIPP_TMP}stderr_server.txt    stdout=${SIPP_TMP}stdout_server.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${SERVER_SCENARIO2_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_SERVER2_PROCESS}    stderr=${SIPP_TMP}stderr_server2.txt    stdout=${SIPP_TMP}stdout_server2.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${CLIENT_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_CLIENT_PROCESS}    stderr=${SIPP_TMP}stderr_client.txt    stdout=${SIPP_TMP}stdout_client.txt
    log    sipp Exit status ${rc}


RUN SIPP ONE CLIENT THREE SERVER
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}    ${SERVER_SCENARIO2_FILE}    ${SERVER_SCENARIO3_FILE}
    [Timeout]    3 minute 01 seconds
    CLEAR SIPP DIRECTORIES
    Run    ${SIPPENV}
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${SERVER_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_SERVER_PROCESS}    stderr=${SIPP_TMP}stderr_server.txt    stdout=${SIPP_TMP}stdout_server.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${SERVER_SCENARIO2_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_SERVER2_PROCESS}    stderr=${SIPP_TMP}stderr_server2.txt    stdout=${SIPP_TMP}stdout_server2.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${SERVER_SCENARIO3_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_SERVER3_PROCESS}    stderr=${SIPP_TMP}stderr_server3.txt    stdout=${SIPP_TMP}stdout_server3.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${CLIENT_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_CLIENT_PROCESS}    stderr=${SIPP_TMP}stderr_client.txt    stdout=${SIPP_TMP}stdout_client.txt
    log    sipp Exit status ${rc}


RUN SIPP TWO CLIENT ONE SERVER
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}    ${CLIENT_SCENARIO2_FILE}
    [Timeout]    3 minute 01 seconds
    CLEAR SIPP DIRECTORIES
    Run    ${SIPPENV}
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${SERVER_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_SERVER_PROCESS}    stderr=${SIPP_TMP}stderr_server.txt    stdout=${SIPP_TMP}stdout_server.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${CLIENT_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_CLIENT_PROCESS}    stderr=${SIPP_TMP}stderr_client.txt    stdout=${SIPP_TMP}stdout_client.txt
    log    sipp Exit status ${rc}
    Sleep    10s
    ${rc}=    Process.Start Process    ${SIPP_RUN}${/}${CLIENT_SCENARIO2_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SIPP_CLIENT2_PROCESS}    stderr=${SIPP_TMP}stderr_client2.txt    stdout=${SIPP_TMP}stdout_client2.txt
    log    sipp Exit status ${rc}


VERIFY SIPP SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${SIPP_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout.txt    ${SIPP_PIDGREP}
    ${SIPP_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_PID}    ]
    @{words} =    Split String    ${SIPP_EXT_PID}    [
    Set Test Variable    ${SIP_PID}    ${words[-1]}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${rc}    ${SIPP_greppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_PID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_greppid}
    ${rc}=    Process.Is Process Running    ${SIPP_PROCESS}
    Exit For Loop If    "${SIPP_greppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_PROCESS}
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIPPULL EXECUTION COMPLETED PID is ${SIP_PID}

VERIFY SIPP CLIENT SRVER SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${SIPP_CLIENT_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_client.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server.txt    ${SIPP_PIDGREP}
    ${SIPP_CLIENT_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_CLIENT_PID}    ]
    ${SIPP_SERVER_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER_PID}    ]
    @{words} =    Split String    ${SIPP_CLIENT_EXT_PID}    [
    Set Test Variable    ${SIP_ClientPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER_EXT_PID}    [
    Set Test Variable    ${SIP_ServerPID}    ${words[-1]}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${rc}    ${SIPP_clientgreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ClientPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_clientgreppid}
    ${rc}    ${SIPP_servergreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ServerPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_servergreppid}
    ${rc_client}=    Process.Is Process Running    ${SIPP_CLIENT_PROCESS}
    ${rc_server}=    Process.Is Process Running    ${SIPP_SERVER_PROCESS}
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}" and "${SIPP_servergreppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_CLIENT_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_SERVER_PROCESS}
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT AND SERVER EXECUTION COMPLETED PID is ${SIP_CLIENT_PID} and ${SIP_SERVER_PID}

VERIFY SIPP CLIENT TWO SRVER SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${SIPP_CLIENT_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_client.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER2_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server2.txt    ${SIPP_PIDGREP}
    ${SIPP_CLIENT_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_CLIENT_PID}    ]
    ${SIPP_SERVER_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER_PID}    ]
    ${SIPP_SERVER2_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER2_PID}    ]
    @{words} =    Split String    ${SIPP_CLIENT_EXT_PID}    [
    Set Test Variable    ${SIP_ClientPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER_EXT_PID}    [
    Set Test Variable    ${SIP_ServerPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER2_EXT_PID}    [
    Set Test Variable    ${SIP_Server2PID}    ${words[-1]}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${rc}    ${SIPP_clientgreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ClientPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_clientgreppid}
    ${rc}    ${SIPP_servergreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ServerPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_servergreppid}
    ${rc}    ${SIPP_server2greppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_Server2PID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_servergreppid}
    ${rc_client}=    Process.Is Process Running    ${SIPP_CLIENT_PROCESS}
    ${rc_server}=    Process.Is Process Running    ${SIPP_SERVER_PROCESS}
    ${rc_server2}=    Process.Is Process Running    ${SIPP_SERVER2_PROCESS}
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}" and "${SIPP_servergreppid}"=="${EMPTY}" and "${SIPP_server2greppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_CLIENT_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_SERVER_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_SERVER2_PROCESS}
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT AND TWO SERVER EXECUTION COMPLETED PID is ${SIP_CLIENT_PID} and ${SIP_SERVER_PID} and ${SIP_SERVER2_PID}


VERIFY SIPP CLIENT THREE SRVER SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${SIPP_CLIENT_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_client.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER2_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server2.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER3_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server3.txt    ${SIPP_PIDGREP}
    ${SIPP_CLIENT_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_CLIENT_PID}    ]
    ${SIPP_SERVER_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER_PID}    ]
    ${SIPP_SERVER2_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER2_PID}    ]
    ${SIPP_SERVER3_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER3_PID}    ]
    @{words} =    Split String    ${SIPP_CLIENT_EXT_PID}    [
    Set Test Variable    ${SIP_ClientPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER_EXT_PID}    [
    Set Test Variable    ${SIP_ServerPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER2_EXT_PID}    [
    Set Test Variable    ${SIP_Server2PID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER3_EXT_PID}    [
    Set Test Variable    ${SIP_Server3PID}    ${words[-1]}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${rc}    ${SIPP_clientgreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ClientPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_clientgreppid}
    ${rc}    ${SIPP_servergreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ServerPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_servergreppid}
    ${rc}    ${SIPP_server2greppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_Server2PID} | grep -v grep | awk '{ print $2 }'
    ${rc}    ${SIPP_server3greppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_Server3PID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_servergreppid}
    ${rc_client}=    Process.Is Process Running    ${SIPP_CLIENT_PROCESS}
    ${rc_server}=    Process.Is Process Running    ${SIPP_SERVER_PROCESS}
    ${rc_server2}=    Process.Is Process Running    ${SIPP_SERVER2_PROCESS}
    ${rc_server3}=    Process.Is Process Running    ${SIPP_SERVER3_PROCESS}
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}" and "${SIPP_servergreppid}"=="${EMPTY}" and "${SIPP_server2greppid}"=="${EMPTY}" and "${SIPP_server3greppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_CLIENT_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_SERVER_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_SERVER2_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_SERVER3_PROCESS}
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT AND TWO SERVER EXECUTION COMPLETED PID is ${SIP_CLIENT_PID} and ${SIP_SERVER_PID} and ${SIP_SERVER2_PID} and ${SIP_SERVER3_PID}



VERIFY TWO SIPP CLIENT ONE SRVER SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${SIPP_CLIENT_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_client.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server.txt    ${SIPP_PIDGREP}
    ${SIPP_CLIENT2_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_client2.txt    ${SIPP_PIDGREP}
    ${SIPP_CLIENT_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_CLIENT_PID}    ]
    ${SIPP_SERVER_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER_PID}    ]
    ${SIPP_CLIENT2_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_CLIENT2_PID}    ]
    @{words} =    Split String    ${SIPP_CLIENT_EXT_PID}    [
    Set Test Variable    ${SIP_ClientPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER_EXT_PID}    [
    Set Test Variable    ${SIP_ServerPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_CLIENT2_EXT_PID}    [
    Set Test Variable    ${SIP_Client2PID}    ${words[-1]}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${rc}    ${SIPP_clientgreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ClientPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_clientgreppid}
    ${rc}    ${SIPP_servergreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ServerPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_servergreppid}
    ${rc}    ${SIPP_client2greppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_Client2PID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_client2greppid}
    ${rc_client}=    Process.Is Process Running    ${SIPP_CLIENT_PROCESS}
    ${rc_server}=    Process.Is Process Running    ${SIPP_SERVER_PROCESS}
    ${rc_server2}=    Process.Is Process Running    ${SIPP_CLIENT2_PROCESS}
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}" and "${SIPP_servergreppid}"=="${EMPTY}" and "${SIPP_client2greppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_CLIENT_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_SERVER_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_CLIENT2_PROCESS}
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT AND TWO SERVER EXECUTION COMPLETED PID is ${SIP_CLIENT_PID} and ${SIP_SERVER_PID} and ${SIP_CLIENT2_PID}


VERIFY SIPP CLIENT SERVER RESULT
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}
    ${CLIENT_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${CLIENT_SCENARIO_FILE}
    ${CLIENT_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${CLIENT_SCENARIO_FILE}
    ${CLIENT_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==1 or ${SIPP_PROTO_VALIDATION}==3    VERIFY SIPP MSG RESULT    ${CLIENT_SCENARIO_FILE}
    ${SERVER_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==2 or ${SIPP_PROTO_VALIDATION}==3    VERIFY SIPP MSG RESULT    ${SERVER_SCENARIO_FILE}
    ${TEST_SCENARIO_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${CLIENT_SIPPLOG_RESULT}'in['True','NULL'] and '${CLIENT_SIPPSTAT_RESULT}'in['True','NULL'] and '${SERVER_SIPPLOG_RESULT}'in['True','NULL'] and '${SERVER_SIPPSTAT_RESULT}'in['True','NULL'] and '${CLIENT_SIPPMSG_RESULT}'in['True','NULL','PASS','None'] and '${SERVER_SIPPMSG_RESULT}'in['True','NULL','PASS','None']    PASS    FAIL
    log    ${TEST_SCENARIO_RESULT}
    COPY SIPP SCENARIO LOGS
    [Return]    ${TEST_SCENARIO_RESULT}

VERIFY SIPP CLIENT TWO SERVER RESULT
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}    ${SERVER_SCENARIO2_FILE}
    ${CLIENT_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${CLIENT_SCENARIO_FILE}
    ${CLIENT_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${CLIENT_SCENARIO_FILE}
    ${CLIENT_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==1 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${CLIENT_SCENARIO_FILE}
    ${SERVER_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==2 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER2_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${SERVER_SCENARIO2_FILE}
    ${SERVER2_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${SERVER_SCENARIO2_FILE}
    ${SERVER2_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==3 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${SERVER_SCENARIO2_FILE}
    ${TEST_SCENARIO_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${CLIENT_SIPPLOG_RESULT}'in['True','NULL'] and '${CLIENT_SIPPSTAT_RESULT}'in['True','NULL'] and '${SERVER_SIPPLOG_RESULT}'in['True','NULL'] and '${SERVER_SIPPSTAT_RESULT}'in['True','NULL'] and '${SERVER2_SIPPLOG_RESULT}'in['True','NULL'] and '${SERVER2_SIPPSTAT_RESULT}'in['True','NULL'] and '${CLIENT_SIPPMSG_RESULT}'in['True','NULL','PASS','None'] and '${SERVER_SIPPMSG_RESULT}'in['True','NULL','PASS','None'] and '${SERVER2_SIPPMSG_RESULT}'in['True','NULL','PASS','None']    PASS    FAIL
    log    ${TEST_SCENARIO_RESULT}
    COPY SIPP SCENARIO LOGS
    [Return]    ${TEST_SCENARIO_RESULT}


VERIFY SIPP CLIENT THREE SERVER RESULT
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}    ${SERVER_SCENARIO2_FILE}    ${SERVER_SCENARIO3_FILE}
    ${CLIENT_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${CLIENT_SCENARIO_FILE}
    ${CLIENT_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${CLIENT_SCENARIO_FILE}
    ${CLIENT_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==1 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${CLIENT_SCENARIO_FILE}
    ${SERVER_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==2 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER2_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${SERVER_SCENARIO2_FILE}
    ${SERVER2_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${SERVER_SCENARIO2_FILE}
    ${SERVER3_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${SERVER_SCENARIO3_FILE}
    ${SERVER3_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${SERVER_SCENARIO3_FILE}
    ${SERVER2_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==3 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${SERVER_SCENARIO2_FILE}
    ${SERVER3_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==3 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${SERVER_SCENARIO3_FILE}
    ${TEST_SCENARIO_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${CLIENT_SIPPLOG_RESULT}'in['True','NULL'] and '${CLIENT_SIPPSTAT_RESULT}'in['True','NULL'] and '${SERVER_SIPPLOG_RESULT}'in['True','NULL'] and '${SERVER_SIPPSTAT_RESULT}'in['True','NULL'] and '${SERVER2_SIPPLOG_RESULT}'in['True','NULL'] and '${SERVER2_SIPPSTAT_RESULT}'in['True','NULL'] and '${SERVER3_SIPPSTAT_RESULT}'in['True','NULL'] and '${CLIENT_SIPPMSG_RESULT}'in['True','NULL','PASS','None'] and '${SERVER_SIPPMSG_RESULT}'in['True','NULL','PASS','None'] and '${SERVER2_SIPPMSG_RESULT}'in['True','NULL','PASS','None'] and '${SERVER3_SIPPMSG_RESULT}'in['True','NULL','PASS','None']    PASS    FAIL
    log    ${TEST_SCENARIO_RESULT}
    COPY SIPP SCENARIO LOGS
    [Return]    ${TEST_SCENARIO_RESULT}



VERIFY TWO SIPP CLIENT ONE SERVER RESULT
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}    ${CLIENT_SCENARIO2_FILE}
    ${CLIENT_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${CLIENT_SCENARIO_FILE}
    ${CLIENT_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${CLIENT_SCENARIO_FILE}
    ${CLIENT_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==1 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${CLIENT_SCENARIO_FILE}
    ${SERVER_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${SERVER_SCENARIO_FILE}
    ${SERVER_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==2 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${SERVER_SCENARIO_FILE}
    ${CLIENT2_SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${CLIENT_SCENARIO2_FILE}
    ${CLIENT2_SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${CLIENT_SCENARIO2_FILE}
    ${CLIENT2_SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==3 or ${SIPP_PROTO_VALIDATION}==4    VERIFY SIPP MSG RESULT    ${CLIENT_SCENARIO2_FILE}
    ${TEST_SCENARIO_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${CLIENT_SIPPLOG_RESULT}'in['True','NULL'] and '${CLIENT_SIPPSTAT_RESULT}'in['True','NULL'] and '${SERVER_SIPPLOG_RESULT}'in['True','NULL'] and '${SERVER_SIPPSTAT_RESULT}'in['True','NULL'] and '${CLIENT2_SIPPLOG_RESULT}'in['True','NULL'] and '${CLIENT2_SIPPSTAT_RESULT}'in['True','NULL'] and '${CLIENT_SIPPMSG_RESULT}'in['True','NULL','PASS','None'] and '${SERVER_SIPPMSG_RESULT}'in['True','NULL','PASS','None'] and '${CLIENT2_SIPPSTAT_RESULT}'in['True','NULL','PASS','None']    PASS    FAIL
    log    ${TEST_SCENARIO_RESULT}
    COPY SIPP SCENARIO LOGS
    [Return]    ${TEST_SCENARIO_RESULT}


VERIFY SIPP RESULT
    [Arguments]    ${SCENARIO_FILE}
    ${SIPPLOG_RESULT}=    VERIFY SIPP LOG RESULT    ${SCENARIO_FILE}
    ${SIPPSTAT_RESULT}=    VERIFY SIPP STAT RESULT    ${SCENARIO_FILE}
    ${SIPPMSG_RESULT}=    Run Keyword If    ${SIPP_PROTO_VALIDATION}==1    VERIFY SIPP MSG RESULT    ${SCENARIO_FILE}
    ${TEST_SCENARIO_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SIPPLOG_RESULT}'in['True','NULL'] and '${SIPPSTAT_RESULT}'in['True','NULL'] and '${SIPPMSG_RESULT}'in['True','NULL','PASS','None']    PASS    FAIL
    log    ${TEST_SCENARIO_RESULT}
    COPY SIPP SCENARIO LOGS
    [Return]    ${TEST_SCENARIO_RESULT}

VERIFY SIPP LOG RESULT
    [Arguments]    ${SCENARIO_ID}
    [Timeout]    1 minute 01 seconds
    Sleep    4s
    ${SIPP_log}=    BuiltIn.Run Keyword And Continue On Failure    Run    ls -rt ${SIPP_LOG}${/}${SCENARIO_ID}_VALIDATION* | tail -1
    ${ret} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Grep File    ${SIPP_log}    ${SIPP_RESULT}    encoding=UTF-8    encoding_errors=strict
    ${scen_result}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    Should Contain    ${ret}    SCENARIO_PASS
    [Return]    ${scen_result}

VERIFY SIPP STAT RESULT
    [Arguments]    ${SCENARIO_ID}
    [Timeout]    1 minute 01 seconds
    Sleep    4s
    ${SIPP_log}=    BuiltIn.Run Keyword And Continue On Failure    Run    ls -rt ${SIPP_LOG}${/}${SCENARIO_ID}_STAT* | tail -1
    ${ret} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Get File    ${SIPP_log}    encoding=UTF-8    encoding_errors=strict
    ${retline} =    BuiltIn.Run Keyword And Continue On Failure    String.Get Line    ${ret}    -1
    log    ${retline}
    @{words} =    BuiltIn.Run Keyword And Continue On Failure    String.Split String    ${retline}    ,
    ${scen_result}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    Should Contain    ${words}[15]    1
    log    ${scen_result}
    [Return]    ${scen_result}

VERIFY SIPP MSG RESULT
    [Arguments]    ${SCENARIO_ID}
    [Documentation]    SIPP MESSAGE SPECIFIC FILE LEVEL VALIDATION
    [Timeout]    1 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${SIPP_TEMP_PATH}
    ${temp_sipp_msglog}=    Run    ${SIPP_PROTO_GREP} ${SIPP_LOG}${/}${SCENARIO_ID}_MSG.log ${SIPP_PROTO_GREP_END_STRING}
    Operating System.Append To File    ${SIPP_TEMP_PATH}${TEST_NAME}_${SCENARIO_ID}_MSG.log    ${temp_sipp_msglog}
    ${rc}    ${output}=    Run Keyword If    ${SIPP_PROTO_VALIDATION_TYPE}==1    Run And Return Rc And Output    diff -b ${SIPP_TEMP_PATH}${TEST_NAME}_${SCENARIO_ID}_MSG.log ${SIPP_EXP_PATH}${TEST_NAME}_${SCENARIO_ID}_MSG.log
    ...    ELSE    Run Keyword If    ${SIPP_PROTO_VALIDATION_TYPE}==2    SIPP PROTOCOL VALIDATION TYPE TWO
    ${sipp_proto_status}=    Run Keyword If    ${rc}==${0}    Set Variable    PASS
    ...    ELSE    Set Variable    FAIL
    BuiltIn.Run Keyword If    ${rc}>${0}    BuiltIn.Run Keyword    SIPP_PROTO_LOGGING    ${output}    ${SCENARIO_ID}
    Copy File   ${SIPP_TEMP_PATH}${TEST_NAME}_${SCENARIO_ID}_MSG.log   ${result_path}/SIPP_${TEST_NAME}_${SCENARIO_ID}_MSG_VALIDATION_ACTUAL_RESULT.log 
    [Return]    ${sipp_proto_status}

SIPP PROTOCOL VALIDATION TYPE TWO
    [Documentation]    SIPP PROTOCOL SPECIFIC FILE LEVEL VALIDATION
    [Timeout]    1 minute 01 seconds
    ${rc}    ${test_one}=    Run And Return Rc And Output    sort ${SIPP_TEMP_PATH}${TEST_NAME}_${SCENARIO_ID}_MSG.log
    Operating System.Append To File    ${SIPP_TEMP_PATH}temp1.xml    ${test_one}
    ${rc}    ${test_two}=    Run And Return Rc And Output    sort ${SIPP_EXP_PATH}${TEST_NAME}_${SCENARIO_ID}_MSG.log
    Operating System.Append To File    ${SIPP_TEMP_PATH}temp2.xml    ${test_two}
    ${rc}    ${output}=    Run And Return Rc And Output    diff -b ${SIPP_TEMP_PATH}temp1.xml ${SIPP_TEMP_PATH}temp2.xml
    [Return]    ${rc}    ${output}


SIPP_PROTO_LOGGING
    [Arguments]    ${line}    ${SCENARIO_ID}
    [Documentation]    This Keyword is used to log the PCAP XML Messages for which Test Case Fails
    ${file}=    Set Variable    ${result_path}/SIPP_${TEST_NAME}_${SCENARIO_ID}_MSG_PROTO_FAILURE.txt
    Append To File    ${file}    ${line}
    Append To File    ${file}    ${\n}  


COPY SIPP SCENARIO LOGS
    [Timeout]    1 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Copy Directory    ${SIPP_LOG}    ${result_path}${/}SIPP_LOG

CLEAR SIPP DIRECTORIES
    [Timeout]    1 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${SIPP_LOG}
