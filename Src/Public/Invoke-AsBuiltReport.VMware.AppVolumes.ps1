function Invoke-AsBuiltReport.VMware.AppVolumes {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware AppVolumes in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware AppVolumes in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.1.1
        Author:         Chris Hildebrandt
        Twitter:        @childebrandt42
        Github:         https://github.com/AsBuiltReport/
        Credits:        Iain Brighton (@iainbrighton) - PScribo module


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.AppVolumes
    #>


    [CmdletBinding()]
    param (
        [String[]] $Target,
        [PSCredential] $Credential,
        [String] $StylePath
    ) #Close out Param

    # Check if the required version of VMware PowerCLI is installed
    Get-RequiredModule -Name 'VMware.PowerCLI' -Version '12.3'


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
        } #Close Out Try Catch


        #region Script Body
        #---------------------------------------------------------------------------------------------#
        #                                       SCRIPT BODY                                           #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Server Connection is successful
        if ($AppVolServerRest.success -eq 'Ok') {

            #Environment Varibles
            
            #General
            $GeneralAppInfo = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/version"

            #Managers
            $Managers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/manager_services"

            #License Info
            $License = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/license"

            #AppStacks
            $AppStacks = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/appstacks"

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

        } # Close out if ($AppVolServers) 


        #---------------------------------------------------------------------------------------------#
        #                                    AppVolumes Manager General Info                          #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Manager General Information is successful
        if ($GeneralAppInfo) {
            if ($InfoLevel.AppVolumes.General -ge 1) {
                section -Style Heading1 "VMware AppVolumes - $($AppVolServer)" {

                    $GeneralAppInfoPSObj = [PSCustomObject]@{

                        'Name' = $AppVolServer
                        'Version' = $GeneralAppInfo.version
                        'Configured' = $GeneralAppInfo.configured
                        'Uptime' = $GeneralAppInfo.uptime
                    } # Close Out $GeneralAppInfoPSObj = [PSCustomObject]
                    $GeneralAppInfoPSObj | Table -Name 'Manager General Information' -List -ColumnWidths 50,50
                } # Close out section -Style Heading2 'AppVolumes Manager General Information'
            } # Close out if ($InfoLevel.AppVolumes.General -ge 1)
        } # Close out if ($GeneralAppInfo)


        #---------------------------------------------------------------------------------------------#
        #                                    AppVolumes Manager Servers Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes AppVolumes Manager Servers Information is successful
        if ($Managers) {
            if ($InfoLevel.AppVolumes.Managers -ge 1) {
                section -Style Heading1 'Manager Servers Information' {
                        foreach($Manager in $Managers.services) {
                            section -Style Heading2 "$($Manager.name) Details" {
                                $ManagersPSObj = [PSCustomObject]@{
                                    'Name' = $Manager.name
                                    'Internal Version' = $Manager.internal_version
                                    'Product Version' = $Manager.product_version
                                    'Domain Name' = $Manager.domain_name
                                    'Computer Name' = $Manager.computer_name
                                    'Computer FQDN' = $Manager.fqdn
                                    'Registered' = $Manager.registered
                                    'Secure' = $Manager.secure
                                    'Status' = $Manager.status
                                    'First Seen At' = $Manager.first_seen_at_human
                                    'Last Seen At' = $Manager.last_seen_at_human

                                } # Close Out $ManagersPSObj = [PSCustomObject]
                            $ManagersPSObj | Table -Name 'Manager Servers Information' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 'AppVolumes Manager Servers Details'
                        } # Close out foreach($Manager in $Managers.group_permissions)
                } # Close out section -Style Heading2 'AppVolumes Manager Servers Information'
            } # Close out if ($InfoLevel.AppVolumes.Managers -ge 1)
        } # Close out if ($Managers)


        #---------------------------------------------------------------------------------------------#
        #                                    License Info                                             #
        #---------------------------------------------------------------------------------------------#


        # Generate report if connection to AppVolumes License Information is successful
        if ($License) {
            if ($InfoLevel.AppVolumes.License -ge 1) {
                section -Style Heading1 'License Information' {
                    Switch ($License.license.invalid)
                        {
                            'True' {$LicenseInvalid = 'False' }
                            'False' {$LicenseInvalid = 'True' }
                        }

                        $LicensePSObj = [PSCustomObject]@{
                            'Key Create Date' = $License.license.Keycreate
                            'Key Valid' = $LicenseInvalid
                            'Limit Users' = $License.license.details.users
                            'Usage Users' = $License.license.usage.Users
                            'Limit Desktops' = $License.license.details.Desktops
                            'Usage Desktops' = $License.license.usage.Desktops
                            'Limit Servers' = $License.license.details.Servers
                            'Usage Server' = $License.license.usage.Servers
                            'Limit Concurrent Users' = $License.license.details.'Concurrent Users'
                            'Usage Concurrent Users' = $License.license.usage.'Concurrent Users'
                            'Limit Concurrent Desktops' = $License.license.details.'Concurrent Desktops'
                            'Usage Concurrent Desktops' = $License.license.usage.'Concurrent Desktops'
                            'Limit Concurrent Servers' = $License.license.details.'Concurrent Servers'
                            'Usage Concurrent Servers' = $License.license.usage.'Concurrent Servers'
                            'Limit Terminal Users' = $License.license.details.'Terminal Users'
                            'Usage Terminal Users' = $License.license.usage.'Terminal Users'
                            'Limit Concurrent Terminal Users' = $License.license.details.'Concurrent Terminal Users'
                            'Usage Concurrent Terminal Users' = $License.license.usage.'Concurrent Terminal Users'
                            'Limit Max Attachments Per User' = $License.license.details.'Max Attachments Per User'
                            'Limit Writable Volumes' = $License.license.details.'Writable Volumes'
                            'Limit License Mode' = $License.license.details.'License Mode'
                            'Limit Attach User Volumes' = $License.license.details.'Attach User Volumes'
                            'Issued Date' = $License.license.details.Issued
                            'Valid After Date' = $License.license.details.'Valid After'
                            'Valid Until Date' = $License.license.details.'Valid Until'
                            'Options' = $License.license.details.Options

                        } # Close Out $LicensePSObj = [PSCustomObject]
                    $LicensePSObj | Table -Name 'License Information' -List -ColumnWidths 50,50

                } # Close out section -Style Heading2 'AppVolumes License Information'
            } # Close out if ($InfoLevel.AppVolumes.License -ge 1)

        } # Close out if ($Licenses)


        #---------------------------------------------------------------------------------------------#
        #                                AppStacks                                                    #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Server Connection is successful
        if ($AppStacks) {
            if ($InfoLevel.AppVolumes.AppStacks -ge 1) {
                section -Style Heading1 'AppStack Information' {

                    foreach($AppStackCT in $AppStacks) {
                        $AppStackCount++
                    } # Close out foreach($Application in $Applications.applications)                                       
                    section -Style Heading2 'AppStack Count' {
                        $AppStackCountPSObj = [PSCustomObject]@{
                            'Total Number of AppStacks' = $AppStackCount
                        } # Close out $ApplicationCountPSObj = [PSCustomObject]
                    $AppStackCountPSObj | Table -Name 'AppVolumes AppStack Count' -List -ColumnWidths 50,50
                    } # Close out section -Style Heading2 "AppVolumes AppStack Count"

                    if ($InfoLevel.AppVolumes.AppStacks -ge 2) {
                        foreach($AppStack in $AppStacks) {
                            $AppStackID = $appstack.id
                            $AppStackAssignments = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/appstacks/$AppStackID/assignments"
                            $AppStackIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/appstacks/$AppStackID/"

                            section -Style Heading2 "AppStack $($AppStack.Name) Details" {
                                $AppVolumesAppStacksPSObj = [PSCustomObject]@{
                                    'Name' = $AppStack.Name
                                    'Name HTML' = $AppStack.Name_HTML
                                    'Path' = $AppStack.Path
                                    'Datastore Name' = $AppStack.datastore_Name
                                    'Status' = $AppStack.Status
                                    'Created' = $AppStack.created_At_Human
                                    'Mounted' = $AppStack.mounted_At_Human
                                    'Mount Count' = $AppStack.mount_Count
                                    'Size in MB' = $AppStack.size_mb
                                    'Template Version' = $AppStack.template_version
                                    'Total Assignments' = $AppStack.assignments_Total
                                    'Attachments Total' = $AppStack.attachments_Total
                                    'Attachment Limit' = $AppStack.attachment_limit
                                    'Description' = $AppStackIDSource.appstack.description
                                    'Applications Count' = $AppStackIDSource.appstack.application_count
                                    'Agent Version' = $AppStackIDSource.appstack.agent_version
                                    'Package Agent Version' = $AppStackIDSource.appstack.capture_version
                                    'OS Version' = $AppStackIDSource.appstack.primordial_os_name
                                    'Provisioning Duration' = $AppStackIDSource.appstack.provision_duration

                                } # Close Out $AppVolumesAppStacksPSObj = [PSCustomObject]
                                $AppVolumesAppStacksPSObj | Table -Name 'AppStack Detailes' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 "AppVolumes AppStack Details"

                                
                            foreach($AppStackAssignment in $AppStackAssignments){                            
                                $AppStackAssignName = $AppStackAssignment.Name
                                $AppStackAssignNameSplit = $AppStackAssignName.split("`n")|ForEach-Object{$_.split('>')[1]}|ForEach-Object{$_.split('<')[-2]}

                                $AppVolumesAppStackAssignmentsPSObj = [PSCustomObject]@{
                                    'Assignment Name' = $AppStackAssignNameSplit
                                    'Assignment Type' = $AppStackAssignment.entity_type

                                } # Close Out $AppVolumesAppStackAssignmentsPSObj = [PSCustomObject]
                                $AppVolumesAppStackAssignmentsPSObj | Table -Name 'AppStack Info' -List -ColumnWidths 50,50
                            } # Close out foreach($AppStackAssignment in $AppStackAssignments)

                        } # Close out foreach($AppStack in $AppStacks)
                    } # Close out if ($InfoLevel.AppVolumes.AppStacks -ge 3)
                } # Close out section -Style Heading1 'AppVolumes AppStack Information'
            } # Close out if ($InfoLevel.AppVolumes.AppStacks -ge 1)
        } # Close out if ($AppStacks)


        #---------------------------------------------------------------------------------------------#
        #                                Writeable Volumes                                            #
        #---------------------------------------------------------------------------------------------#

        
        if ($Writables) {
            if ($InfoLevel.AppVolumes.writeables -ge 1) {
                section -Style Heading1 'Writable AppStack Information' {
                        
                    section -Style Heading2 "Writable Volumes Overview" {
                        $AppVolumesWritableOverviewPSObj = [PSCustomObject]@{
                            'Total Writeable Volumes' = $Writables.DataStores.Total_Count
                            'Total Writeable in Warning' = $Writables.DataStores.Warning_Count
                            'Total Writeable in Critical' = $Writables.DataStores.Critical_Count

                        } # Close Out $AppVolumesWritableOverviewPSObj = [PSCustomObject]
                        $AppVolumesWritableOverviewPSObj | Table -Name 'Writable Volumes Overview' -List -ColumnWidths 50,50
                    }

                    if ($InfoLevel.AppVolumes.writeables -ge 2) {
                        foreach($Writable in $Writables.datastores.writable_volumes) {
                            $WritablesID = $Writable.id
                            $WritablesIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api//writables/$WritablesID/"

                            section -Style Heading2 "Writable Volume $($Writable.Name) Details" {
                                $AppVolumesWritablePSObj = [PSCustomObject]@{
                                    'Name' = $Writable.Name
                                    'Name HTML' = $Writable.Name_HTML
                                    'Title' = $Writable.Title
                                    'Title HTML' = $Writable.Title_HTML
                                    'Owner' = $Writable.Owner_name
                                    'Owner Type' = $Writable.Owner_Type
                                    'Created Date' = $Writable.created_at_Human
                                    'Last Updated Date' = $Writable.updated_At_human
                                    'Last Mounted Date' = $Writable.mounted_At_Human
                                    'Attachment State' = $Writable.attached
                                    'Status' = $Writable.Status
                                    'Size In MB' = $Writable.Size_mb
                                    'Number of Times Mounted' = $Writable.Mount_Count
                                    'Free Space In MB' = $Writable.free_mb
                                    'Total Size In MB' = $Writable.total_mb
                                    'Percent Space Available' = $Writable.percent_available
                                    'Template Version' = $Writable.template_version
                                    'Version Count' = $Writable.version_count
                                    'Type' = $Writable.Display_Type
                                    'Error Action' = $Writable.error_action
                                    'Busy State' = $Writable.busy
                                    'File Name' = $Writable.filename
                                    'Path' = $Writable.path
                                    'Datastore Name' = $Writable.Datastore_Name
                                    'Datastore Protected' = $WritablesIDSource.protected
                                    'Datastore Can Expand' = $WritablesIDSource.can_expand
                                    'OS Version' = $WritablesIDSource.primordial_os_name
                                
                                } # Close Out $AppVolumesWritablePSObj = [PSCustomObject]
                                $AppVolumesWritablePSObj | Table -Name 'Writable Volumes Details' -List -ColumnWidths 50,50
                            
                            } # Close out section -Style Heading2 "AppVolumes Writable Volumes
                        } # Close out foreach($AppStack in $Writable)
                    } # Close out if ($InfoLevel.AppVolumes.writeables -ge 3)
                } # Close out section -Style Heading1 'AppVolumes AppStack Information'
            } # Close out if ($InfoLevel.AppVolumes.writeables -ge 1)
        } # Close out if ($Writable)


        #---------------------------------------------------------------------------------------------#
        #                                    Application Info                                         #
        #---------------------------------------------------------------------------------------------#
        
        # Generate report if connection to AppVolumes Application Information is successful
        if ($Applications) {
            if ($InfoLevel.AppVolumes.Applications -ge 1) {
                section -Style Heading1 'Application Information' {
                        
                    foreach($ApplicationCT in $Applications.applications) {
                        $ApplicationCount++
                    } # Close out foreach($Application in $Applications.applications)
                    
                    section -Style Heading2 'Application Count' {
                        $ApplicationCountPSObj = [PSCustomObject]@{
                            'Total Applications is' = $ApplicationCount
                        }
                    $ApplicationCountPSObj | Table -Name 'Application Count' -List -ColumnWidths 50,50
                    } # Close out section -Style Heading2 "AppVolumes Application Count"
                    
                    if ($InfoLevel.AppVolumes.Applications -ge 2) {
                        foreach($Application in $Applications.applications) {
                            
                            $AppStackInstalled = $Application.snapvol
                            #$AppStackInstalledSplit = $AppStackInstalled.split("`n")|ForEach-Object{$_.split('>')[1]}|ForEach-Object{$_.split('<')[-2]}
                            $AppStackInstalledSplit = $AppStackInstalled.split("`n")
                            $AppStackInstalledSplit = $AppStackInstalled.split('>')[1]
                            $AppStackInstalledSplit = $AppStackInstalledSplit.split('<')[-2]

                            $AppName = $Application.Name
                            $AppVersion = $Application.version

                            section -Style Heading2 "Application $($Application.Name) Details" {
                                $ApplicationPSObj = [PSCustomObject]@{
                                    'Name' = $AppName
                                    'Version' = $Appversion
                                    'Publisher' = $Application.publisher
                                    'Assignments Count' = $Application.assignments_count
                                    'Date Created' = $Application.created_at_human
                                    'Icon Location' = $Application.icon
                                    'AppStack Installed On' = $AppStackInstalledSplit
                                    'Assignable' = $Application.assignable
                                } # Close Out $ApplicationPSObj = [PSCustomObject]
                            $ApplicationPSObj | Table -Name 'Application Information' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 'AppVolumes Application Details'
                        } # Close out foreach($Application in $Applications)
                    } # if ($InfoLevel.AppVolumes.Applications -ge 2)
                } # Close out section -Style Heading2 'AppVolumes Application Information'
            } # Close out if ($InfoLevel.AppVolumes.Applications -ge 1)
        } # Close out if ($Applications)


        #---------------------------------------------------------------------------------------------#
        #                                    Active Directory User Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Active Directory User Information is successful
        if ($ActiveDirectoryUsers) {
            if ($InfoLevel.AppVolumes.ADUsers -ge 1) {
                section -Style Heading1 'Active Directory User Information' {
                    if ($InfoLevel.AppVolumes.ADUsers -ge 1) {
                        foreach($ADUserCT in $ActiveDirectoryUsers) {
                            $ADUserCount++
                        } # Close out foreach($ADDomainCT in $ADUser)
                                        
                        section -Style Heading2 'Active Directory User Count' {
                            $ADUserCountPSObj = [PSCustomObject]@{
                                'Total Active Directory Users is' = $ADUserCount
                            } # Close out $ApplicationCountPSObj = [PSCustomObject]
                        $ADUserCountPSObj | Table -Name 'Active Directory User Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Active Directory User Count"
                    } # Close out if ($InfoLevel.AppVolumes.ADUsers -ge 1)
                    BlankLine
                    if ($InfoLevel.AppVolumes.ADUsers -ge 2) {
                        section -Style Heading2 'Active Directory User Details' {
                            foreach($ActiveDirectoryUser in $ActiveDirectoryUsers) {   
                                $ActiveDirectoryUserPSObj = [PSCustomObject]@{
                                    'User Name' = $ActiveDirectoryUser.upn
                                    'User Last Logon' = $ActiveDirectoryUser.last_login_human
                                    'User Status' = $ActiveDirectoryUser.status
                                    "User Writable" = $ActiveDirectoryUser.writables
                                    "User AppStack" = $ActiveDirectoryUser.appstacks
                                    "User Attachment's" = $ActiveDirectoryUser.attachments
                                    "User Login's" = $ActiveDirectoryUser.logins
                                } # Close Out $ActiveDirectoryUserPSObj = [PSCustomObject]
                                $ActiveDirectoryUserPSObj | Table -Name 'Active Directory User Information' -list -ColumnWidths 50,50
                                
                            } # Close out foreach($ActiveDirectoryUser in $ActiveDirectoryUsers)
                        } # Close out section -Style Heading2 'AppVolumes Active Directory User Details'
                    } # Close out if ($InfoLevel.AppVolumes.ADUsers -ge 3)
                } # Close out section -Style Heading2 'AppVolumes Active Directory User Information'
            } # Close out if ($InfoLevel.AppVolumes.ADUsers -ge 1)
        } # Close out if ($ActiveDirectoryUsers)


        #---------------------------------------------------------------------------------------------#
        #                                    Active Directory Group Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Active Directory Group Information is successful
        if ($ActiveDirectoryGroups) {
            if ($InfoLevel.AppVolumes.ADGroups -ge 1) {
                section -Style Heading1 'Active Directory Group Information' {
                    if ($InfoLevel.AppVolumes.ADGroups -ge 1) {
                        foreach($ADGroupCT in $ActiveDirectoryGroups.groups) {
                            $ADGroupCount++
                        } # Close out foreach($ADDomainCT in $ADGroup)
                                        
                        section -Style Heading2 'Active Directory Group Count' {
                            $ADGroupCountPSObj = [PSCustomObject]@{
                                'Total Active Directory Groups is' = $ADGroupCount
                            } # Close out $ADGroupCountPSObj = [PSCustomObject]
                        $ADGroupCountPSObj | Table -Name 'Active Directory Group Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Active Directory Group Count"
                    } # Close out if ($InfoLevel.AppVolumes.ADGroups -ge 1)

                    if ($InfoLevel.AppVolumes.ADGroups -ge 2) {
                        section -Style Heading2 'Active Directory Group Details' {
                            $ActiveDirectoryGroupPSObj = foreach($ActiveDirectoryGroup in $ActiveDirectoryGroups.groups) {   
                                [PSCustomObject]@{
                                    'Group Name' = $ActiveDirectoryGroup.name
                                    'Group Last Logon' = $ActiveDirectoryGroup.last_login_human
                                    'Group Status' = $ActiveDirectoryGroup.status
                                } # Close Out $ActiveDirectoryGroupPSObj = [PSCustomObject]   
                            } # Close out foreach($ActiveDirectoryGroup in $ActiveDirectoryGroups)
                            $ActiveDirectoryGroupPSObj | Table -Name 'Active Directory Group Information' -ColumnWidths 50,30,20
                        } # Close out section -Style Heading2 'AppVolumes Active Directory Group Details'
                    } # Close out if ($InfoLevel.AppVolumes.ADGroups -ge 3)
                } # Close out section -Style Heading2 'AppVolumes Active Directory Group Information'
            } # Close out if ($InfoLevel.AppVolumes.ADGroups -ge 1)
        } # Close out if ($ActiveDirectoryGroups)


        #---------------------------------------------------------------------------------------------#
        #                                DataStores                                                   #
        #---------------------------------------------------------------------------------------------#


        # Generate report if connection to AppVolumes DataStores is successful
        if ($Datastores) {
            if ($InfoLevel.AppVolumes.StorageLocations -ge 1) {
                section -Style Heading1 'Datastores' {
                    foreach ($DatastoreD in $Datastores.datastores){
                        if($DatastoreD.uniq_string -eq $Datastores.writable_storage){
                            $DatastoreWritableStorage = $DatastoreD.name
                        } #Close out if($DatastoreD.uniq_string -eq $Datastores.writable_storage)
                        if($DatastoreD.uniq_string -eq $Datastores.appstack_storage){
                            $DatastoreAppStorage = $DatastoreD.name
                        } #Close out if($DatastoreD.uniq_string -eq $Datastores.appstack_storage)
                        if($DatastoreD.uniq_string -eq $Datastores.writable_backup_recurrent_datastore){
                            $DatastoreAWriteableBackupRecurrentDatastore = $DatastoreD.name
                        } #Close out if($DatastoreD.uniq_string -eq $Datastores.writable_backup_recurrent_datastore)
                    } #Close out foreach ($DatastoreD in $Datastores.datastores)

                    section -Style Heading2 "Datastore Overview Information" {
                        $AppVolumesDataStoreOverviewPSObj = [PSCustomObject]@{
                            'Datacenter' = $Datastores.Datacenter
                            'Writable Storage Location' = $DatastoreWritableStorage
                            'AppStack Storage Location' = $DatastoreAppStorage
                            'Datastore Writeable Backup Location' = $DatastoreAWriteableBackupRecurrentDatastore
                            'Datastore AppStack Path' = $Datastores.appstack_path
                            'Datastore Writeable Path' = $Datastores.writable_path
                            'Datastore Writeable Archive Path' = $Datastores.writable_archive_path
                            'Datastore Writeable Backup Recurrent Path' = $Datastores.writable_backup_recurrent_path
                            'Datastore AppStack Template Path' = $Datastores.appstack_template_path
                            'Datastore Writeable Template Path' = $Datastores.writable_template_path
                        } # Close out $AppVolumesDataStoreOverviewPSObj = [PSCustomObject]
                        $AppVolumesDataStoreOverviewPSObj | Table -Name 'Datastore Overview Information' -List -ColumnWidths 50,50
                    } # Close out section -Style Heading2 'AppVolumes Datastore Overview Information'

                    if ($InfoLevel.AppVolumes.StorageLocations -ge 1) {
                        foreach($StorageLocationCT in $Datastores.datastores) {
                            $StorageLocationCount++
                        } # Close out foreach($StorageLocationCT in $StorageLocations)
                                        
                        section -Style Heading2 'Datastore Count' {
                            $StorageLocationCountPSObj = [PSCustomObject]@{
                                'Total Datastores is' = $StorageLocationCount
                            } # Close out $ApplicationCountPSObj = [PSCustomObject]
                        $StorageLocationCountPSObj | Table -Name 'Datastore Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Datastore Count"
                    } # Close out if ($InfoLevel.AppVolumes.StorageLocations -ge 1)

                    if ($InfoLevel.AppVolumes.StorageLocations -ge 2) {
                        foreach($DataStore in $Datastores.datastores) {
                            section -Style Heading2 "$($DataStore.name) Details" {
                                $AppvolumesDataStorePSObj = [PSCustomObject]@{
                                    'Name' = $DataStore.name
                                    'Display Name' = $DataStore.display_Name
                                    'Category' = $DataStore.Catagory
                                    'Datacenter ' = $DataStore.datacenter
                                    'Notes' = $DataStore.note
                                    'Description' = $DataStore.description
                                    'Accessible' = $DataStore.accessible
                                    'Host' = $DataStore.host
                                    'Template Storage' = $DataStore.template_storage
                                    'Host Username' = $DataStore.host_username
                                    'Free Space' = $DataStore.free_space
                                    'Capacity' = $DataStore.capacity

                                } # Close Out $AppvolumesDataStorePSObj = [PSCustomObject]
                                $AppvolumesDataStorePSObj | Table -Name 'Datastore Details' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 "AppVolumes Datastore"
                        } # Close out foreach($DataStore in $DataStores)
                    } # Close out if ($InfoLevel.AppVolumes.StorageLocations -ge 3)
                } # section -Style Heading2 "AppVolumes Datastore Overview Information"
            } # Close out if ($InfoLevel.AppVolumes.StorageLocations -ge 1)
        } # Close out if ($DataStores)


        #---------------------------------------------------------------------------------------------#
        #                                    Storage Groups                                           #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Storage Groups is successful
        if ($StorageGroups) {
            if ($InfoLevel.AppVolumes.StorageGroups -ge 1) {
                section -Style Heading1 'Storage Groups' {
                    
                    if ($InfoLevel.AppVolumes.StorageGroups -ge 1) {
                        foreach($StorageGroupCT in $StorageGroups.storage_groups) {
                            $StorageGroupCount++
                        } # Close out foreach($StorageGroupCT in $StorageGroups)
                                        
                        section -Style Heading2 'Storage Group Count' {
                            $StorageGroupCountPSObj = [PSCustomObject]@{
                                'Total Storage Groups is' = $StorageGroupCount
                            } # Close out $ApplicationCountPSObj = [PSCustomObject]
                        $StorageGroupCountPSObj | Table -Name 'Storage Group Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes StorageGroup Count"
                    } # Close out if ($InfoLevel.AppVolumes.StorageGroups -ge 1)

                    if ($InfoLevel.AppVolumes.StorageGroups -ge 2) {
                        foreach($StorageGroup in $StorageGroups.storage_groups) {
                            section -Style Heading2 "Storage Group $($StorageGroup.name) Details" {
                                $StorageGroupPSObj = [PSCustomObject]@{
                                    'Storage Group Name' = $StorageGroup.name
                                    'Distribution Strategy' = $StorageGroup.strategy
                                    'Template Storage' = $StorageGroup.template_storage
                                    'Members Count' = $StorageGroup.members
                                    'Member Name Prefix' = $StorageGroup.member_prefix
                                    'Space Used' = $StorageGroup.space_used
                                    'Total Space' = $StorageGroup.space_total
                                    'Creation Date' = $StorageGroup.created_at_human
                                    'Auto Import' = $StorageGroup.auto_import
                                    'Auto Replicate' = $StorageGroup.auto_replicate
                                    'Last Replicated Date' = $StorageGroup.replicated_at_human
                                    'Last Imported Date' = $StorageGroup.imported_at_human
                                    'Last Curated Date' = $StorageGroup.curated_at_human
                                } # Close Out $StorageGroupPSObj = [PSCustomObject]
                            $StorageGroupPSObj | Table -Name 'Storage Group Information' -List
                            } # Close out section -Style Heading2 'AppVolumes Storage Group Details
                        } # Close out foreach($StorageGroup in $StorageGroups)
                    } # Close out if ($InfoLevel.AppVolumes.StorageGroups -ge 3)
                } # Close out section -Style Heading2 'AppVolumes Storage Groups'
            } # Close out if ($InfoLevel.AppVolumes.StorageGroups -ge 1)
        } # Close out if ($StorageGroups)


        #---------------------------------------------------------------------------------------------#
        #                                    Active Directory Domains Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Active Directory Domains Information is successful
        if ($LDAPDomains) {
            if ($InfoLevel.AppVolumes.ADDomains -ge 1) {
                section -Style Heading1 'Active Directory Domains Information' {
                        
                    if ($InfoLevel.AppVolumes.ADDomains -ge 1) {
                        foreach($ADDomainCT in $LDAPDomains.ldap_domains) {
                            $ADDomainCount++
                        } # Close out foreach($ADDomainCT in $ADDomains)
                                        
                        section -Style Heading2 'AD Domain Count' {
                            $ADDomainCountPSObj = [PSCustomObject]@{
                                'Total AD Domains is' = $ADDomainCount
                            } # Close out $ApplicationCountPSObj = [PSCustomObject]
                        $ADDomainCountPSObj | Table -Name 'AD Domain Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes AD Domain Count"
                    } # Close out if ($InfoLevel.AppVolumes.ADDomains -ge 1)

                    if ($InfoLevel.AppVolumes.ADDomains -ge 2) {
                        foreach($LDAPDomain in $LDAPDomains.ldap_domains) {
                            section -Style Heading2 "Active Directory Domain $($LDAPDomain.domain) Details" {
                                $LDAPDomainsPSObj = [PSCustomObject]@{
                                    'Active Directory Domain' = $LDAPDomain.domain
                                    'Username' = $LDAPDomain.username
                                    'Base' = $LDAPDomain.base
                                    'NetBIOS' = $LDAPDomain.netbios
                                    'LDAPS' = $LDAPDomain.ldaps
                                    'LDAP_TLS' = $LDAPDomain.ldap_tls
                                    'SSL Verify' = $LDAPDomain.ssl_verify
                                    'Port' = $LDAPDomain.port
                                    'Effective Port' = $LDAPDomain.effective_port
                                    'Created At' = $LDAPDomain.created_at
                                    'Updated At' = $LDAPDomain.updated_at
                                } # Close Out $LDAPDomainsPSObj = [PSCustomObject]
                            $LDAPDomainsPSObj | Table -Name 'Active Directory Domains Information' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 'AppVolumes Active Directory Domains Details'
                        } # Close out foreach($LDAPDomain in $LDAPDomains.group_permissions)
                    } # Close out if ($InfoLevel.AppVolumes.ADDomains -ge 3)
                } # Close out section -Style Heading2 'AppVolumes Active Directory Domains Information'
            } # Close out if ($InfoLevel.AppVolumes.ADDomains -ge 1)
        } # Close out if ($LDAPDomains)


        #---------------------------------------------------------------------------------------------#
        #                                    Administrator Roles Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Administrator Roles Information is successful
        if ($AdminGroups) {
            if ($InfoLevel.AppVolumes.AdminGroups -ge 1) {
                section -Style Heading1 'Administrator Roles Information' {
                    
                    if ($InfoLevel.AppVolumes.AdminGroups -ge 1) {
                        foreach($AdminGroupCT in $AdminGroups.group_permissions) {
                            $AdminGroupCount++
                        } # Close out foreach($AdminGroupCT in $AdminGroup)
                                        
                        section -Style Heading2 'Admin Groups Count' {
                            $AdminGroupCountPSObj = [PSCustomObject]@{
                                'Total Admin Groups is' = $AdminGroupCount
                            } # Close out $AdminGroupPSObj = [PSCustomObject]
                        $AdminGroupCountPSObj | Table -Name 'Admin Groups Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Admin Groups Count"
                    } # Close out if ($InfoLevel.AppVolumes.AdminGroup -ge 1)
                    
                    if ($InfoLevel.AppVolumes.AdminGroups -ge 2) {
                        foreach($AdminGroup in $AdminGroups.group_permissions) {
                            section -Style Heading2 'Administrator Roles Details' {
                                $AdminGroupsPSObj = [PSCustomObject]@{
                                    'Role' = $AdminGroup.Role
                                    'Assignee UPN' = $AdminGroup.assignee_upn
                                    'Assignee Type' = $AdminGroup.assignee_type
                                    'Assignment Created at' = $AdminGroup.created_at
                                    'Assignment Updated at' = $AdminGroup.updated_at
                                } # Close Out $AdminGroupsPSObj = [PSCustomObject]
                            $AdminGroupsPSObj | Table -Name 'Administrators Roles Information' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 'AppVolumes Administrator Roles Details'
                        } # Close out foreach($AdminGroup in $AdminGroups.group_permissions)
                    } # Close out if ($InfoLevel.AppVolumes.AdminGroups -ge 3)
                } # Close out section -Style Heading2 'AppVolumes Administrator Roles Information'
            } # Close out if ($InfoLevel.AppVolumes.AdminGroups -ge 1)
        } # Close out if ($AdminGroups)


        #---------------------------------------------------------------------------------------------#
        #                                    Machine Manager Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Machine Manager Information is successful
        if ($MachineManagers) {
            if ($InfoLevel.AppVolumes.MachineManagers -ge 1) {
                section -Style Heading1 'Machine Manager Information' {
                    
                    if ($InfoLevel.AppVolumes.MachineManagers -ge 1) {
                        foreach($MachineManagerCT in $MachineManagers.machine_managers) {
                            $MachineManagerCount++
                        } # Close out foreach($ADDomainCT in $MachineManagers)
                                        
                        section -Style Heading2 'Machine Managers Count' {
                            $MachineManagerPSObj = [PSCustomObject]@{
                                'Total Machine Managers is' = $MachineManagerCount
                            } # Close out $MachineManagerPSObj = [PSCustomObject]
                        $MachineManagerPSObj | Table -Name 'Machine Managers Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Machine Managers Count"
                    } # Close out if ($InfoLevel.AppVolumes.MachineManagers -ge 1)

                    if ($InfoLevel.AppVolumes.MachineManagers -ge 2) {
                        foreach($MachineManager in $MachineManagers.machine_managers) {
                            section -Style Heading2 "Machine Manager $($MachineManager.Host) Details" {
                                $MachineManagerPSObj = [PSCustomObject]@{
                                    'Name' = $MachineManager.host
                                    'Username' = $MachineManager.Username
                                    'Adapter Type' = $MachineManager.adapter_type
                                    'Type' = $MachineManager.type
                                    'upports Multi' = $MachineManager.supports_multi
                                } # Close Out $MachineManagerPSObj = [PSCustomObject]
                            $MachineManagerPSObj | Table -Name 'Machine Manager Information' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 'AppVolumes Machine Manager Details'
                        } # Close out foreach($MachineManager in $MachineManagers)
                    } # Close out if ($InfoLevel.AppVolumes.MachineManagers -ge 1)
                } # Close out section -Style Heading2 'AppVolumes Machine Manager Information'
            } # Close out if ($InfoLevel.AppVolumes.MachineManagers -ge 1)
        } # Close out if ($MachineManagers)


        #---------------------------------------------------------------------------------------------#
        #                                    Storage Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Storage Information is successful
        if ($Storages) {
            if ($InfoLevel.AppVolumes.Storage -ge 1) {
                section -Style Heading1 'Storage Information' {
                    
                    if ($InfoLevel.AppVolumes.Storage -ge 1) {
                        foreach($StrorageCT in $Storages.Storages) {
                            $StorageCount++
                        } # Close out foreach($StorageCT in $Storage)
                                        
                        section -Style Heading2 'Storage Count' {
                            $StorageCountPSObj = [PSCustomObject]@{
                                'Total Storage is' = $StorageCount
                            } # Close out $StorageCountPSObj = [PSCustomObject]
                        $StorageCountPSObj | Table -Name 'Storage Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Storage Count"
                    } # Close out if ($InfoLevel.AppVolumes.Storage -ge 1)

                    if ($InfoLevel.AppVolumes.Storage -ge 2) {
                        foreach($Storage in $Storages.Storages) {
                            
                            section -Style Heading2 "$($Storage.Name) Details" {
                                $StoragePSObj = [PSCustomObject]@{
                                    'Name' = $Storage.Name
                                    'Host' = $Storage.host
                                    'Space Users' = $Storage.space_used
                                    'Space Total' = $Storage.space_total
                                    "Number of AppStack's" = $Storage.num_appstacks
                                    "Number of Writable's" = $Storage.num_writables
                                    'Attachable' = $Storage.attachable
                                    'Created Date' = $Storage.created_at_human
                                    'Status' = $Storage.status
                                } # Close Out $StoragePSObj = [PSCustomObject]
                            $StoragePSObj | Table -Name 'Storage Information' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 'AppVolumes Storage Details'
                        } # Close out foreach($Storage in $Storages)
                    } # Close out if ($InfoLevel.AppVolumes.Storage -ge 3)
                } # Close out section -Style Heading2 'AppVolumes Storage Information'
            } # Close out if ($InfoLevel.AppVolumes.Storage -ge 1)
        } # Close out if ($Storages)


        #---------------------------------------------------------------------------------------------#
        #                      AppVolumes Manger Settings Info                                        #
        #---------------------------------------------------------------------------------------------#

        # Generate report if connection to AppVolumes Settings Information is successful
        if ($Settings) {
            if ($InfoLevel.AppVolumes.Applications -ge 1) {
                section -Style Heading1 'AppVolumes Settings Information' {
                    foreach($Setting in $Settings.data.setting){
                        if($Setting.key -eq "ui_session_timeout"){
                            $UISessionTimeout = $Setting.value
                        } # Close out if($Setting.key -eq "ui_session_timeout")
                        #Regular Backups
                        if($Setting.key -eq "enable_writable_recurrent_backup"){
                            $RegularBackups = $Setting.value
                        } # Close out if($Setting.key -eq "enable_writable_recurrent_backup")
                        #Regular Backups Days
                        if($Setting.key -eq "writable_backup_recurrent_interval"){
                            $RegularBackupsInterval = $Setting.value
                        } # Close out if($Setting.key -eq "writable_backup_recurrent_interval")
                        # Backup Storage Location
                        if($Setting.key -eq "writable_backup_recurrent_datastore"){
                            $StorageLocation = $Setting.value
                        } # Close out if($Setting.key -eq "writable_backup_recurrent_datastore")
                        # Backup Storage Path
                        if($Setting.key -eq "writable_backup_recurrent_path"){
                            $StoragePath = $Setting.value
                        } # Close out if($Setting.key -eq "writable_backup_recurrent_path")
                        # Backup Storage Path
                        if($Setting.key -eq "manage_sec"){
                            $NonDomainEntities = $Setting.value
                        } # Close out if($Setting.key -eq "manage_sec")
                    } # Close out foreach($Setting in $Settings.data.setting)

                    foreach ($Datastore in $Datastores.datastores){
                        if($Datastore.uniq_string -eq $StorageLocation){
                            $DatastoreBackupName = $Datastore.name
                        } # Close out if($Datastore.uniq_string -eq $StorageLocation)
                    } # Close out foreach ($Datastore in $Datastores.datastores)

                    foreach($Setting in $Settings.data.advanced_setting){
                        # Disable Volume Cache
                        if($Setting.key -eq "DISABLE_SNAPVOL_CACHE"){
                            $DisableSnapVolumeCache = $Setting.value
                        } # Close out if($Setting.key -eq "DISABLE_SNAPVOL_CACHE")
                        # Disable Token AD Query
                        if($Setting.key -eq "DISABLE_TOKEN_AD_QUERY"){
                            $DisableTokenADQuery = $Setting.value
                        } # Close out if($Setting.key -eq "DISABLE_TOKEN_AD_QUERY")
                    } # Close out foreach($Setting in $Settings.data.advanced_setting)

                    section -Style Heading2 "AppVolumes Settings Details" {
                        $SettingsPSObj = [PSCustomObject]@{
                            'UI Session Timeout' = $UISessionTimeout
                            'Non-Domain Entities' = $NonDomainEntities
                            'Writeable Volumes Regular Backups' = $RegularBackups
                            'Writeable Volumes Regular Backups Interval' = $RegularBackupsInterval
                            'Writeable Volumes Storage Location' = $DatastoreBackupName
                            'Writeable Volumes Storage Path' = $StoragePath
                            'Disable Volume Cache' = $DisableSnapVolumeCache
                            'Disable Token AD Query' = $DisableTokenADQuery
                        } # Close Out $SettingsPSObj = [PSCustomObject]
                        $SettingsPSObj | Table -Name 'Settings Information' -List -ColumnWidths 50,50
                    } # Close out section -Style Heading2 'AppVolumes Settings Details'
                } # Close out section -Style Heading2 'AppVolumes Settings Information'
            } # Close out if ($InfoLevel.AppVolumes.Settings -ge 1)
        } # Close out if ($Settings)
    } # Close out foreach ($AppStacks in $Target)
} # Close out function Invoke-AsBuiltReport.VMware.AppVolumes