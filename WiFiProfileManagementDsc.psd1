@{

    ModuleVersion        = '1.2.0'

    GUID                 = 'c3824c3c-46cd-4f04-9680-726fe07be098'

    Author               = 'mkht'

    Copyright            = '(c) 2021 mkht. All rights reserved.'

    Description          = 'PowerShell DSC resource for manage WiFi profile.'

    PowerShellVersion    = '4.0'

    RequiredModules      = @(
        @{
            ModuleName    = 'WiFiProfileManagement'
            ModuleVersion = '0.5.0.0'
            Guid          = '91ed6e00-7f98-4f49-84f5-c3ee1a10e4d0'
        }
    )

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
