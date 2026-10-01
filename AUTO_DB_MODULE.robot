*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           DateTime
Library           DatabaseLibrary



*** Variables ***



*** Keyword ***
PRECONDITION
    [Documentation]    This Keyword is used to connect to all databases configured and execute precondition DB Queries
    [Timeout]    3 minute
    ${pre_db_query_length}=    Get Length    ${precondition_input_alias}
    Append To File    ${framework_log_file}    Starting Database Precondition Execution\n
    FOR    ${i}    IN RANGE        ${pre_db_query_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${precondition_input_alias}[${i}]_DB_PRE
    Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    Run Keyword If    "${count}"!="${0}"    CONNECT DATABASE    ${DB_TYPE}[${i}]    ${DB_CONNECTION_STRING}[${i}]
    Run Keyword If    "${count}"!="${0}"    EXECUTE PRECONDITION    @{result}
    Run Keyword If    "${count}"!="${0}"    DatabaseLibrary.Disconnect from Database
    END
    Append To File    ${framework_log_file}    Stopping Database Precondition Execution\n

   

ONCALLDBCONDITION
    [Documentation]    This Keyword is used to connect to all databases configured and execute On Call DB Queries
    [Timeout]    3 minute
    ${oncall_db_query_length}=    Get Length    ${oncallcondition_input_alias}
    Append To File    ${framework_log_file}    Starting Database On Call DB condition Execution\n
    FOR    ${i}    IN RANGE        ${oncall_db_query_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${oncallcondition_input_alias}[${i}]_DB_ON
    Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    Run Keyword If    "${count}"!="${0}"    CONNECT DATABASE    ${DB_TYPE}[${i}]    ${DB_CONNECTION_STRING}[${i}]
    Run Keyword If    "${count}"!="${0}"    EXECUTE PRECONDITION    @{result}
    Run Keyword If    "${count}"!="${0}"    DatabaseLibrary.Disconnect from Database
    END
    Append To File    ${framework_log_file}    Stopping Database On Call DB condition Execution\n



POSTCONDITION WITH MSISDN
    [Documentation]    This Keyword is used to connect to all databases configured, execute post condition DB Queries & captures the values from DB at the time of test case execution for debugging
    [Timeout]    3 minute
    Set Test Variable    @{post_status}    @{EMPTY}
    Set Test Variable    @{post_results}    @{EMPTY}
    ${post_db_query_length}=    Get Length    ${postcondition_input_alias}
    Append To File    ${framework_log_file}    Starting Database Post condition Execution\n
    FOR    ${i}    IN RANGE        ${post_db_query_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${postcondition_input_alias}[${i}]_DB_POST
    Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    Run Keyword If    "${count}"!="${0}"    CONNECT DATABASE    ${DB_TYPE}[${i}]    ${DB_CONNECTION_STRING}[${i}]
    ${post_result}=    Run Keyword If    "${count}"!="${0}"    EXECUTE POSTCONDITION    ${result_file_name}    @{result}
    Append To List    ${post_results}    ${post_result}
    Run Keyword If    ${post_result}==${0}    DB FAILURE LOGGING    ${result_file_name}    ${debug_queries}[${i}]
    Run Keyword If    "${count}"!="${0}"    DatabaseLibrary.Disconnect from Database
    END
    ${post_flag}=    Count Values In List    ${post_results}   ${0}
    ${no_of_items}=    Get Length    ${post_results}
    ${db_flag}=    Run Keyword If    ${post_flag}>${0}    Set Variable    ${FAIL}
    ...    ELSE IF    ${no_of_items}>${0}    Set Variable    PASS
    ...    ELSE    Set Variable    NONE
    Append To File    ${framework_log_file}    Stopping Database Post condition Execution\n
    [Return]    ${db_flag}



POSTCONDITION
    [Documentation]    This Keyword is used to connect to all databases configured and execute post condition DB Queries
    [Timeout]    3 minute
    Set Test Variable    @{post_status}    @{EMPTY}
    Set Test Variable    @{post_results}    @{EMPTY}
    ${post_db_query_length}=    Get Length    ${postcondition_input_alias}
    Append To File    ${framework_log_file}    Starting Database Post condition Execution\n
    FOR    ${i}    IN RANGE        ${post_db_query_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${postcondition_input_alias}[${i}]_DB_POST
    Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    Run Keyword If    "${count}"!="${0}"    CONNECT DATABASE    ${DB_TYPE}[${i}]    ${DB_CONNECTION_STRING}[${i}]
    ${post_result}=    Run Keyword If    "${count}"!="${0}"    EXECUTE POSTCONDITION    ${result_file_name}    @{result}
    Append To List    ${post_results}    ${post_result}
    Run Keyword If    "${count}"!="${0}"    DatabaseLibrary.Disconnect from Database
    END
    ${post_flag}=    Count Values In List    ${post_results}   ${0}
    ${no_of_items}=    Get Length    ${post_results}
    ${db_flag}=    Run Keyword If    ${post_flag}>${0}    Set Variable    ${FAIL}
    ...    ELSE IF    ${no_of_items}>${0}    Set Variable    PASS
    ...    ELSE    Set Variable    NONE
    Append To File    ${framework_log_file}    Stopping Database Post condition Execution\n
    [Return]    ${db_flag}



NEW FILE TO ARRAY
    [Arguments]    ${test}    ${current_content}
    [Documentation]    This Keyword is used to extract the db queries for the testcase from the set of loaded db queries
    [Timeout]    3 minute
    ${end}=    Set Variable    ${test}${postfix}
    @{lines}    Split To Lines    ${current_content}
    ${source}=    Get Index From List    ${lines}    ${test}
    ${dest}=    Get Index From List    ${lines}    ${end}
    ${line}=    Get Slice From List    ${lines}    ${source}    ${dest}
    ${count}=    Get Length    ${line}
    Run Keyword If    "${count}"!="${0}"    Remove From List    ${line}    0
    [Return]    ${count}    @{line}


CONNECT DATABASE
    [Arguments]    ${DBTYPE}    ${DB_CONNECTION_STRING}
    [Documentation]    This Keyword is used to connect to database
    [Timeout]    3 minute
    Append To File    ${framework_log_file}    Connecting To Database"${DB_CONNECTION_STRING}\n
    Run Keyword If    "${DBTYPE}"!="pymysql"    DatabaseLibrary.Connect To Database Using Custom Params    ${DBTYPE}    '${DB_CONNECTION_STRING}'
    ...    ELSE    DatabaseLibrary.Connect To Database Using Custom Params    ${DBTYPE}    ${DB_CONNECTION_STRING}



EXECUTE PRECONDITION
    [Arguments]    @{query}
    [Documentation]    This Keyword is used to execute the query passed as arguments
    [Timeout]    3 minute
    FOR    ${q}    IN    @{query}
    ${q}=    Run Keyword If    ${DB_UPDATE_TIME}==${1}    SYSTIME COMPUTE    ${q}
    ...    ELSE    Set Variable    ${q}
    Execute Sql String    ${q}
    Append To File    ${framework_log_file}    Executing DB Query "${q}"\n
    END


EXECUTE POSTCONDITION
    [Arguments]    ${log_dir_name}    @{query}
    [Documentation]    This Keyword used to create db result log file,execute post condition db queries passed in arguments,returns pass/fail status and log the result
    [Timeout]    3 minute
    Set Test Variable    @{result_query}    @{EMPTY}
    ${log_file_name}=    CREATE RESULT FILE    ${log_dir_name}    DB_QUERY
    FOR    ${q}    IN    @{query}
    ${row_count}    Row Count    ${q}
    Append To File    ${framework_log_file}    Executing DB Query "${q}"\n
    Append To List    ${post_status}    ${row_count}
    Append To List    ${result_query}    ${q}${SPACE}:${row_count}\n
    END
    ${post_flag}=    Count Values In List    ${post_status}   ${0}
    ${post_flag}=    Set Variable If    ${post_flag}>${0}    ${0}
    DB LOG MOVING    ${log_file_name}    ${result_query}
    [Return]    ${post_flag}


DB FAILURE LOGGING
    [Arguments]    ${file_name}    ${query}
    [Documentation]    This Keyword used to capture the values of DB at the time of test case execution from DB DEBUG QUERY file & logs the result in logging file
    [Timeout]    3 minute
    ${length}=    Get Length    ${query}
    ${res_query}=    Set Variable    ${EMPTY}
    ${db_debug_log_name}=    CREATE RESULT FILE    ${file_name}    DB_DEBUG_QUERY
    ${num_of_queries}=    Get Line Count    ${query}
    FOR    ${i}    IN RANGE    ${num_of_queries}
    ${current_query}=    Get Line    ${query}    ${i}
    ${flag}    ${temp}=    Run Keyword If    ${length}>${0}    REPLACE DUMMY    ${current_query}
    ${res_query}=    Run Keyword If    ${flag}!=${1}    Set Variable    ${res_query}${temp}\n
    ...    ELSE    Set Variable    ${res_query}
    END
    Run Keyword If    ${length}>${0}    COPY DB QUERIES    ${db_debug_log_name}    ${res_query}


REPLACE DUMMY
    [Arguments]    ${query}
    ${dummy_length}=    Get Length    ${DUMMY_PLACE_HOLDERS}
    ${res_query}=    Set Variable    ${EMPTY}
    FOR    ${i}    IN RANGE    ${dummy_length}
    ${is_exist}=    Get Lines Containing String    ${query}    ${DUMMY_PLACE_HOLDERS}[${i}]
    ${is_exist}=    Get Length    ${is_exist}
    ${invalid_dummy_flag}=    Run Keyword If    ${${DUMMY_PLACE_HOLDERS}[${i}]}==${-1}    VALIDATE INVALID DUMMY    ${is_exist}
    ...    ELSE    Set Variable    ${0}
    Return From Keyword If    ${invalid_dummy_flag}==${1}    ${invalid_dummy_flag}    ${EMPTY}
    ${query}=    Run Keyword If    ${is_exist}!=${0}    Replace String    ${query}    ${DUMMY_PLACE_HOLDERS}[${i}]    ${${DUMMY_PLACE_HOLDERS}[${i}]}
    ...    ELSE    Set Variable    ${query}
    END
    [Return]    ${invalid_dummy_flag}    ${query}


VALIDATE INVALID DUMMY
    [Arguments]    ${is_exist}
    ${flag}=    Run Keyword If    ${is_exist}!=${0}    Set Variable    ${1}
    ...    ELSE    Set Variable    ${0}
    [Return]    ${flag}
    


LIST TO STRING
    [Arguments]    ${count}    @{list}
    [Documentation]    This Keyword used to convert the list type into string type,gets no of elements in list and list as arguments
    [Timeout]    3 minute
    ${result}=    Set Variable    ${EMPTY}
    FOR    ${i}    IN    @{list}
    ${result}=    Set Variable    ${result}${i}${SPACE}
    END
    [Return]    ${result}


COPY DB QUERIES
    [Arguments]    ${file_name}    ${list}
    [Documentation]    This Keyword replace dummy place holder in debug query file(source) with actual value for test case(dest) & execute the query & logs the result in a file
    [Timeout]    3 minute
    Set Test Variable    @{debugged_query}    @{EMPTY}
    ${list}=    Convert To String    ${list}
    @{source_list}    Split To Lines    ${list}
    FOR    ${q}    IN    @{source_list}
    ${query}   BuiltIn.Run Keyword And Continue On Failure    DatabaseLibrary.Query    ${q}
    ${len}=    Get Length    ${query}
    ${query}=    LIST TO STRING    ${len}    ${query}
    Append To List    ${debugged_query}    ${q}\n
    Append To List    ${debugged_query}    ${query}\n\n
    END
    ${query_len}=    Get Length    ${debugged_query}
    DB LOG MOVING    ${file_name}    ${debugged_query}


CREATE RESULT FILE
    [Arguments]    ${path}    ${file_prefix}
    [Documentation]    This Keyword get file path & file prefix as arguments and create a logger file with the file prefix & timestamp of automation
    [Timeout]    3 minute
    ${date}=    Get Current Date    result_format=%Y_%m_%d_%H_%M_%S
    ${file}=    Set Variable    ${result_path}${file_prefix}_${TEST_NAME}_${date}
    [Return]    ${file}

    

DB LOG MOVING
    [Arguments]   ${file_name}    ${content}
    [Documentation]    This Keyword get file name and logging content as arguments and logs the content into the file
    [Timeout]    3 minute
    FOR    ${i}    IN    @{content}
    Append To File    ${file_name}    ${i}
    END


SYSTIME COMPUTE
    [Arguments]    ${query}
    [Documentation]    This Keyword is to compute current system time and generate start time and end time with respect to range given
    [Timeout]    3 minute
    ${time} =	Get Current Date    UTC    increment=10:00:00    result_format=%H%M%S    exclude_millis=yes
    @{array_queries}    Split To Lines    ${query}
    ${array_query}=    Get From List    ${array_queries}    0
    ${plus_search}=    Set Variable    <+
    ${minus_search}=    Set Variable    <-
    ${plus_count}=    Split String    ${query}    <+
    ${plus_counter}=    Get Length    ${plus_count}
    ${plus_counter}=    Evaluate    ${plus_counter}-1
    ${minus_count}=    Split String    ${query}    <-
    ${minus_counter}=    Get Length    ${minus_count}
    ${minus_counter}=    Evaluate    ${minus_counter}-1
    FOR    ${i}    IN RANGE   ${plus_counter}
    ${array_query}=    ADD SYSTIME COMPUTE    ${array_query}
    END
    FOR    ${i}    IN RANGE    ${minus_counter}
    ${array_query}=    SUBTRACT SYSTIME COMPUTE    ${array_query}
    END
    ${array_query}=    Replace String    ${array_query}    <CURR_TIME>    ${time}
    [Return]    ${array_query}

ADD SYSTIME COMPUTE
    [Arguments]    ${array_query}
    ${plus_start_index}=    Get Index From List    ${array_query}    <+
    ${plus_end_index}=    Get Index From List    ${array_query}    +>
    ${diff}=    Get Slice From List    ${array_query}    ${plus_start_index}    ${plus_end_index}
    ${diff}=    Run Keyword If    ${plus_start_index}>=${0}    Get Substring    ${diff}    ${12}
    ${replacing}=    Set Variable    <+CURR_TIME+${diff}+>
    ${plus_time}=    Run Keyword If    ${plus_start_index}>=${0}    Add Time To Date    ${time}    ${diff}    result_format=%H%M%S    exclude_millis=yes    date_format=%H%M%S
    ${array_query}=    Run Keyword If    ${plus_start_index}>=${0}    Replace String    ${array_query}    ${replacing}    ${plus_time}
    ...    ELSE    Set Variable    ${array_query}
    [Return]    ${array_query}


SUBTRACT SYSTIME COMPUTE
    [Arguments]    ${array_query}
    ${minus_start_index}=    Get Index From List    ${array_query}    <-
    ${minus_end_index}=    Get Index From List    ${array_query}    ->
    ${diff}=    Get Slice From List    ${array_query}    ${minus_start_index}    ${minus_end_index}
    ${diff}=    Run Keyword If    ${minus_start_index}>=${0}    Get Substring    ${diff}    ${12}
    ${replacing}=    Set Variable    <-CURR_TIME-${diff}->
    ${minus_time}=    Run Keyword If    ${minus_start_index}>=${0}    Subtract Time From Date    ${time}    ${diff}    result_format=%H%M%S    exclude_millis=yes    date_format=%H%M%S
    ${array_query}=    Run Keyword If    ${minus_start_index}>=${0}    Replace String    ${array_query}    ${replacing}    ${minus_time}
    ...    ELSE    Set Variable    ${array_query}
    [Return]    ${array_query}


    

