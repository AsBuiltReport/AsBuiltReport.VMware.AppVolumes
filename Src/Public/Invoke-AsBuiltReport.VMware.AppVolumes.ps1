function Invoke-AsBuiltReport.VMware.AppVolumes {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware AppVolumes in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware AppVolumes in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.1.1
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

    # Check if the required version of VMware PowerCLI is installed
    Get-RequiredModule -Name 'VMware.PowerCLI' -Version '12.7'


    # Import JSON Configuration for Options and InfoLevel
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options

    # If custom style not set, use default style


    $RESTAPIUser = $Credential.UserName
    $RESTAPIPassword = $Credential.GetNetworkCredential().password

    $AppVolRestCreds = @{
        username = $RESTAPIUser
        password = $RESTAPIPassword
    }

    foreach ($AppVolServer in $Target) {
    
        Try {
            $AppVolServerRest = Invoke-RestMethod -SkipCertificateCheck -SessionVariable SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/sessions" -Body $AppVolRestCreds 
        } Catch { 
            Write-Error $_
        } 
        
        # Generate report if connection to AppVolumes Server Connection is successful
        if ($AppVolServerRest.success -eq 'Ok') {

            #Environment Varibles

            #Writable Volumes
            $Writables = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/writables"

            #Applications
            $Applications = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/applications"

            #Directory Users
            $ActiveDirectoryUsers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users"

            #Directory Groups
            $ActiveDirectoryGroups = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/groups"

            #Storage Locations
            $Datastores = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores"

            #Storage Groups
            $StorageGroups = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storage_groups"

            #AD Domains
            $LDAPDomains = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/ldap_domains"

            #Admin Roles
            $AdminGroups = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/group_permissions"

            #Machine Managers
            $MachineManagers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers"

            #Storage
            $Storages = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storages"

            #Settings
            $Settings = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/settings"

        } 
        

        # Generate report if connection to AppVolumes Manager General Information is successful
        if ($InfoLevel.AppVolumes.General -ge 1) {
            section -Style Heading1 "VMware AppVolumes - $($AppVolServer)" {        
                Get-AbrAPPVolGeneralInfo
                Get-AbrAPPVolManager
                Get-AbrAPPVolLicense
                Get-AbrAPPVolAppstack
                Get-AbrAppVolWritable
            }
        }
    }
}