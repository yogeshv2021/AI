*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           DateTime
Library           Collections



*** Variables ***


*** Keyword ***
INITIALIZE
    Set Test Variable    &{file_and_pre_count_dict}    &{EMPTY}
    Set Test Variable    &{file_and_pre_file_count_dict}    &{EMPTY}
    Set Test Variable    &{file_and_server_dict}    &{EMPTY}
    Set Test Variable    &{file_and_post_count_dict}    &{EMPTY}
    Set Test Variable    &{file_and_post_file_count_dict}    &{EMPTY}
    Set Test Variable    @{pre_files}    @{EMPTY}
    Set Test Variable    @{post_files}    @{EMPTY}

LOG COUNT
    [Arguments]    ${alias}    ${path}    ${grep_string}
    Switch Connection    ${alias}
    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Ignore Error    SSHLibrary.Directory Should Exist    ${path}
    ${pre_count}=    SSHLibrary.Execute Command    ${grep_string}
    [Return]    ${pre_count}


GET LOG PATH
    [Arguments]    ${type}
    ${num_of_paths}=    Get Length    ${REMOTE_LOGPATH}
    FOR    ${i}    IN RANGE    ${num_of_paths}
    ${logger_path}=    Get From List   ${REMOTE_LOGPATH}    ${i}
    ${grep}=    Prepare Grep String    ${logger_path}    ${i}
    Run Keyword If    ${type}==${0}    PREPOSTLOG PROCESS    ${type}    ${logger_path}    ${grep}    ${i}
    ...    ELSE    PREPOSTLOG PROCESS    ${type}    ${logger_path}    ${grep}    ${i}
    END


Prepare Grep String
    [Arguments]    ${path}    ${index}
    ${logger_prefixes}=    Get From List    ${GREP_PREFIX}    ${index}
    ${file_length}=    Get Length    ${logger_prefixes}
    ${grep_string}=    Set Variable    cd ${path};
    FOR    ${i}    IN RANGE    ${file_length}
    ${prefix}=    Get From List    ${logger_prefixes}    ${i}
    ${prefix}=    Run Keyword If    "${prefix}"!="*"    Set Variable    ${prefix}*
    ...    ELSE    Set Variable    *
    ${temp_string}=    Set Variable    fcount=`ls -rt ${prefix} | wc -l`;fname=`ls -t ${prefix} |head -1`;count=`cat $fname | wc -l`;echo $count $fname $fcount;
    ${grep_string}=    Set Variable    ${grep_string}${temp_string}
    END
    [Return]    ${grep_string}

    
PREPOSTLOG PROCESS
    [Arguments]    ${type}    ${path}    ${grep}    ${index}
    log many    ${type}    ${grep}    ${index}
    ${alias}=    Get From List    ${SERVER_ALIAS}    ${index}
    ${string}=    LOG COUNT    ${alias}    ${path}    ${grep}
    @{per_log_details}=    Split String    ${string}    \n
    ${total_num_of_logs}=    Get Length    ${per_log_details}
    FOR    ${i}    IN RANGE    ${total_num_of_logs}
    ${string}=    Get From List    ${per_log_details}    ${i}
    @{list}=    Split String    ${string}    ${SPACE}
    ${file}=    Get From List    ${list}    1
    Set List Value    ${list}    1    ${path}${file}  
    Run Keyword If    ${type}==${0}    Set To Dictionary    ${file_and_pre_count_dict}    ${list}[1]=${list}[0]
    ...    ELSE    Set To Dictionary    ${file_and_post_count_dict}    ${list}[1]=${list}[0]
    Run Keyword If    ${type}==${0}    Set To Dictionary    ${file_and_pre_file_count_dict}    ${list}[1]=${list}[2]
    ...    ELSE    Set To Dictionary    ${file_and_post_file_count_dict}    ${list}[1]=${list}[2]
    Run Keyword If    ${type}==${0}    Append To List    ${pre_files}    ${list}[1]
    ...    ELSE    Append To List    ${post_files}    ${list}[1]
    Run Keyword If    ${type}==${0}    Set To Dictionary    ${file_and_server_dict}    ${list}[1]=${alias}
    END


FETCH LOG
    Set Test Variable    ${log_content}    ${EMPTY}
    Set Test Variable    @{pattern_global_status}    @{EMPTY}
    ${key_length}=    Get Length    ${pre_files}
    ${log_pattern_length}=    Get Length    ${log_pattern_input_alias}
    FOR    ${i}    IN RANGE    ${key_length}
    ${log_content}    ${prefix}=    Run Keyword If    "${pre_files}[${i}]"=="${post_files}[${i}]"    SAME FILE LOGS    ${result_path}    ${i}    ${pre_files}[${i}]    ${post_files}[${i}]
    ...    ELSE    DIFF FILE LOGS    ${result_path}    ${i}    ${pre_files}[${i}]    ${post_files}[${i}]
    ${status}=    BuiltIn.Run Keyword If    ${LOG_PATTERN_VALIDATION}==${1}    Run Keyword If    "${log_content}"!="${None}"    LOG PATTERN VALIDATION    ${log_content}    ${prefix}
    ...    ELSE    Set Variable    pass
    Append To List    ${pattern_global_status}    ${status}
    END
    ${pattern_flag}=    Count Values In List    ${pattern_global_status}   ${0}
    ${pattern_flag}=    Run Keyword If    ${pattern_flag}>${0}    Set Variable    ${FAIL}
    ...    ELSE    Set Variable    PASS
    [Return]    ${pattern_flag}

LOG PATTERN VALIDATION
    [Arguments]    ${content}    ${prefix}
    [Timeout]    3 minute
    ${log_key}=    Get Dictionary Keys    ${log_pattern_input_alias}
    ${log_keys_check}=    Get Index From List    ${log_key}    ${prefix}
    ${count}    ${current_content}    @{result}=    Run Keyword If    ${log_keys_check}!=${-1}    INPUT FILE PROCESSING    ${log_pattern_input_alias}[${prefix}]_LOG
    ...    ELSE    Set Variable    ${0}    ${EMPTY}
    BuiltIn.Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    ${pattern_per_flag}=    BuiltIn.Run Keyword If    "${count}"!="${0}"    LOG PATTERN STATUS    ${content}    @{result}
    [Return]    ${pattern_per_flag}


LOG PATTERN STATUS
    [Arguments]    ${content}    @{result}
    Set Test Variable    @{pattern_status}    @{EMPTY}
    ${result_length}=    Get Length    ${result}
    FOR    ${i}    IN RANGE    ${result_length}
    ${lines}=    Operating System.Grep File    ${content}    ${result}[${i}]
    ${line_status}=    Get Length    ${lines}
    ${line_status}=    Run Keyword If    ${line_status}>${0}    Set Variable    ${1}
    ...    ELSE    Set Variable    ${0}
    Append To List    ${pattern_status}    ${line_status}
    END
    ${pattern_flag}=    Count Values In List    ${pattern_status}   ${0}
    ${pattern_flag}=    Run Keyword If    ${pattern_flag}>${0}    Set Variable    ${FALSE}
    ...    ELSE    Set Variable    pass
    [Return]    ${pattern_flag}


SAME FILE LOGS
    [Arguments]    ${result_path}    ${index}    ${pre_file}    ${post_file}
    ${delta_count}=    Evaluate    ${file_and_post_count_dict}[${post_file}] - ${file_and_pre_count_dict}[${pre_file}]
    Run Keyword If    ${delta_count}!=${0}    Switch Connection    ${file_and_server_dict}[${pre_file}]
    ${content}=    Run Keyword If    ${delta_count}!=${0}    SSHLibrary.Execute Command    head -n ${file_and_post_count_dict}[${post_file}] ${post_file} | tail -${delta_count}    return_stdout=True
    ${last}=    Run Keyword If    ${delta_count}!=${0}    Fetch From Right    ${post_file}    /
    ${file}=    Run Keyword If    ${delta_count}!=${0}    Set Variable    ${result_path}${LOG_PREFIX}[${index}]_${last}
    Run Keyword If    ${delta_count}!=${0}    Append To File    ${file}    ${content}
    ${log_content}=    BuiltIn.Run Keyword If    ${LOG_PATTERN_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${delta_count}!=${0}    Set Variable    ${file}
    [Return]    ${log_content}    ${LOG_PREFIX}[${index}]


DIFF FILE LOGS
    [Arguments]    ${result_path}    ${index}    ${pre_file}    ${post_file}
    ${delta_file_count}=    Evaluate    ${file_and_post_file_count_dict}[${post_file}] - ${file_and_pre_file_count_dict}[${pre_file}] -1
    ${paths}    ${file}=    Split String From Right    ${post_file}    /    1
    Switch Connection    ${file_and_server_dict}[${pre_file}]
    ${content}    ${error}=    SSHLibrary.Execute Command    cd ${paths};count=`wc -l < ${pre_file}`;diff=`expr $count - ${file_and_pre_count_dict}[${pre_file}]`;head -n $count ${pre_file} | tail -$diff;ls -rt | tail -${delta_file_count} | xargs cat;head -n ${file_and_post_count_dict}[${post_file}] ${post_file}    return_stdout=True    return_stderr=True
    ${last}=    Fetch From Right    ${post_file}    /
    ${file}=    Set Variable    ${result_path}${LOG_PREFIX}[${index}]_${last}
    Append To File    ${file}    ${content}
    ${log_content}=    BuiltIn.Run Keyword If    ${LOG_PATTERN_VALIDATION}==${1}    Set Variable    ${file}
    [Return]    ${log_content}    ${LOG_PREFIX}[${index}]


LOGGER
    Append To File    ${framework_log_file}    Started Logging\n
    GET LOG PATH    1
    ${status}=    FETCH LOG
    Append To File    ${framework_log_file}    Logging Completed\n
    [Return]    ${status}
