*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Process

*** Variables ***

*** Keyword ***
RUN SIPP EXT CLIENT SERVER
    [Arguments]    ${SCENARIO_FILES}
    [Timeout]    3 minute 01 seconds
    Log Many    ${SCENARIO_FILES}
    Set Test Variable    ${CLIENT_SCENARIO_FILE}    ${EMPTY}
    Set Test Variable    ${SERVER_SCENARIO_FILE}    ${EMPTY}
    Set Test Variable    @{list_file_creation}    @{EMPTY}
    Set Test Variable    @{header_client_server_list}    @{EMPTY}
    Set Test Variable    @{file_name_list}    @{EMPTY}
    ${get_list_value}=    Get Length    ${SCENARIO_FILES}
    ${CLIENT_SCENARIO_FILE}=    Run Keyword If    "${get_list_value}"=="1"    Set Variable    @{SCENARIO_FILES}[${0}]
    Run Keyword If    "${get_list_value}"=="2"    Append To List    ${list_file_creation}    @{SCENARIO_FILES}[${1}]    @{SCENARIO_FILES}[${0}]
    ...    ELSE IF    "${get_list_value}"=="1"    Append To List    ${list_file_creation}    ${CLIENT_SCENARIO_FILE}
    ...    ELSE IF    "${get_list_value}"=="3" and ${CLIENT_SERVER_SCENARIO}==${2}    Append To List    ${list_file_creation}    @{SCENARIO_FILES}[${2}]    @{SCENARIO_FILES}[${1}]    @{SCENARIO_FILES}[${0}]
    ...    ELSE IF    "${get_list_value}"=="3" and ${CLIENT_SERVER_SCENARIO}==${3}    Append To List    ${list_file_creation}    @{SCENARIO_FILES}[${1}]    @{SCENARIO_FILES}[${0}]    @{SCENARIO_FILES}[${2}]
    CLEAR EXT SIPP DIRECTORIES
    Run Keyword If    '${msgchk}'=='YES'    set test variable    ${mesgchk}    "-msgcheck"
    ...    ELSE    set test variable    ${mesgchk}    ${msgno}
    Run    ${SEGENV}
    Append To File    ${framework_log_file}    Starting Sipp Client State Machine\n
    Open Connection    ${SIPP_IP_ADDRESS}    ${SIPP_CLIENT_ALIAS}    timeout=30
    ${output}=    Login    ${SIPP_USERNAME}    ${SIPP_PASSWORD}
    ${list_file_creation}=    DELETE COPY SIPP SERVER SCENARIO REMOTE    ${list_file_creation}
    Run Keyword If    "${get_list_value}"=="3" and ${CLIENT_SERVER_SCENARIO}==${2}    Append To List    ${file_name_list}    server    server1    client
    ...    ELSE IF    "${get_list_value}"=="3" and ${CLIENT_SERVER_SCENARIO}==${3}    Append To List    ${file_name_list}    server    client    client1
    ...    ELSE IF    "${get_list_value}"=="2"    Append To List    ${file_name_list}    server    client
    ...    ELSE IF    "${get_list_value}"=="1"    Append To List    ${file_name_list}    client
    FOR    ${i}    IN RANGE    ${get_list_value}
    ${get_list_sipp_value}=    Get From List    ${list_file_creation}    ${i}
    ${fetch_sipp_cmdline}=    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Get File    ${SIPP_RUN}${/}${get_list_sipp_value}.sh    encoding=UTF-8    encoding_errors=strict
    ${fetch_sipp_start}    ${fetch_sipp_end}=    BuiltIn.Run Keyword And Continue On Failure    String.Split String From Right    ${fetch_sipp_cmdline}    ${SPACE}    1
    Log Many    ${fetch_sipp_start}    ${fetch_sipp_end}
    ${get_end_value}=    Remove String    ${fetch_sipp_end}    ${SPACE}
    ${fetch_end_value}=    String.Get Line    ${get_end_value}    0
    ${fetch_start_value}=    String.Get Line    ${fetch_sipp_start}    -1
    ${get_sipp_cmdline}=    Catenate    SEPARATOR=${SPACE}    ${fetch_start_value}    ${fetch_end_value}
    Log Many    ${get_sipp_cmdline}    ${fetch_start_value}    ${fetch_end_value}
    ${getlist_name}=    Set Variable    @{file_name_list}[${i}]
    Run Keyword And Continue On Failure    Remove File    ${SIPP_TMP}${/}stdout_${getlist_name}.txt
    Run Keyword And Continue On Failure    Remove File    ${SIPP_TMP}${/}stderr_${getlist_name}.txt
    ${sipp_start}=    SSHLibrary.Start Command    sudo${SPACE}${SIPP_EXEC_PATH}${/}${get_sipp_cmdline}${SPACE}-bg
    ${sipp_stdout}    ${sipp_err}=    Read Command Output    return_stdout=True	return_stderr=True
    log    Sipp ${getlist_name} Exit status ${sipp_stdout} ${sipp_err}
    Run Keyword And Continue On Failure    Create File    ${SIPP_TMP}${/}stdout_${getlist_name}.txt
    Run Keyword And Continue On Failure    Create File    ${SIPP_TMP}${/}stderr_${getlist_name}.txt
    Append To File    ${SIPP_TMP}${/}stdout_${getlist_name}.txt    ${sipp_stdout}
    Append To File    ${SIPP_TMP}${/}stderr_${getlist_name}.txt    ${sipp_err}
    Run Keyword If    "${get_list_value}"<"${3}"    Sleep    2s
    ...   ELSE    Sleep    5s
    END

   @{fetch_process}=    Split String    ${sipp_stdout}   =
   For    ${i}    in    @{fetch_process}
   ${str}=    Remove String    ${i}    [    ]
   Append To File    ${framework_log_file}    Process ID of the SIPP Client is ${str}\n
   END
   log    Process ID of the SIPP Client is ${str}
   ${result}=    Should Match Regexp    ${str}    [0-9]
   ${result}=    Run Keyword If    ${result} >0    Set Variable    PASS
   ...    ELSE    FAIL
   [Return]     ${result}

DELETE COPY SIPP SERVER SCENARIO REMOTE
    [Arguments]    ${list_file_creation}
    [Timeout]    1 minute 01 seconds
    Set Test Variable    @{server_local_list}    @{EMPTY}  
    ${header_list_count}=    Get Length    ${list_file_creation} 
    FOR    ${i}    IN RANGE    ${header_list_count}
    ${get_header_values}=    Get From List    ${list_file_creation}    ${i}
    ${server_delete_file_out}=    BuiltIn.Run Keyword And Return Status    SSHLibrary.Execute Command    find${SPACE}${SIPP_EXT_CLIENT_PATH}${SPACE}-name${SPACE}*${get_header_values}*|${SPACE}xargs${SPACE}rm${SPACE}-rf
    ${kill_existing_process}=    BuiltIn.Run Keyword And Return Status    SSHLibrary.Execute Command    ps${SPACE}-ef${SPACE}|${SPACE}grep${SPACE}'${get_header_values}*'${SPACE}|${SPACE}grep${SPACE}-v${SPACE}'grep'${SPACE}|${SPACE}awk ${SPACE}'{print $2}'${SPACE}|${SPACE}xargs${SPACE}kill${SPACE}-9
    ${server_local_run_file}=    BuiltIn.Run Keyword    Run    ls -rt ${SIPP_RUN}${/}${get_header_values}.sh
    ${server_local_scen_file}=    BuiltIn.Run Keyword    Run    ls -rt ${SIPP_SCEN}${/}${get_header_values}.xml
    ${server_local_inf_file}=    BuiltIn.Run Keyword    Run    ls -rt ${SIPP_INF}${/}${get_header_values}.csv
    Append To List    ${server_local_list}    ${server_local_run_file}    ${server_local_scen_file}    ${server_local_inf_file}
    ${server_list_count}=    Get Length    ${server_local_list}
    END

    FOR    ${i}    IN RANGE    ${server_list_count}
    ${get_server_file_values}=    Get From List    ${server_local_list}    ${i}
    @{get_server_remote_path}=    Split String From Right    ${get_server_file_values}    /    1
    ${get_server_remote_dir}=    Fetch From Left    @{get_server_remote_path}
    ${get_server_remote_dir}=    Set Variable    ${get_server_remote_dir}${/}
    ${server_file_output}=    SSHLibrary.Put File    ${get_server_file_values}    ${get_server_remote_dir}    mode=0744
    END
    [Return]    ${list_file_creation}


VERIFY SIPP SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${SIPP_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout.txt    ${SIPP_PIDGREP}
    ${SIPP_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_PID}    ]
    @{words} =    Split String    ${SIPP_EXT_PID}    [
    Set Test Variable    ${SIP_PID}    ${words[-1]}
    Switch Connection    ${SIPP_CLIENT_ALIAS}
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

VERIFY SIPP EXT CLIENT SRVER SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    Log Many    ${file_name_list}
    ${SIPP_CLIENT_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_client.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server.txt    ${SIPP_PIDGREP}
    ${SIPP_CLIENT_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_CLIENT_PID}    ]
    ${SIPP_SERVER_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER_PID}    ]
    @{words} =    Split String    ${SIPP_CLIENT_EXT_PID}    [
    Set Test Variable    ${SIP_ClientPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER_EXT_PID}    [
    Set Test Variable    ${SIP_ServerPID}    ${words[-1]}
    Switch Connection    ${SIPP_CLIENT_ALIAS}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${SIPP_clientgreppid} =    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    ps${SPACE}-ef${SPACE}|${SPACE}grep${SPACE}${SIP_ClientPID}${SPACE}|grep${SPACE}-v${SPACE}grep|${SPACE}awk${SPACE}'{print $2}'|head${SPACE}-1
    Log    ${SIPP_clientgreppid}
    ${SIPP_servergreppid} =    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    ps${SPACE}-ef${SPACE}|${SPACE}grep${SPACE}${SIP_ServerPID}${SPACE}|grep${SPACE}-v${SPACE}grep|${SPACE}awk${SPACE}'{print $2}'|head${SPACE}-1
    Log    ${SIPP_servergreppid}
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}" and "${SIPP_servergreppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    ${client_output}=    Run Keyword And Return If    ${index}==${y}    SSHLibrary.Execute Command    ps${SPACE}-ef${SPACE}|${SPACE}grep${SPACE}${SIP_ClientPID}${SPACE}|${SPACE}awk${SPACE}'{print $2}'|head${SPACE}-1|xargs${SPACE}kill${SPACE}-9    return_rc=True
    ${server_output}=    Run Keyword And Return If    ${index}==${y}    SSHLibrary.Execute Command    ps${SPACE}-ef${SPACE}|${SPACE}grep${SPACE}${SIP_ServerPID}${SPACE}|${SPACE}awk${SPACE}'{print $2}'|head${SPACE}-1|xargs${SPACE}kill${SPACE}-9    return_rc=True
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT AND SERVER EXECUTION COMPLETED PID is ${SIP_CLIENT_PID} and ${SIP_SERVER_PID}

VERIFY SIPP EXT SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${SIPP_CLIENT_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_client.txt    ${SIPP_PIDGREP}
    ${SIPP_CLIENT_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_CLIENT_PID}    ]
    @{words} =    Split String    ${SIPP_CLIENT_EXT_PID}    [
    Set Test Variable    ${SIP_ClientPID}    ${words[-1]}
    Switch Connection    ${SIPP_CLIENT_ALIAS}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${SIPP_clientgreppid} =    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    ps${SPACE}-ef${SPACE}|${SPACE}grep${SPACE}${SIP_ClientPID}${SPACE}|grep${SPACE}-v${SPACE}grep|${SPACE}awk${SPACE}'{print $2}'|head${SPACE}-1
    Log    ${SIPP_clientgreppid}
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    ${client_output}=    Run Keyword And Return If    ${index}==${y}    SSHLibrary.Execute Command    ps${SPACE}-ef${SPACE}|${SPACE}grep${SPACE}${SIP_ClientPID}${SPACE}|${SPACE}awk${SPACE}'{print $2}'|head${SPACE}-1|xargs${SPACE}kill${SPACE}-9    return_rc=True
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT EXECUTION COMPLETED PID is ${SIP_CLIENT_PID}


VERIFY SIPP EXT CLIENT TWO SRVER SCENARIO STATUS
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
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}" and "${SIPP_servergreppid}"=="${EMPTY}" and "${SIPP_server2greppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT AND TWO SERVER EXECUTION COMPLETED PID is ${SIP_CLIENT_PID} and ${SIP_SERVER_PID} and ${SIP_SERVER2_PID}


VERIFY TWO SIPP EXT CLIENT ONE SRVER SCENARIO STATUS
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
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}" and "${SIPP_servergreppid}"=="${EMPTY}" and "${SIPP_client2greppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT AND TWO SERVER EXECUTION COMPLETED PID is ${SIP_CLIENT_PID} and ${SIP_SERVER_PID} and ${SIP_CLIENT2_PID}


VERIFY SIPP EXT CLIENT SERVER RESULT
    [Timeout]    3 minute 01 seconds
    Set Test Variable    &{SCENARIO_DICT_FILE}    &{EMPTY}
    Log Many    ${list_file_creation}
    ${list_length}=    Get Length    ${list_file_creation}
    COPY SIPP EXT SCENARIO LOGS REMOTE
    FOR    ${index}    IN RANGE    ${list_length}
    ${get_file_name}=    Get From List    ${list_file_creation}    ${index}
    ${get_prefix_name}=    Get From List    ${file_name_list}    ${index}
    ${SIPPLOG_RESULT}=    VERIFY SIPP EXT LOG RESULT    ${get_file_name}
    ${SIPPSTAT_RESULT}=    VERIFY SIPP EXT STAT RESULT    ${get_file_name}
    ${SIPPLOG_RESULTS}=    Catenate  SEPARATOR=_    ${get_prefix_name}    log
    ${SIPPSTAT_RESULTS}=    Catenate  SEPARATOR=_    ${get_prefix_name}    stat
    Set To Dictionary    ${SCENARIO_DICT_FILE}    ${SIPPLOG_RESULTS}    ${SIPPLOG_RESULT}    ${SIPPSTAT_RESULTS}    ${SIPPSTAT_RESULT}
    END
    ${get_dict_content}=    Get Dictionary Values    ${SCENARIO_DICT_FILE}
    ${TEST_SCENARIO_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    'False' in ${get_dict_content}    FAIL    PASS 
    log    ${TEST_SCENARIO_RESULT}
    COPY SIPP EXT SCENARIO LOGS RESULT
    [Return]    ${TEST_SCENARIO_RESULT}


VERIFY SIPP EXT LOG RESULT
    [Arguments]    ${SCENARIO_ID}
    [Timeout]    1 minute 01 seconds
    Sleep    4s
    ${SIPP_log}=    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    ls -rt ${SIPP_LOG}${/}${SCENARIO_ID}_VALIDATION* | tail -1
    ${ret} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Grep File    ${SIPP_log}    ${SIPP_RESULT}    encoding=UTF-8    encoding_errors=strict
    ${scen_result}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    Should Contain    ${ret}    SCENARIO_PASS
    [Return]    ${scen_result}

VERIFY SIPP EXT STAT RESULT
    [Arguments]    ${SCENARIO_ID}
    [Timeout]    1 minute 01 seconds
    Sleep    4s
    ${SIPP_log}=    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    ls -rt ${SIPP_LOG}${/}${SCENARIO_ID}_STAT* | tail -1
    ${ret} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Get File    ${SIPP_log}    encoding=UTF-8    encoding_errors=strict
    ${retline} =    BuiltIn.Run Keyword And Continue On Failure    String.Get Line    ${ret}    -1
    log    ${retline}
    @{words} =    BuiltIn.Run Keyword And Continue On Failure    String.Split String    ${retline}    ,
    ${scen_result}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    Should Contain    @{words}[15]    1
    log    ${scen_result}
    [Return]    ${scen_result}

COPY SIPP EXT SCENARIO LOGS RESULT
    [Timeout]    1 minute 01 seconds
    ${SIPP_LOG}=    Catenate    SEPARATOR=    ${SIPP_LOG}    ${/}
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Copy Directory    ${SIPP_LOG}    ${result_path}${/}SIPP_LOG

COPY SIPP EXT SCENARIO LOGS REMOTE
    [Timeout]    1 minute 01 seconds
    Switch Connection    ${SIPP_CLIENT_ALIAS}
    ${SIPP_LOG}=    Catenate    SEPARATOR=    ${SIPP_LOG}    ${/}
    ${output}=    SSHLibrary.Get File    ${SIPP_LOG}    ${SIPP_LOG}

SIPP STATS COUNT
    [Arguments]    ${TEST_NAME}    ${dict_ref_item}
    Set Test Variable    @{sipp_server_result}    @{Empty}
    Set Test Variable    @{current_split_list}    @{Empty}
    ${first_line_file}=    BuiltIn.Run Keyword    OperatingSystem.Run    cat ${result_path}${/}${TEST_NAME}_*_counts.csv | head -1
    ${last_line_file}=    BuiltIn.Run Keyword    OperatingSystem.Run    cat ${result_path}${/}${TEST_NAME}_*_counts.csv | tail -1
    ${first_line_split}=    Split String    ${first_line_file}    ,
    FOR    ${i}    IN    @{first_line_split}
    ${current_fetch_value}=    Split String    ${i}    _    1
    ${current_split_value}=    Set Variable    @{current_fetch_value}[-1]
    Append To List    ${current_split_list}    ${current_split_value}
    END
    ${last_line_split}=    Split String    ${last_line_file}    ,
    ${length_list_server}=    Get Length    ${first_line_split}
    FOR    ${i}    IN    @{dict_ref_item.keys()}
    ${reference_value}=    Get From Dictionary    ${dict_ref_item}    ${i}
    ${current_index}=    Get Index From List    ${current_split_list}    ${i}
    ${current_value}=    Get From List    ${last_line_split}    ${current_index}
    ${result}=     Run Keyword If    ${reference_value}==${current_value}    Set Variable    PASS
    ...    ELSE    Set Variable    FAIL
    Append To List    ${sipp_server_result}    ${result}
    END
    [Return]    ${sipp_server_result}


REFERENCES SIPP STATS COUNT
    [Documentation]    This keyword will take the sipp stats count from the reference file.
    Set Test Variable    &{dict_ref_item}    &{EMPTY}
    ${filecontent}=    OperatingSystem.Get File    ${PRE_POST_VALIDATE_PATH}/SIPP_STATS/${TEST_NAME}_SIP_STATS_${pcap_alias}.xml
    ${strp_string}=    Remove String    ${filecontent}    ${SPACE}
    ${splitline}=    Split To Lines    ${strp_string}
    ${getlength}=    Get Length    ${splitline}
    FOR    ${i}    IN    @{splitline}
    ${fetch_content}=    Split String    ${i}    :    1
    ${fetch_tag}=    Get From List    ${fetch_content}    0
    ${fetch_values}=    Get From List     ${fetch_content}    1
    ${fetch_tag}=    Remove String    ${fetch_tag}    ${SPACE}
    ${fetch_values}=    Remove String    ${fetch_values}    ${SPACE}
    ${ref_dict_value}=    Set To Dictionary    ${dict_ref_item}    ${fetch_tag}    ${fetch_values}
    END
    ${status}=    SERVER SIPP STATS COUNT    ${TEST_NAME}    ${dict_ref_item}
    List Should Not Contain Value    ${status}    FAIL
    [Return]    ${status}


CLEAR EXT SIPP DIRECTORIES
    [Timeout]    1 minute 01 seconds
    ${SIPP_LOG_LOCAL}=    Catenate    SEPARATOR=    ${SIPP_LOG}    ${/}
    ${SIPP_LOG_REMOTE}=    Catenate    SEPARATOR=    ${SIPP_LOG}    ${/}*
    Open Connection    ${SIPP_IP_ADDRESS}    ${SIPP_CLIENT_ALIAS}    timeout=30
    ${output}=    Login    ${SIPP_USERNAME}    ${SIPP_PASSWORD}
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${SIPP_LOG_LOCAL}
    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm -rf ${SIPP_LOG_REMOTE}