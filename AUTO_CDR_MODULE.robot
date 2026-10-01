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
CDR INITIALIZE
    Set Test Variable    &{file_and_pre_cdr_count_dict}    &{EMPTY}
    Set Test Variable    &{file_and_pre_file_cdr_count_dict}    &{EMPTY}
    Set Test Variable    &{file_and_server_cdr_dict}    &{EMPTY}
    Set Test Variable    &{file_and_post_cdr_count_dict}    &{EMPTY}
    Set Test Variable    &{file_and_post_file_cdr_count_dict}    &{EMPTY}
    Set Test Variable    @{pre_cdr_files}    @{EMPTY}
    Set Test Variable    @{post_cdr_files}    @{EMPTY}

CDR COUNT
    [Arguments]    ${alias}    ${path}    ${grep_string}
    Switch Connection    ${alias}
    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Ignore Error    SSHLibrary.Directory Should Exist    ${path}
    ${pre_count}=    SSHLibrary.Execute Command    ${grep_string}
    log    ${timestamp}
    [Return]    ${pre_count}


GET CDR PATH
    [Arguments]    ${type}
    ${num_of_paths}=    Get Length    ${REMOTE_CDR_PATH}
    FOR    ${i}    IN RANGE    ${num_of_paths}
    ${logger_path}=    Get From List   ${REMOTE_CDR_PATH}    ${i}
    ${grep}=    Prepare CDR Grep String    ${logger_path}    ${i}
    Run Keyword If    ${type}==${0}    PREPOSTCDR PROCESS    ${type}    ${logger_path}    ${grep}    ${i}
    ...    ELSE    PREPOSTCDR PROCESS    ${type}    ${logger_path}    ${grep}    ${i}
    END


Prepare CDR Grep String
    [Arguments]    ${path}    ${index}
    ${logger_prefixes}=    Get From List    ${CDR_GREP_PREFIX}    ${index}
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

    
PREPOSTCDR PROCESS
    [Arguments]    ${type}    ${path}    ${grep}    ${index}
    ${alias}=    Get From List    ${CDR_SERVER_ALIAS}    ${index}
    Run Keyword If    ${type}==${1}    Switch Connection    ${alias}
    ${timestamp}=        Run Keyword If    ${type}==${1}    SSHLibrary.Execute Command    date +20%y%m%d%H%M%S
    log    ${timestamp}
    ${plus_time}=    Run Keyword If    ${type}==${1}    Add Time To Date    ${timestamp}    20    result_format=%Y%m%d%H%M%S    exclude_millis=yes    date_format=%Y%m%d%H%M%S
    log    ${plus_time}
    ${string}=    CDR COUNT    ${alias}    ${path}    ${grep}
    @{per_log_details}=    Split String    ${string}    \n
    ${total_num_of_logs}=    Get Length    ${per_log_details}
    FOR    ${i}    IN RANGE    ${total_num_of_logs}
    ${string}=    Get From List    ${per_log_details}    ${i}
    @{list}=    Split String    ${string}    ${SPACE}
    ${file}=    Get From List    ${list}    1
    Set List Value    ${list}    1    ${path}${file}  
    Run Keyword If    ${type}==${0}    Set To Dictionary    ${file_and_pre_cdr_count_dict}    ${list}[1]=${list}[0]
    ...    ELSE    Set To Dictionary    ${file_and_post_cdr_count_dict}    ${list}[1]=${list}[0]
    Run Keyword If    ${type}==${0}    Set To Dictionary    ${file_and_pre_file_cdr_count_dict}    ${list}[1]=${list}[2]
    ...    ELSE    Set To Dictionary    ${file_and_post_file_cdr_count_dict}    ${list}[1]=${list}[2]
    Run Keyword If    ${type}==${0}    Append To List    ${pre_cdr_files}    ${list}[1]
    ...    ELSE    Append To List    ${post_cdr_files}    ${list}[1]
    Run Keyword If    ${type}==${0}    Set To Dictionary    ${file_and_server_cdr_dict}    ${list}[1]=${alias}
    END


FETCH CDR
    Set Test Variable    ${flag}    ${EMPTY}
    ${key_length}=    Get Length    ${pre_cdr_files}
    FOR    ${i}    IN RANGE    ${key_length}
    ${flag}=    Run Keyword If    "${pre_cdr_files}[${i}]"=="${post_cdr_files}[${i}]"    SAME FILE CDR    ${result_path}    ${i}    ${pre_cdr_files}[${i}]    ${post_cdr_files}[${i}]
    ...    ELSE    DIFF FILE CDR    ${result_path}    ${i}    ${pre_cdr_files}[${i}]    ${post_cdr_files}[${i}]
    END
    [Return]    ${flag}

DELIMIT CONVERT
    ${conevrsion_length}=    Get Length    ${CONVERT_INPUT_ALIAS}
    ${conversion_keys}=    Get Dictionary Keys    ${CONVERT_DELIMITERS}
    FOR    ${i}    IN RANGE    ${conevrsion_length}
    ${file_content}=    OperatingSystem.Grep File    ${result_path}/${CONVERT_INPUT_ALIAS}[${i}]*
    CONVERSIONING    ${file_content}    ${conversion_keys}[${i}]
    END

CONVERSIONING
    [Arguments]    ${file_content}    ${keys}
    ${keys_array}=    Split String    ${keys}    d
    FOR    ${i}    IN    @{keys_array}
    ${str}=    Replace String    ${file_content}    ${i}    ${CONVERT_DELIMITERS}[${keys}]
    log    ${str}
    END


SAME FILE CDR
    [Arguments]    ${result_path}    ${index}    ${pre_file}    ${post_file}
    ${delta_count}=    Evaluate    ${file_and_post_cdr_count_dict}[${post_file}] - ${file_and_pre_cdr_count_dict}[${pre_file}]
    Run Keyword If    ${delta_count}!=${0}    Switch Connection    ${file_and_server_cdr_dict}[${pre_file}]
    ${content}=    Run Keyword If    ${delta_count}!=${0}    SSHLibrary.Execute Command    head -n ${file_and_post_cdr_count_dict}[${post_file}] ${post_file} | tail -${delta_count}    return_stdout=True
    ${last}=    Run Keyword If    ${delta_count}!=${0}    Fetch From Right    ${post_file}    /
    ${file}=    Run Keyword If    ${delta_count}!=${0}    Set Variable    ${result_path}${CDR_PREFIX}[${index}]_${last}
    Run Keyword If    ${delta_count}!=${0}    Append To File    ${file}    ${content}
    ${flag}=    Run Keyword If    ${delta_count}!=${0}    CDR FIELD COUNT    ${content}    ${index}
    [Return]    ${flag}    


DIFF FILE CDR
    [Arguments]    ${result_path}    ${index}    ${pre_file}    ${post_file}
    Set Test Variable    @{content_list}    @{EMPTY}
    Set Test Variable    ${flag}    ${EMPTY}
    ${delta_file_count}=    Evaluate    ${file_and_post_file_cdr_count_dict}[${post_file}] - ${file_and_pre_file_cdr_count_dict}[${pre_file}] -1
    ${paths}    ${file}=    Split String From Right    ${post_file}    /    1
    Switch Connection    ${file_and_server_cdr_dict}[${pre_file}]
    ${content}    ${error}=    SSHLibrary.Execute Command    cd ${paths};count=`wc -l < ${pre_file}`;diff=`expr $count - ${file_and_pre_cdr_count_dict}[${pre_file}]`;head -n $count ${pre_file} | tail -$diff;ls -rt | tail -${delta_file_count} | xargs cat;head -n ${file_and_post_cdr_count_dict}[${post_file}] ${post_file}    return_stdout=True    return_stderr=True
    ${content_line}=    Split To Lines    ${content}
    log    ${content_line}
    ${content_length}=    Get Length    ${content_line}
    ${index_increment}=    Set Variable    ${0}
    ${content}=    Run Keyword If    ${content_length}>${0}    CDR REMOVAL    ${content_line}    ${content_length}    ${index}
    ${Actual_list_count}=    Get Length    ${content}
    FOR    ${j}    IN RANGE    ${Actual_list_count}
    ${display_content}=    Set Variable    ${content}[${j}]${\n}
    ${last}=    Fetch From Right    ${post_file}    /
    ${file}=    Set Variable    ${result_path}${CDR_PREFIX}[${index}]_${last}
    Append To File    ${file}    ${display_content}
    ${flag}=    CDR FIELD COUNT    ${display_content}    ${index}
    END
    [Return]    ${flag}

CDR REMOVAL
    [Arguments]    ${removal_content}    ${content_length}    ${i}
    Set Test Variable    ${get_content}    ${EMPTY}
    Set Test Variable    @{list_content}    @{EMPTY}
    ${procheck_content}=    Set Variable    PROLIC
    ${cdr_alias}=    Get Length    ${REF_CDR_INPUT_ALIAS}
    ${str}=    Set Variable    REF_CDR_PATTERN_${i}
    FOR    ${j}    IN RANGE    ${content_length}
    ${get_content}=    Get From List    ${removal_content}    ${j}
    ${content_lines}=    Split String    ${get_content}    ,
    ${content_list_length}=    Get Length    ${content_lines}
    ${status}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    List Should Contain value    ${content_lines}    ${${str}}[${0}]
    ${procheck_status}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    List Should Contain value    ${content_lines}    ${procheck_content}
    BuiltIn.Run Keyword And Continue On Failure    Run Keyword If    ${status}==True or ${procheck_status}==True    Continue For Loop
    ${actual_tdr_content}=    Set Variable    ${content_lines}
    ${actual_tdr_conv}=    Evaluate    ",".join(${actual_tdr_content})
    Append To List    ${list_content}    ${actual_tdr_conv}
    END
    [Return]    ${list_content}

CDR FIELD COUNT
    [Arguments]    ${content}    ${index}
    Set Test Variable    @{total_cdrs}    @{EMPTY}
    Set Test Variable    @{cdr_count_fields}    @{EMPTY}
    Set Test Variable    @{cdr_count_statuses}    @{EMPTY}
    ${total_cdrs}=    Split To Lines    ${content}
    FOR    ${i}    IN    @{total_cdrs}
    @{cdr_count_fields}=    Split String    ${i}    ${DELIMITERS}[${index}]
    ${num_of_fields}=    Get Length    ${cdr_count_fields}
    ${status}=    Run Keyword If    ${TOTAL_CDR_COUNT}[${index}]==${num_of_fields}    Set Variable    ${1}
    ...    ELSE    Set Variable    ${0}
    Append To List    ${cdr_count_statuses}    ${status}
    END
    ${cdr_count_flag}=    Count Values In List    ${cdr_count_statuses}    ${0}
    ${cdr_count_flag}=    Run Keyword If    ${cdr_count_flag}>${0}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    [Return]    ${cdr_count_flag}



CDR PREPROCESSING
    CDR INITIALIZE
    GET CDR PATH    0


CDR
    GET CDR PATH    1
    Append To File    ${framework_log_file}    Capturing CDR\n
    ${cdr_count_flag}=    FETCH CDR
    Append To File    ${framework_log_file}    Validating CDR with Reference\n
    ${flag}=    Run Keyword    CDR VALIDATION
    ${flag}=    Run Keyword If    ${cdr_count_flag}==${0}    Set Variable    FAIL
    ...    ELSE    Set Variable    ${flag}
    Append To File    ${framework_log_file}    CDR Validation Done\n
    [Return]    ${flag}

CDR VALIDATION
    Set Test Variable    @{all_cdr_statuses}    @{EMPTY}
    ${ref_length}=    Get Length    ${REF_CDR_INPUT_ALIAS}
    ${latest_ref_content}=    Set Variable    ${testcase_input}[0]
    FOR    ${i}    IN RANGE    ${ref_length}
    ${command}=    Set Variable    cut -d${DELIMITERS}[${i}] -f${CDR_FIELDS}[${i}]
    ${count}    ${current_content}    @{ref_list}=    INPUT FILE PROCESSING    ${REF_CDR_INPUT_ALIAS}[${i}]_${REF_CDR_INPUT_EXT}[${i}]
    ${ref_cdr_exists}=    Get Length    ${ref_list}
    ${ref_content}=    Run Keyword If    ${ref_cdr_exists}>${0}    LIST TO LINE    @{ref_list}
    Run Keyword If    ${ref_cdr_exists}>${0}    BuiltIn.Run Keyword And Continue On Failure    Create File    ${AUTOMATION_TEMP_PATH}CDR_TEMP.txt    ${ref_content}
    ${ref_content}=    Run Keyword If    ${ref_cdr_exists}>${0}    Run    ${command} ${AUTOMATION_TEMP_PATH}CDR_TEMP.txt

    @{actual_list}=    Run Keyword If    ${ref_cdr_exists}>${0}    OperatingSystem.List Files In Directory    ${result_path}    ${CDR_PREFIX}[${i}]*${REF_CDR_INPUT_EXT}[${i}]
    ${actual_length}=    Run Keyword If    ${ref_cdr_exists}>${0}    Get Length    ${actual_list}
    CONTINUE FOR LOOP IF    "${actual_length}"=="None"
    ${actual_cdr}=    Run Keyword If    ${actual_length}>${0}    Set Variable    ${actual_list}[0]
    ${pattern}=    Run Keyword If    ${actual_length}>${0}    Set Variable    ${REF_CDR_INPUT_EXT}[${i}]
    ${actual_total_content}=    Run Keyword If    ${actual_length}>${0}    Operating System.Get File    ${result_path}${actual_cdr}
    Run Keyword If    ${actual_length}>${0}    BuiltIn.Run Keyword And Continue On Failure    Create File    ${AUTOMATION_TEMP_PATH}CDR_TEMP.txt    ${actual_total_content}
    Run Keyword If    ${actual_length}>${0}    Run    perl -pi -e "s/^/${REF_CDR_INPUT_ALIAS}[${i}]_${REF_CDR_INPUT_EXT}[${i}] : /" ${AUTOMATION_TEMP_PATH}CDR_TEMP.txt
    ${actual_total_content}=    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Grep File    ${AUTOMATION_TEMP_PATH}CDR_TEMP.txt    *?*
    Run Keyword If    ${actual_length}>${0}    WRITE LATEST REF FILE    ${actual_total_content}\n
    ${actual_content}=    Run Keyword If    ${actual_length}>${0}    Run    ${command} ${result_path}${actual_cdr}

    ${cdr_flag}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword If    ${actual_length}>${0}    STRING COMPARE    ${actual_content}    ${ref_content}
    ${cdr_temp_flag}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword If    ${actual_length}>${0}    Run Keyword If    ${cdr_flag}==${0}    CDR PROCESSING    ${pattern}    ${i}    ${ref_content}    ${actual_content}    ${REF_CDR_INPUT_ALIAS}[${i}]_${REF_CDR_INPUT_EXT}[${i}]
    Run Keyword If    ${actual_length}>${0}    Append To List    ${all_cdr_statuses}    ${cdr_flag}
    END
    ${cdr_flag}=    Count Values In List    ${all_cdr_statuses}    ${0}
    ${no_of_items}=    Get Length    ${all_cdr_statuses}
    ${cdr_flag}=    Run Keyword If    ${cdr_flag}>${0}    Set Variable    FAIL
    ...    ELSE IF    ${no_of_items}>${0}    Set Variable    PASS
    ...    ELSE    Set Variable    NONE
    [Return]    ${cdr_flag}

STRING COMPARE
    [Arguments]    ${actual_content}    ${ref_content}
    ${values}=    Run Keyword And Return Status    Should Be Equal As Strings    ${actual_content}    ${ref_content}
    ${values}=    Run Keyword If    ${values}==${True}    Set Variable    ${1}
    ...    ELSE    Set Variable    ${0}
    log    ${values}
    [Return]    ${values}


RETURN CDR STRING
    [Arguments]    ${ref_cdr}    ${cdr_fld}    ${delimit}
    ${result}=    Set Variable    ${EMPTY}
    ${hor_colon_fields}=    Split String    ${cdr_fld}    ,
    FOR    ${i}    IN    @{ref_cdr}
    ${temp}=    Get Optimized CDR    ${i}    ${hor_colon_fields}    ${delimit}
    ${result}=    Set Variable    ${result}${temp}
    END
    [Return]    ${result}


EXTRACT REF CDR
    [Arguments]    ${ref_cdr}    ${cdr_fld}    ${delimit}
    ${hor_colon_fields}=    Split String    ${cdr_fld}    ,
    ${optimized_cdr}=    Get Optimized CDR    ${ref_cdr}    ${hor_colon_fields}    ${delimit}
    [Return]    ${optimized_cdr}


Get Optimized CDR
    [Arguments]    ${ref_cdr}    ${hor_colon_fields}    ${delimit}
    Set Test Variable    ${cdr_results}    ${EMPTY}
    ${num_of_hor_colon_fields}=    Get Length    ${hor_colon_fields}
    ${num_of_colons}=    Evaluate    ${num_of_hor_colon_fields}-${1}
    FOR    ${i}    IN RANGE    ${num_of_hor_colon_fields}
    @{list_in}=    Split String    ${ref_cdr}    ${delimit}
    ${first}    ${last}=    Split String    ${hor_colon_fields}[${i}]    ..    1
    ${last}=    Evaluate    ${last}+${1}
    ${list_out}=    Get Slice From List	${list_in}    ${first}    ${last}
    ${delimit_flag}=    Run Keyword If    ${i}<${num_of_colons}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    ${temp}=    LIST TO CSV    ${delimit}    ${delimit_flag}    ${list_out}
    ${cdr_results}=    Set Variable    ${cdr_results}${temp}
    END
    ${cdr_results}=    Set Variable    ${cdr_results}\n
    [Return]    ${cdr_results}



LIST TO CSV
    [Arguments]    ${delimit}    ${delimit_flag}    ${list}
    [Documentation]    This Keyword used to convert the list type into string type,gets no of elements in list and list as arguments
    [Timeout]    3 minute
    ${result}=    Set Variable    ${EMPTY}
    ${length}=    Get Length    ${list}
    ${temp_length}=    Evaluate    ${length}-${1}
    FOR    ${i}    IN RANGE    ${length}
    ${result}=    Run Keyword If    ${delimit_flag}==${0}    Set Variable    ${result}${list}[${i}]${delimit}
    ...    ELSE    Run Keyword    BOUNDARY CHECK    ${i}    ${temp_length}    ${result}    ${delimit}    ${list}[${i}]
    END
    [Return]    ${result}


BOUNDARY CHECK
    [Arguments]    ${index}    ${temp_length}    ${result}    ${delimit}    ${list}
    ${result}=    Run Keyword If    ${index}<${temp_length}    Set Variable    ${result}${list}${delimit}
    ...    ELSE    Set Variable    ${result}${list}
    [Return]    ${result}


LIST TO LINE
    [Arguments]    @{list}
    [Documentation]    This Keyword used to convert the list type into string type,gets no of elements in list and list as arguments
    [Timeout]    3 minute
    ${result}=    Set Variable    ${EMPTY}
    FOR    ${i}    IN    @{list}
    ${result}=    Set Variable    ${result}${i}\n
    END
    [Return]    ${result}
    
     

Create Index
    [Arguments]    ${first}    ${last}
    Set Test Variable    @{cdr_index_result}    @{EMPTY}
    FOR    ${i}    IN RANGE    ${first}    ${last}+1
    Append To List    ${cdr_index_result}    ${i}
    END
    [Return]    ${cdr_index_result}    



CDR PROCESSING
    [Arguments]    ${pattern}    ${index}    ${reference}    ${actual}    ${cdr_pattern}
    Set Test Variable    @{cdr_total_status}    @{EMPTY}
    ${reference_count}=    Get Line Count    ${reference}
    ${actual_count}=    Get Line Count    ${actual}
    ${line_no_status}=    Run Keyword If    ${reference_count}!=${actual_count}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    Run Keyword If    ${reference_count}!=${actual_count}    Append To FILE    ${result_path}CDR_FAILURE_LOGGING${pattern}    "Number of CDR's mismatched in Reference and Actual CDR - Expected:${reference_count} Actual Count:${actual_count}"\n
    @{reference_list}=    Split To Lines    ${reference}
    @{actual_list}=    Split To Lines    ${actual}
    ${index_count}=    Run Keyword If    ${reference_count}<=${actual_count}    Set Variable    ${reference_count}
    ...    ELSE    Set Variable    ${actual_count}
    FOR    ${j}    IN RANGE    ${index_count}
    @{ref_values}=    Split String    ${reference_list}[${j}]    ${DELIMITERS}[${index}]
    @{actual_values}=    Split String    ${actual_list}[${j}]    ${DELIMITERS}[${index}]
    ${temp}=    Set Variable    ${cdr_pattern} : 
    ${results}=    BuiltIn.Run Keyword And Continue On Failure    Compare    ${pattern}    ${index}    ${j}    ${ref_values}    ${actual_values}
    ${cdr_status}=    Count Values In List    ${results}    ${0}
    ${cdr_status}=    Run Keyword If    ${cdr_status}>${0}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    Append To List    ${cdr_total_status}    ${cdr_status}
    END
    ${cdr_flag}=    Count Values In List    ${cdr_total_status}    ${0}
    ${cdr_flag}=    Run Keyword If    ${cdr_flag}>${0}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${line_no_status}
    [Return]    ${cdr_flag}


Compare
    [Arguments]    ${pattern}    ${index}    ${file_no}    ${ref_values}    ${actual_values}
    Set Test Variable    @{results}    @{EMPTY}
    ${count}=    Get Length    ${ref_values}
    FOR    ${i}    IN RANGE    ${count}
    ${src}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable    ${ref_values}[${i}]
    ${dst}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable    ${actual_values}[${i}]
    ${status}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword If    "${src}"!="${dst}"    CDR FAILURE LOGGING    ${pattern}    ${src}    ${dst}    ${i}    ${index}    ${file_no}
    Append To List    ${results}    ${status}
    END
    [Return]    ${results}


CDR FAILURE LOGGING
    [Arguments]    ${pattern}    ${src}    ${dst}    ${i}    ${index}    ${file_no}
    ${str}=    Set Variable    REF_CDR_PATTERN_${index}
    ${file_no}=    Evaluate    ${file_no}+1
    BuiltIn.Run Keyword And Continue On Failure    Append To FILE    ${result_path}CDR_FAILURE_LOGGING${pattern}    "CDR Line Number:${file_no} CDR FIELD:${${str}}[${i}] Actual Value is ${dst} But Expected Value is ${src}"\n
    [Return]    ${0}


 
