$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

#region LocalizedData
$Culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture)) {
    $Culture = $PSUICulture
}
Import-LocalizedData `
    -BindingVariable LocalizedData `
    -Filename WiFiProfile.strings.psd1 `
    -BaseDirectory $moduleRoot `
    -UICulture $Culture
#endregion LocalizedData


#region Get-TargetResource
function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProfileName
    )

    $returnHash = @{
        Ensure            = 'Present'
        ProfileName       = $ProfileName
        ConnectionMode    = $null
        Authentication    = $null
        Encryption        = $null
        ConnectHiddenSSID = $false
        EAPType           = $null
        ServerNames       = $null
        TrustedRootCA     = $null
        AuthMode          = $null
        XmlProfile        = $null
        PassPhrase        = [string]::Empty
    }

    $currentProfile = Get-WiFiProfile -ProfileName $ProfileName -ClearKey -ErrorAction SilentlyContinue

    if (-not $currentProfile) {
        Write-Verbose -Message $($LocalizedData.ProfileNotExist -f $ProfileName)
        $returnHash.Ensure = 'Absent'
    }
    else {
        $returnHash.Ensure = 'Present'
        $returnHash.ConnectionMode = $currentProfile.ConnectionMode
        $returnHash.Authentication = $currentProfile.Authentication
        $returnHash.Encryption = $currentProfile.Encryption
        $returnHash.ConnectHiddenSSID = $currentProfile.ConnectHiddenSSID
        $returnHash.EAPType = $currentProfile.EAPType
        $returnHash.XmlProfile = $currentProfile.Xml
        $returnHash.PassPhrase = $currentProfile.Password

        if ($null -ne $currentProfile.EAPType) {
            $returnHash.ServerNames = $currentProfile.ServerNames
            $returnHash.TrustedRootCA = $currentProfile.TrustedRootCA
            $returnHash.AuthMode = $currentProfile.AuthMode
        }
    }

    return $returnHash
}
#endregion Get-TargetResource


#region Test-TargetResource
function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.String]
        $ProfileName,

        [Parameter()]
        [ValidateSet('manual', 'auto')]
        [System.String]
        $ConnectionMode = 'auto',

        [Parameter()]
        [ValidateSet('open', 'shared', 'WPA', 'WPAPSK', 'WPA2', 'WPA2PSK', 'WPA3SAE', 'WPA3ENT192', 'OWE')]
        [System.String]
        $Authentication = 'WPA2PSK',

        [Parameter()]
        [ValidateSet('none', 'WEP', 'TKIP', 'AES', 'GCMP256')]
        [System.String]
        $Encryption = 'AES',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $ConnectHiddenSSID = $false,

        [Parameter()]
        [ValidateSet('PEAP', 'TLS')]
        [System.String]
        $EAPType,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $ServerNames,

        [Parameter()]
        [System.String]
        $TrustedRootCA,

        [Parameter()]
        [ValidateSet('machineOrUser', 'machine', 'user', 'guest')]
        [System.String]
        $AuthMode = 'machineOrUser',

        [Parameter()]
        [System.String]
        $XmlProfile
    )

    $currentState = Get-TargetResource -ProfileName $ProfileName

    if ($Ensure -eq 'Absent') {
        return ($currentState.Ensure -eq 'Absent')
    }

    # When $Ensure -eq 'Present'
    if ($currentState.Ensure -ne 'Present') {
        return $false
    }

    if ($XmlProfile) {
        $xmlProfileObject = ($XmlProfile -as [System.Xml.XmlDocument])

        if ($null -eq $xmlProfileObject) {
            Write-Error -Message $($LocalizedData.XMLProfileIsNotValid)
        }
        else {
            return ($xmlProfileObject.OuterXml -ceq ([xml]$currentState.XmlProfile).OuterXml)
        }
    }
    else {
        $PassPhrase = [string]::Empty
        if ($Credential) {
            # Get plain passphrase
            $PassPhrase = $Credential.GetNetworkCredential().Password
        }

        # Test whether all properties match
        $testProperties = ('ConnectionMode', 'Authentication', 'Encryption', 'PassPhrase', 'ConnectHiddenSSID', 'EAPType')
        foreach ($property in $testProperties) {
            if (-not ($currentState[$property] -ceq (Get-Variable -Name $property -ValueOnly))) {
                Write-Verbose -Message $($LocalizedData.ProfilePropertyIsNotMatch -f $property)
                return $false
            }
        }

        # Test only when 802.1X is specified
        if ($EAPType) {
            $testProperties = ('ServerNames', 'TrustedRootCA', 'AuthMode')
            foreach ($property in $testProperties) {
                if (-not ($currentState[$property] -ceq (Get-Variable -Name $property -ValueOnly))) {
                    Write-Verbose -Message $($LocalizedData.ProfilePropertyIsNotMatch -f $property)
                    return $false
                }
            }
        }
    }

    # All test passed
    return $true
}
#endregion Test-TargetResource


#region Set-TargetResource
function Set-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Void])]
    param
    (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.String]
        $ProfileName,

        [Parameter()]
        [ValidateSet('manual', 'auto')]
        [System.String]
        $ConnectionMode = 'auto',

        [Parameter()]
        [ValidateSet('open', 'shared', 'WPA', 'WPAPSK', 'WPA2', 'WPA2PSK', 'WPA3SAE', 'WPA3ENT192', 'OWE')]
        [System.String]
        $Authentication = 'WPA2PSK',

        [Parameter()]
        [ValidateSet('none', 'WEP', 'TKIP', 'AES', 'GCMP256')]
        [System.String]
        $Encryption = 'AES',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $ConnectHiddenSSID = $false,

        [Parameter()]
        [ValidateSet('PEAP', 'TLS')]
        [System.String]
        $EAPType,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $ServerNames,

        [Parameter()]
        [System.String]
        $TrustedRootCA,

        [Parameter()]
        [ValidateSet('machineOrUser', 'machine', 'user', 'guest')]
        [System.String]
        $AuthMode = 'machineOrUser',

        [Parameter()]
        [System.String]
        $XmlProfile
    )

    if ($Ensure -eq 'Absent') {
        Remove-WiFiProfile -ProfileName $ProfileName
        Write-Verbose -Message $($LocalizedData.ProfileRemoved -f $ProfileName)
    }
    else {
        if ($XmlProfile) {
            Set-WiFiProfile -XmlProfile $XmlProfile
            Write-Verbose -Message $($LocalizedData.ProfileSaved -f $ProfileName)
        }
        else {
            $paramHash = @{
                ProfileName       = $ProfileName
                ConnectionMode    = $ConnectionMode
                Authentication    = $Authentication
                Encryption        = $Encryption
                ConnectHiddenSSID = $ConnectHiddenSSID
            }

            if ($Credential) {
                $paramHash.Password = $Credential.Password
            }

            if ($EAPType) {
                $paramHash.EAPType = $EAPType
                $paramHash.ServerNames = $ServerNames
                $paramHash.AuthMode = $AuthMode
                if ($TrustedRootCA) {
                    $paramHash.TrustedRootCA = $TrustedRootCA
                }
            }

            Set-WiFiProfile @paramHash
            Write-Verbose -Message $($LocalizedData.ProfileSaved -f $ProfileName)
        }
    }
}
#endregion Set-TargetResource


Export-ModuleMember -Function *-TargetResource
