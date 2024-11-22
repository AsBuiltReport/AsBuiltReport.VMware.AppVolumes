function Invoke-AsBuiltReport.VMware.AppVolumes {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware AppVolumes in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware AppVolumes in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.2.0
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

    if ($psISE) {
        Write-Error -Message "You cannot run this script inside the PowerShell ISE. Please execute it from the PowerShell Command Window."
        break
    }

    if ($PSVersionTable.PSEdition -ne 'Core') {

        Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    }


    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    Write-PScriboMessage -Plugin "Module" -IsWarning "Please refer to the AsBuiltReport.VMware.AppVolumes github website for more detailed information about this project."
    Write-PScriboMessage -Plugin "Module" -IsWarning "Do not forget to update your report configuration file after each new version release."
    Write-PScriboMessage -Plugin "Module" -IsWarning "Documentation: https://github.com/AsBuiltReport/AsBuiltReport.VMware.AppVolumes"
    Write-PScriboMessage -Plugin "Module" -IsWarning "Issues or bug reporting: https://github.com/AsBuiltReport/AsBuiltReport.VMware.AppVolumes/issues"
    Write-PScriboMessage -Plugin "Module" -IsWarning "This project is community maintained and has no sponsorship from VMware/Omnissa, its employees or any of its affiliates."

    # Check the current AsBuiltReport.VMware.AppVolumes installed module
    Try {
        $InstalledVersion = Get-Module -ListAvailable -Name AsBuiltReport.VMware.AppVolumes -ErrorAction SilentlyContinue | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty Version

        if ($InstalledVersion) {
            Write-PScriboMessage -IsWarning "AsBuiltReport.VMware.AppVolumes $($InstalledVersion.ToString()) is currently installed."
            $LatestVersion = Find-Module -Name AsBuiltReport.Veeam.VBR -Repository PSGallery -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
            if ($LatestVersion -gt $InstalledVersion) {
                Write-PScriboMessage -IsWarning "AsBuiltReport.VMware.AppVolumes $($LatestVersion.ToString()) is available."
                Write-PScriboMessage -IsWarning "Run 'Update-Module -Name AsBuiltReport.VMware.AppVolumes -Force' to install the latest version."
            }
        }
    } Catch {
        Write-PScriboMessage -IsWarning $_.Exception.Message
    }

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
            } else { $AppVolServerRest = Invoke-RestMethod -SessionVariable SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/sessions" -Body $AppVolRestCreds }
        } Catch {
            Write-Error $_
        }

        # Generate report if connection to AppVolumes Server Connection is successful
        if ($AppVolServerRest.success -eq 'Ok') {
            # Generate report if connection to AppVolumes Manager General Information is successful
            if ($InfoLevel.AppVolumes.General -ge 1) {
                Section -Style Heading1 $($AppVolServer) {
                    Paragraph "The following section provides a summary of the implemented components on the VMware App Volumes infrastructure."
                    Get-AbrAPPVolGeneral
                    Section -Style Heading2 "Inventory" {
                        Get-AbrAPPVolApplication
                        Get-AbrAppVolPackage
                        Get-AbrAppVolProgram
                        Get-AbrAppVolAssignment
                        Get-AbrAppVolWritable
                        #Get-AbrAppVolAppstack
                    }
                    Section -Style Heading2 "Directory" {
                        Get-AbrAppVolADUser
                        Get-AbrAppVolComputer
                        Get-AbrAppVolADGroup
                        Get-AbrAppVolADOU
                    }
                    Section -Style Heading2 "Infrastructure" {
                        Get-AbrAppVolMachine
                        Get-AbrAppVolStorage
                        Get-AbrAppVolStorageGroup
                        Get-AbrAppVolInstance
                    }
                    Section -Style Heading2 "Activity" {
                        Get-AbrAppVolJob
                        Get-AbrAppVolTSArchive
                    }
                    Section -Style Heading2 "Configuration" {
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
