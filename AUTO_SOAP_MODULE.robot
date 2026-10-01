*** Settings ***
Library           Collections
Library           SSHLibrary    5min
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Process
Library           XML
Library           /opt/product/Automation_Softwares/ROBOT_FRAMEWORK_SUPPORTING_LIB/robotframework-requests-master/src/RequestsLibrary/RequestsKeywords.py

*** Variables ***

*** Keyword ***
HTTP
    Set Test Variable    @{http_results}    @{EMPTY}
    ${num_of_http}=    Get Length    ${HTTP_XML_VALIDATE_PATH}
    FOR    ${i}    IN RANGE    ${num_of_http}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${SOAP_ALIAS}[${i}]_SOAP_REQ
    Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    Run Keyword If    "${count}"!="${0}"    Create Session    httpbin    ${URL}[${i}]
    ${http_parsed_flag}=    Run Keyword If    "${count}"!="${0}"    HTTP REQUEST PARSE    ${i}    ${HEADERS_CONTENT_TYPE}[${i}]    ${HEADERS_EXPECT}[${i}]    @{result}
    Append To List    ${http_results}    ${http_parsed_flag}
    END
    ${http_flag}=    Count Values In List    ${http_results}   ${0}
    ${http_flag}=    Run Keyword If    ${http_flag}>${0}    Set Variable    ${Fail}
    ...    ELSE    Set Variable    ${Pass}
    [Return]    ${http_flag}


HTTP REQUEST PARSE
    [Arguments]    ${index}    ${header_content_type}    ${header_expect}    @{result}
    Set Test Variable    @{http_parsed_results}    @{EMPTY}
    FOR    ${i}    IN    @{result}
    ${xml_request}    ${xml_values_array}=    Split String    ${i}    ,    1
    ${is_value_present}=    Get Length    ${xml_values_array}
    ${file_content}=    Run Keyword If    ${is_value_present}>${0}    SOAP VALUE REPLACE    ${index}    ${xml_request}    ${xml_values_array}
    ${file_content}=    Run Keyword If    ${is_value_present}>${0}    SOAP DEFAULT VALUE FILL    ${xml_request}    ${file_content}
    &{files}=    Run Keyword If    ${is_value_present}>${0}    Create Dictionary    xml=${file_content}
    &{headers}=    Run Keyword If    ${is_value_present}>${0}    Create Dictionary    Content-Type=${header_content_type}    Expect=${header_expect}
    ${resp}=    Run Keyword If    ${is_value_present}>${0}    Post Request    httpbin    /${xml_request}/    files=${files}    headers=${headers}
    ${xml_resp_flag}=    Run Keyword If    ${is_value_present}>${0}    SOAP RESPONSE VALIDATE    ${index}    ${xml_request}    ${resp}
    Append To List    ${http_parsed_results}    ${xml_resp_flag}
    END
    ${http_parsed_flag}=    Count Values In List    ${http_parsed_results}   ${0}
    ${http_parsed_flag}=    Run Keyword If    ${http_parsed_flag}>${0}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    [Return]    ${http_parsed_flag}
    

SOAP VALUE REPLACE
    [Arguments]    ${index}    ${xml_request}    ${xml_values_array}
    ${file_content}=    OperatingSystem.Get File    ${HTTP_XML_VALIDATE_PATH}[${index}]${xml_request}_TEMPLATE.xml
    @{values}=    Split String    ${xml_values_array}    ,
    FOR    ${i}    IN    @{values}
    ${place_holder}    ${value}=    Split String    ${i}    ::    1
    ${file_content}=    Replace String    ${file_content}    ${place_holder}    ${value}
    END
    [Return]    ${file_content}


SOAP RESPONSE VALIDATE
    [Arguments]    ${index}    ${xml_request}    ${resp}
    Set Test Variable    @{xml_response_results}    @{EMPTY}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${SOAP_ALIAS}[${index}]_${xml_request}
    Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    @{file_outputs}=     Run Keyword If    "${count}"!="${0}"    Split String    ${result}[${0}]    ,
    Run Keyword If    "${count}"!="${0}"    BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.status_code}    200
    log    ${resp.content}
    ${root}=    Run Keyword If    "${count}"!="${0}"    PARSE XML    ${resp.content}
    Run Keyword If    "${count}"!="${0}"    Element Attribute Should Be    ${root}    xmlns    ${SOAP_NAMESPACE}[${index}]    Header/ERROR_CODE
    Run Keyword If    "${count}"!="${0}"    Element Attribute Should Be    ${root}    xmlns    ${SOAP_NAMESPACE}[${index}]    Header/ERROR_DESC
    FOR    ${i}    IN    @{file_outputs}
    @{temp}=    Split String    ${i}    ::
    log many    @{temp}
    ${value}=    Run Keyword If    ${temp}[2]==0    BuiltIn.Run Keyword And Continue On Failure    SOAP VALUE CHECK    ${root}    ${temp}[1]    ${temp}[0]
    ...    ELSE    BuiltIn.Run Keyword And Continue On Failure    SOAP TYPE CHECK    ${root}    ${temp}[1]    ${temp}[0]
    log    ${value}
    Append To List    ${xml_response_results}    ${value}
    END
    ${xml_resp_flag}=    Count Values In List    ${xml_response_results}   ${False}
    ${xml_resp_flag}=    Run Keyword If    ${xml_resp_flag}>${0}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    [Return]    ${xml_resp_flag}

SOAP VALUE CHECK
    [Arguments]    ${root}    ${temp1}    ${temp0}
    ${values}=    Run Keyword And Return Status    Element Text Should Be    ${root}    ${temp1}    ${temp0}
    [Return]    ${values}

SOAP TYPE CHECK
    [Arguments]    ${root}    ${temp1}    ${temp0}
    ${values}=    Run Keyword And Return Status    Element Text Should Match    ${root}    ${temp1}    ${temp0}
    [Return]    ${values}


SOAP DEFAULT VALUE FILL
    [Arguments]    ${xml_request}    ${file_content}
    ${content}=    OperatingSystem.Get File    ${HTTP_XML_VALIDATE_PATH}[${index}]${xml_request}_VALUES.txt
    @{lines}=    Split To Lines    ${content}
    ${lines_length}=    Get Length    ${lines}
    FOR    ${i}    IN RANGE    ${lines_length}
    ${place_holder}    ${values}=    Run Keyword    Split String From Right    ${lines}[${i}]    ::
    ${file_content}=    Replace String    ${file_content}    ${place_holder}    ${values}
    END
    [Return]    ${file_content}
