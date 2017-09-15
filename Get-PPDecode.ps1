function Get-PPDecode {
param([string]$url)

<#
.SYNOPSIS
This script is used to decode rewritten proofpoint urls.
Function: Get-PPDecode -url 

Required Dependencies: None
Optional Dependencies: None
Version: 1.1

.DESCRIPTION
This script is used to decode rewritten proofpoint urls into human readable format.
.PARAMETER url
Switch: Specifies the url to decode.
	
.EXAMPLE
Get-PPDecode -url "https://urldefense.proofpoint.com/v2/url?u=https-3A__www.example.org&d=DwICAg&c=9g4MJkl2VjLjS6R4ei18BA&r=h7MPRldYxqbwAw0YxAUGO3KNC_2Ohg_iAatgBbxFzoo&m=X0uz55UtoIxq_TqGBvCIxoR7kpocSG2xtQhrTOstyiU&s=ZbQdAqxVRMu5eFtqCIpdxdSsDF7c0oXz9RVEdP7jIoE&e"
Decodes the url and outputs it as raw text.

.NOTES
The full url must be entered within brackets: 
Get-PPDecode -url "https://urldefense.proofpoint.com/v2/url?u=https-3A__www.example.org&d=DwICAg&c=9g4MJkl2VjLjS6R4ei18BA&r=h7MPRldYxqbwAw0YxAUGO3KNC_2Ohg_iAatgBbxFzoo&m=X0uz55UtoIxq_TqGBvCIxoR7kpocSG2xtQhrTOstyiU&s=ZbQdAqxVRMu5eFtqCIpdxdSsDF7c0oXz9RVEdP7jIoE&e"

Borrowed from Github repo: https://github.com/BenDrysdale/Proofpoint-URL-Decoder and slightly modified. Thanks Ben for your work.
#>

## Some Fun ASCI Art ##

@"
################################################################################

888 88e                              dP,e,                    ,e,           d8  
888 888D 888,8,  e88 88e   e88 88e   8b "  888 88e   e88 88e   "  888 8e   d88  
888 88"  888 "  d888 888b d888 888b 888888 888 888b d888 888b 888 888 88b d88888
888      888    Y888 888P Y888 888P  888   888 888P Y888 888P 888 888 888  888  
888      888     "88 88"   "88 88"   888   888 88"   "88 88"  888 888 888  888  
                                           888                     URL DECODER                                                                                             
                                           888                    
================================================================================                                           
"@

    
    [array]$regEx = ""
    $iterations="c","d","m","r","s"
    foreach ($i in $iterations){
    [array]$regEx +="((\&$i\=\w+\-\w+\-\w+\-\w+\-\w+)|(\&$i\=\w+\-\w+\-\w+\-\w+)|(\&$i\=\w+\-\w+\-\w+)|(\&$i\=\w+\-\w+)|(\&$i\=\w+\-\w+)|(\&$i\=\w+))|"
    }
    $compReg=("((https\:\/\/urldefense\.proofpoint\.com\/v2\/url\?u\=)|$regex(\&e\=))") -replace " ",""

    $a = $url -replace ($compReg)
    $b = $a -replace ("_","/")
    $c = $b -replace ("-5F","_")
    $d = $c -replace ("-3F","?")
    $e = $d -replace ("-3A",":")
    $f = $e -replace ("-3D","=")
    $g = $f -replace ("-26","&")
    $h = $g -replace ("-40","@")
    $i = $h -replace ("[.]",".")
    $j = $i -replace ("(\w+\:\//)|(www.)")
    $k = $j -replace ('(.+?)/.+','$1')
    "Decoded URL: $i"
}