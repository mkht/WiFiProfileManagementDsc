$output = 'C:\MOF'

$configuraionData = @{
    AllNodes =
    @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = "localhost"
            Role = "test"
        }
    )
}

Configuration WiFiProfileManagement_Sample
{
    param
    (
        [PSCredential]$Credential = (Get-Credential)
    )

    Import-DscResource -ModuleName WiFiProfileManagementDsc

    Node localhost
    {
        WiFiProfile WPA2Personal
        {
            Ensure = 'Present'
            ProfileName = 'MyWiFi'
            ConnectionMode = 'auto'
            Authentication = 'WPA2PSK'
            Encryption = 'AES'
            ConnectHiddenSSID = $true
            Credential = $Credential
        }

        WiFiProfile WPA2Enterprise
        {
            Ensure = 'Present'
            ProfileName = 'OneXWiFi'
            ConnectionMode = 'manual'
            Authentication = 'WPA2'
            Encryption = 'AES'
            ConnectHiddenSSID = $true
            EAPType = 'PEAP'
        }

        WiFiProfile FromXML
        {
            Ensure = 'Present'
            ProfileName = 'XMLWiFi'
            XmlProfile = @'
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>XMLWiFi</name>
    <SSIDConfig>
        <SSID>
            <hex>584D4C57694669</hex>
            <name>XMLWiFi</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>manual</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>P@ssw0rd</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
'@
        }
    }

    WiFiProfile RemoveWiFiProfile
    {
        Ensure = 'Absent'
        ProfileName = 'TestWiFi'
    }
}

WiFiProfileManagement_Sample -OutputPath $output -ConfigurationData $configuraionData -ErrorAction Stop
Start-DscConfiguration -Path $output -Verbose -Wait
Remove-DscConfigurationDocument -Stage Current,Previous,Pending -Force
