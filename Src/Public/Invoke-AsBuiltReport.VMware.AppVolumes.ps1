function Invoke-AsBuiltReport.VMware.AppVolumes {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware AppVolumes in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware AppVolumes in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.0
        Author:         Chris Hildebrandt, @childebrandt42
        Editor:         Jonathan Colon, @jcolonfzenpr
        Twitter:        @asbuiltreport
        Github:         AsBuiltReport
        Credits:        Iain Brighton (@iainbrighton) - PScribo module


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.AppVolumes
    #>


    [CmdletBinding()]
    param (
        [String[]] $Target,
        [PSCredential] $Credential,
        [String] $StylePath
    )

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    Write-PScriboMessage -IsWarning "Please refer to the AsBuiltReport.VMware.AppVolumes github website for more detailed information about this project."
    Write-PScriboMessage -IsWarning "Do not forget to update your report configuration file after each new version release."
    Write-PScriboMessage -IsWarning "Documentation: https://github.com/AsBuiltReport/AsBuiltReport.VMware.AppVolumes"
    Write-PScriboMessage -IsWarning "Issues or bug reporting: https://github.com/AsBuiltReport/AsBuiltReport.VMware.AppVolumes/issues"

    # Check if the required version of VMware PowerCLI is installed
    Get-RequiredModule -Name 'VMware.PowerCLI' -Version '12.7'

    # Import JSON Configuration for Options and InfoLevel
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options

    $RESTAPIUser = $Credential.UserName
    $RESTAPIPassword = $Credential.GetNetworkCredential().password

    $AppVolRestCreds = @{
        username = $RESTAPIUser
        password = $RESTAPIPassword
    }

    foreach ($AppVolServer in $Target) {

        Try {
            if ($PSVersionTable.PSEdition -eq 'Core') {
                $AppVolServerRest = Invoke-RestMethod -SkipCertificateCheck -SessionVariable SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/sessions" -Body $AppVolRestCreds
            } else {$AppVolServerRest = Invoke-RestMethod -SessionVariable SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/sessions" -Body $AppVolRestCreds}
        } Catch {
            Write-Error $_
        }

        # Generate report if connection to AppVolumes Server Connection is successful
        if ($AppVolServerRest.success -eq 'Ok') {
            # Generate report if connection to AppVolumes Manager General Information is successful
            if ($InfoLevel.AppVolumes.General -ge 1) {
                section -Style Heading1 $($AppVolServer) {
                    Paragraph "The following section provides a summary of the implemented components on the VMware App Volumes infrastructure."
                    Get-AbrAPPVolGeneral
                    section -Style Heading2 "Inventory" {
                        Get-AbrAPPVolApplication
                        Get-AbrAppVolPackage
                        Get-AbrAppVolProgram
                        Get-AbrAppVolAssignment
                        Get-AbrAppVolWritable
                        #Get-AbrAppVolAppstack
                    }
                    section -Style Heading2 "Directory" {
                        Get-AbrAppVolADUser
                        Get-AbrAppVolComputer
                        Get-AbrAppVolADGroup
                        Get-AbrAppVolADOU
                    }
                    section -Style Heading2 "Infrastructure" {
                        Get-AbrAppVolMachine
                        Get-AbrAppVolStorage
                        Get-AbrAppVolStorageGroup
                        Get-AbrAppVolInstance
                    }
                    section -Style Heading2 "Activity" {
                        Get-AbrAppVolJob
                        Get-AbrAppVolTSArchive
                    }
                    section -Style Heading2 "Configuration" {
                        Get-AbrAppVolLicense
                        Get-AbrAppVolADDomain
                        Get-AbrAppVolAdminRole
                        Get-AbrAppVolMachineManager
                        Get-AbrAppVolDatastore
                        Get-AbrAPPVolManager
                        Get-AbrAppVolSetting
                    }
                }
            }
        }
    }
}
