*** Settings ***
Documentation  Marias Robot Order
Library  RPA.Browser 
Library  RPA.HTTP
Library  RPA.Tables
Library  RPA.PDF
Library  RPA.Archive

*** Keywords ***
Open Website
    Open Available Browser  https://robotsparebinindustries.com/#/robot-order
     Click Button  //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

*** Keywords ***
Dowload Orders Excel Sheet 
    Download    https://robotsparebinindustries.com/orders.csv   overwrite=True

*** Keywords ***
Fill The Form
    [Arguments]   ${bot_order}
        Select From List By Value    id:head   ${bot_order}[Head]
        Select Radio Button    body    id-body-${bot_order}[Body]
        Input Text    //input[@placeholder="Enter the part number for the legs"]   ${bot_order}[Legs]
        Input Text    id:address   ${bot_order}[Address]
        
        #To Preview The Robot
        Click Button    id:preview
        Wait Until Page Contains Element   id:robot-preview-image
        
        #Place The Order
        Click Button    id:order
        Wait Until Page Contains Element   id:order-another 

*** Keywords ***
Fill The Form And Print Pdf
    ${orders}=  Read table from CSV     orders.csv  header=True 
    FOR   ${bot_order}    IN    @{orders}
        Wait Until Keyword Succeeds    3x    0.5 sec     Fill The Form  ${bot_order}
        Reciept To Pdf  ${bot_order}
    END


*** Keywords ***
Reciept To Pdf
    [Arguments]   ${bot_order}
    Wait Until Page Contains Element   id:order-another
    Sleep  2s
    
    #Store Html Order Reciept As Pdf
    ${html_reciept}=     Get Element Attribute    id:receipt    outerHTML
    
    #Html To Pdf Conversion
    Html To Pdf   ${html_reciept}   ${CURDIR}${/}output${/}${bot_order}[Order number].pdf
        
    #Store the Screenshot of Robot Image
    Screenshot    id:robot-preview-image    ${CURDIR}${/}output${/}${bot_order}[Order number].png
    
    #Pdf Opening
    ${openpdf}=  Open Pdf  ${CURDIR}${/}output${/}${bot_order}[Order number].pdf
    
    #Attach Screenshot Of Robot To Pdf Reciept
    Add Watermark Image To Pdf  ${CURDIR}${/}output${/}${bot_order}[Order number].png  ${CURDIR}${/}output${/}${bot_order}[Order number].pdf  ${CURDIR}${/}output${/}${bot_order}[Order number].pdf
    
    #Close The Pdf Reciept
    Close Pdf  ${openpdf}
       
    #Another Order   
    Click Button    id:order-another
    Wait Until Page Contains Element   //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    
    #Clicking Ok in the Model
    Click Element    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]


*** Keywords ***
Archive the receipts
    Archive Folder With Zip   ${CURDIR}${/}output  receipts.zip


*** Tasks ***
Order robots from Robot Spare Bin Website
    Open Website
    Dowload Orders Excel Sheet 
    Fill The Form And Print Pdf
    Archive the receipts
