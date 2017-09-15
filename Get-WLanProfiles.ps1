function Get-WLANProfile
{
    <#

    .SYNOPSIS
    Get WLAN profiles, include password as SecureString or as plain text
   
   	.DESCRIPTION
    Get WLAN profiles on your local system. Must be admin to get clear text key content.
    
    .EXAMPLE
    Get-WLANProfile

    .EXAMPLE
    Get-WLANProfile -ShowPassword

    #>
	[CmdletBinding()]
	param(
        [Parameter(Position=0, ValueFromPipeLine=$true, HelpMessage='List of computers or sessions to run the script against.')]
        [Alias('cn')]
        [string[]]$ComputerName = $env:COMPUTERNAME,

		[Parameter(HelpMessage='Indicates that the password appears in plain text')]
		[Switch]$ShowPassword
	)

	Begin
    {
        $resultObjects = @();

        $scriptBlock = {
		    [CmdletBinding()]
			param(
				[Parameter(
					Position=0,
					HelpMessage='Indicates that the password appears in plain text')]
				[Switch]$ShowPassword
			)
			
            $WLAN_Names = @();
            $WLAN_Profiles = @();

            $TextInfo = (Get-Culture).TextInfo;
            
            
			# Get all WLAN Profiles from netsh
			$Netsh_WLANProfiles = (netsh WLAN show profiles);

			
			# Filter result and get the wlan profile names
			# Matches GPO and non GPO profiles.
			foreach($Line in $Netsh_WLANProfiles)
			{
				if($Line -match "^\s+")
				{
					if($Line.Contains(":"))
					{
						$WLAN_Names += $Line.Split(':')[1].Trim();
					}
					else
					{
						$WLAN_Names += $Line.Trim();
					};
				};
			};
			
			# Get details from every wlan profile, using the name (ssid/password/authentification/etc.)
			foreach($WLAN_Name in $WLAN_Names)
			{
				Write-Verbose "Command: netsh WLAN show profiles name=$WLAN_Name key=clear"

				$hashTable = @{};
				$Netsh_WLANProfile = (netsh WLAN show profiles name="$WLAN_Name" key=clear);

				$section = "";

				foreach($Line in $Netsh_WLANProfile)
				{                 
					Write-Verbose $Line;

					switch($Line.Trim())
					{
						'Profile information'   { $section = 'Profile'; break;};
						'Connectivity settings' { $section = 'Connectivity'; break;};
						'Security settings'     { $section = 'Security'; break;};
						'Cost settings'         { $section = 'Cost'; break;};
					};
					
					if([string]::IsNullOrEmpty($Line)) {$section = [string]::Empty; };

					if($Line.Contains(':'))
					{
						$Line = $Line.Trim() -replace '\x00','';
						
						$kvp = $Line.Trim().Split(":",[System.StringSplitOptions]::RemoveEmptyEntries) | %{$_.Trim()};

						if($kvp -and $kvp.Count -eq 2)
						{
							$camelCase = $TextInfo.ToTitleCase($kvp[0].Trim().ToLower()).Replace(' ','')

							if($camelCase -eq "Applied") 
                            { 
                                $hashTable[ "$($camelCase)"] = $kvp[1].Trim(); 
                            }
                            elseif($camelCase -eq "KeyContent") 
                            {
                                if($ShowPassword.IsPresent) { $hashTable[ "$($section)_$($camelCase)"] = $kvp[1].Trim(); }
                                else { $hashTable[ "$($section)_$($camelCase)"] = "*".PadLeft(8,'*'); }
                            }
							else
                            { 
                                $hashTable[ "$($section)_$($camelCase)"] = $kvp[1].Trim(); 
                            };
							
						}; #END: if Key value pair count

					}; #END: if isKeyValuePair candidate

				}; #END: foreach line in profile


				# Built the custom PSObject
				$WLAN_Profiles += New-Object PSCustomObject -Property $hashTable;

			}; #END: Foreach profile
                
            return $WLAN_Profiles;
        }; #END ScriptBlock
        
    }; #END: BEGIN

	Process
    {
		if($ComputerName)
        {
            foreach($obj in $ComputerName)
            {
                # LOCAL INVOKATION
                if($obj.GetType().Name -eq "String" -and $obj.ToUpper() -eq $env:COMPUTERNAME.ToUpper())
                {
                    $resultObjects += Invoke-Command $scriptBlock -ArgumentList $ShowPassword
                }
                # REMOTE SESSION
                elseif($obj.GetType().Name -eq "PSSession")
                {
                    $resultObjects += Invoke-Command -Session $obj -ScriptBlock $scriptBlock -ArgumentList $ShowPassword
                }
                # REMOTE HOST NAME
                elseif ($obj.GetType().Name -eq "String")
                {
                    $resultObjects += Invoke-Command -ComputerName $obj -ScriptBlock $scriptBlock -ArgumentList $ShowPassword
                }
            }
        }

	}; #END: Process block

	End{ return $resultObjects; };

}; #END 

Get-WLANProfile