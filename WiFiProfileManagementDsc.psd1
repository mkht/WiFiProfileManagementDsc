@{

    ModuleVersion        = '0.1.0'

    GUID                 = 'c3824c3c-46cd-4f04-9680-726fe07be098'

    Author               = 'mkht'

    Copyright            = '(c) 2018 mkht. All rights reserved.'

    Description          = 'PowerShell DSC resource for manage WiFi profile.'

    PowerShellVersion    = '4.0'

    RequiredModules      = @('WiFiProfileManagement')

    FunctionsToExport    = @()

    CmdletsToExport      = @()

    VariablesToExport    = '*'

    AliasesToExport      = @()

    DscResourcesToExport = @('WiFiProfile')

    PrivateData          = @{

        PSData = @{

            Tags       = ('WiFi', 'WirelessNetwork')

            LicenseUri = 'https://github.com/mkht/WiFiProfileManagementDsc/blob/master/LICENSE'

            ProjectUri = 'https://github.com/mkht/WiFiProfileManagementDsc'

            # ReleaseNotes = ''

        }

    }
}
