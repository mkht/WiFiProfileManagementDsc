WiFiProfileManagementDsc
====

PowerShell DSC resource for manage WiFi profile.

----
## Installation
From [PowerShell Gallery](https://www.powershellgallery.com/packages/WiFiProfileManagementDsc/).
```PowerShell
Install-Module -Name WiFiProfileManagementDsc
```

### Dependencies
* [WiFiProfileManagement](https://github.com/jcwalker/WiFiProfileManagement) by jcwalker

----
## DSC Resources
* **WiFiProfile** PowerShell DSC resource for manage WiFi profile.

### WiFiProfile
* **Ensure**: Ensures that the profile is Present or Absent.
* **ProfileName**: The name of the profile. This is a Key property.
* **ConnectionMode**: Indicates whether connection to the wireless LAN should be automatic ("auto") or initiated ("manual") by user. The default is "auto".
* **Authentication**: Specifies the authentication method to be used to connect to the wireless LAN. ('open', 'shared', 'WPA', 'WPAPSK', 'WPA2', 'WPA2PSK')
* **Encryption**: Sets the data encryption to use to connect to the wireless LAN. ('none', 'WEP', 'TKIP', 'AES')
* **Credential**: The network key or passpharse of the wireless profile in the form of a PSCredential.
* **ConnectHiddenSSID**: Specifies whether the profile can connect to networks which does not broadcast SSID. The default is false.
* **EAPType**: (Only 802.1X) Specifies the type of 802.1X EAP. You can select "PEAP"(aka MSCHAPv2) or "TLS".
* **ServerNames**: (Only 802.1X) Specifies the server that will be connect to validate certification.
* **TrustedRootCA**: (Only 802.1X) Specifies the certificate thumbprint of the Trusted Root CA.
* **XmlProfile**: The XML representation of the profile.


### Examples
If you wish to see fully functional scripts, See `Examples` folder.

+ **Example 1**: Create WiFi profile (WPA2-Personal)
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName WiFiProfileManagementDsc
    WiFiProfile WPA2Personal
    {
        Ensure = 'Present'
        ProfileName = 'MyWiFi'
        ConnectionMode = 'auto'
        Authentication = 'WPA2PSK'
        Encryption = 'AES'
        ConnectHiddenSSID = $true
        Credential = $CredentialForConnect #Only use Password. UserName will be ignored.
    }
}
```

+ **Example 2**: Create WiFi profile (WPA2-Enterprise)
```Powershell
Configuration Example2
{
    Import-DscResource -ModuleName WiFiProfileManagementDsc
    WiFiProfile WPA2Enterprise
    {
        Ensure = 'Present'
        ProfileName = 'OneXWiFi'
        ConnectionMode = 'manual'
        Authentication = 'WPA2'
        Encryption = 'AES'
        ConnectHiddenSSID = $true
        EAPType = 'PEAP'
        TrustedRootCA = '041101cca5b336a9c6e50d173489f5929e1b4b00'  #optional
    }
}
```

+ **Example 3**: Remove WiFi profile
```Powershell
Configuration Example3
{
    Import-DscResource -ModuleName WiFiProfileManagementDsc
    WiFiProfile RemoveWiFi
    {
        Ensure = 'Absent'
        ProfileName = 'MyWiFi'
    }
}
```

----
## Versions

### Unreleased

### 1.0.0
  + First public release.
