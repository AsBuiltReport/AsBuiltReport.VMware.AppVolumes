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

    # Import JSON Configuration for Options and InfoLevel
    $InfoLevel = $ReportConfig.InfoLevel
    #$Options = $ReportConfig.Options

    # If custom style not set, use default style
    if (!$StylePath) {
        & "$PSScriptRoot\..\..\AsBuiltReport.VMware.AppVolumes.Style.ps1"
    } #Close out If (!$StylePath)


    $RESTAPIUser = $Credential.UserName
    $Credential.Password | ConvertFrom-SecureString
    $RESTAPIPassword = $Credential.GetNetworkCredential().password

    $AppVolRestCreds = @{
        username = $RESTAPIUser
        password = $RESTAPIPassword
    }

    foreach ($AppVolServer in $Target) {
    
        Try {
            $AppVolServerRest = Invoke-RestMethod -SessionVariable SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/sessions" -Body $AppVolRestCreds 
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
            $GeneralAppInfo = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/version"

            #Managers
            $Managers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/manager_services"

            #License Info
            $License = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/license"

            #AppStacks
            $AppStacks = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/appstacks"

            #Writable Volumes
            $Writables = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/writables"

            #Applications
            $Applications = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/applications"

            #Directory Users
            $ActiveDirectoryUsers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users"

            #Directory Groups
            $ActiveDirectoryGroups = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/groups"

            #Storage Locations
            $Datastores = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores"

            #Storage Groups
            $StorageGroups = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storage_groups"

            #AD Domains
            $LDAPDomains = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/ldap_domains"

            #Admin Roles
            $AdminGroups = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/group_permissions"

            #Machine Managers
            $MachineManagers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers"

            #Storage
            $Storages = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storages"

            #Settings
            $Settings = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/settings"

        } # Close out if ($AppVolServers) 


        #---------------------------------------------------------------------------------------------#
        #                                    AppVolumes Manager General Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Manager General Information is successful
        if ($GeneralAppInfo) {
            if ($InfoLevel.AppVolumes.General -ge 1) {
                section -Style Heading1 "AppVolumes Manager $($AppVolServer) General Information" {

                    $GeneralAppInfoPSObj = [PSCustomObject]@{

                        'AppVolumes Manager Server' = $AppVolServer
                        'AppVolumes Manager Version' = $GeneralAppInfo.version
                        'AppVolumes Manager Configured' = $GeneralAppInfo.configured
                        'AppVolumes Manager Uptime' = $GeneralAppInfo.uptime
                    } # Close Out $GeneralAppInfoPSObj = [PSCustomObject]
                    $GeneralAppInfoPSObj | Table -Name 'AppVolumes Manager General Information' -List -ColumnWidths 50,50
                } # Close out section -Style Heading2 'AppVolumes Manager General Information'
            } # Close out if ($InfoLevel.AppVolumes.General -ge 1)
        } # Close out if ($GeneralAppInfo)


        #---------------------------------------------------------------------------------------------#
        #                                    AppVolumes Manager Servers Info                                             #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes AppVolumes Manager Servers Information is successful
        if ($Managers) {
            if ($InfoLevel.AppVolumes.Managers -ge 1) {
                section -Style Heading1 'AppVolumes Manager Servers Information' {
                        $ii = 1
                        foreach($Manager in $Managers.services) {
                            if(($ii % 4) -eq 0){
                                PageBreak
                            }
                            $ii++
                            section -Style Heading2 "AppVolumes Manager Server $($Manager.name) Details" {
                                $ManagersPSObj = [PSCustomObject]@{
                                    'AppVolumes Manager Server Name' = $Manager.name
                                    'AppVolumes Manager Server Internal Version' = $Manager.internal_version
                                    'AppVolumes Manager Server Product Version' = $Manager.product_version
                                    'AppVolumes Manager Server Domain Name' = $Manager.domain_name
                                    'AppVolumes Manager Server Computer Name' = $Manager.computer_name
                                    'AppVolumes Manager Server Computer FQDN' = $Manager.fqdn
                                    'AppVolumes Manager Server Registered' = $Manager.registered
                                    'AppVolumes Manager Server Secure' = $Manager.secure
                                    'AppVolumes Manager Server Status' = $Manager.status
                                    'AppVolumes Manager Server First Seen At' = $Manager.first_seen_at_human
                                    'AppVolumes Manager Server Last Seen At' = $Manager.last_seen_at_human

                                } # Close Out $ManagersPSObj = [PSCustomObject]
                            $ManagersPSObj | Table -Name 'AppVolumes Manager Servers Information' -List -ColumnWidths 50,50
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
                PageBreak
                section -Style Heading1 'AppVolumes License Information' {

                    Switch ($License.license.invalid)
                        {
                            'True' {$LicenseInvalid = 'False' }
                            'False' {$LicenseInvalid = 'True' }
                        }

                        $LicensePSObj = [PSCustomObject]@{
                            'AppVolumes Key Create Date' = $License.license.Keycreate
                            'AppVolumes Key Valid' = $LicenseInvalid
                            'AppVolumes License Limit Users' = $License.license.details.users
                            'AppVolumes License Usage Users' = $License.license.usage.Users
                            'AppVolumes License Limit Desktops' = $License.license.details.Desktops
                            'AppVolumes License Usage Desktops' = $License.license.usage.Desktops
                            'AppVolumes License Limit Servers' = $License.license.details.Servers
                            'AppVolumes License Usage Server' = $License.license.usage.Servers
                            'AppVolumes License Limit Concurrent Users' = $License.license.details.'Concurrent Users'
                            'AppVolumes License Usage Concurrent Users' = $License.license.usage.'Concurrent Users'
                            'AppVolumes License Limit Concurrent Desktops' = $License.license.details.'Concurrent Desktops'
                            'AppVolumes License Usage Concurrent Desktops' = $License.license.usage.'Concurrent Desktops'
                            'AppVolumes License Limit Concurrent Servers' = $License.license.details.'Concurrent Servers'
                            'AppVolumes License Usage Concurrent Servers' = $License.license.usage.'Concurrent Servers'
                            'AppVolumes License Limit Terminal Users' = $License.license.details.'Terminal Users'
                            'AppVolumes License Usage Terminal Users' = $License.license.usage.'Terminal Users'
                            'AppVolumes License Limit Concurrent Terminal Users' = $License.license.details.'Concurrent Terminal Users'
                            'AppVolumes License Usage Concurrent Terminal Users' = $License.license.usage.'Concurrent Terminal Users'
                            'AppVolumes License Limit Max Attachments Per User' = $License.license.details.'Max Attachments Per User'
                            'AppVolumes License Limit Writable Volumes' = $License.license.details.'Writable Volumes'
                            'AppVolumes License Limit License Mode' = $License.license.details.'License Mode'
                            'AppVolumes License Limit Attach User Volumes' = $License.license.details.'Attach User Volumes'
                            'AppVolumes License Issued Date' = $License.license.details.Issued
                            'AppVolumes License Valid After Date' = $License.license.details.'Valid After'
                            'AppVolumes License Valid Until Date' = $License.license.details.'Valid Until'
                            'AppVolumes License Options' = $License.license.details.Options

                        } # Close Out $LicensePSObj = [PSCustomObject]
                    $LicensePSObj | Table -Name 'AppVolumes License Information' -List -ColumnWidths 50,50

                } # Close out section -Style Heading2 'AppVolumes License Information'
            } # Close out if ($InfoLevel.AppVolumes.License -ge 1)

        } # Close out if ($Licenses)


        #---------------------------------------------------------------------------------------------#
        #                                AppStacks                                                    #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to AppVolumes Server Connection is successful
        if ($AppStacks) {
            if ($InfoLevel.AppVolumes.AppStacks -ge 1) {
                PageBreak
                section -Style Heading1 'AppVolumes AppStack Information' {

                    foreach($AppStackCT in $AppStacks) {
                        $AppStackCount++
                    } # Close out foreach($Application in $Applications.applications)                                       
                    section -Style Heading2 'AppVolumes AppStack Count' {
                        $AppStackCountPSObj = [PSCustomObject]@{
                            'AppVolumes Total Number of AppStacks is' = $AppStackCount
                        } # Close out $ApplicationCountPSObj = [PSCustomObject]
                    $AppStackCountPSObj | Table -Name 'AppVolumes AppStack Count' -List -ColumnWidths 50,50
                    } # Close out section -Style Heading2 "AppVolumes AppStack Count"

                    if ($InfoLevel.AppVolumes.AppStacks -ge 2) {
                        foreach($AppStack in $AppStacks) {
                            $AppStackID = $appstack.id
                            $AppStackAssignments = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/appstacks/$AppStackID/assignments"
                            $AppStackIDSource = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/appstacks/$AppStackID/"

                            PageBreak
                            section -Style Heading2 "AppVolumes AppStack $($AppStack.Name) Details" {
                                $AppVolumesAppStacksPSObj = [PSCustomObject]@{
                                    'AppStack Name' = $AppStack.Name
                                    'AppStack Name HTML' = $AppStack.Name_HTML
                                    'AppStack Path' = $AppStack.Path
                                    'AppStack Datastore Name' = $AppStack.datastore_Name
                                    'AppStack Status' = $AppStack.Status
                                    'AppStack Created At' = $AppStack.created_At_Human
                                    'AppStack Mounted At' = $AppStack.mounted_At_Human
                                    'AppStack Mount Count' = $AppStack.mount_Count
                                    'AppStack Size in MB' = $AppStack.size_mb
                                    'AppStack Template Version' = $AppStack.template_version
                                    'AppStack Total Assignments' = $AppStack.assignments_Total
                                    'AppStack Attachments Total' = $AppStack.attachments_Total
                                    'AppStack Attachment Limit' = $AppStack.attachment_limit
                                    'AppStack Description' = $AppStackIDSource.appstack.description
                                    'AppStack Applications Count' = $AppStackIDSource.appstack.application_count
                                    'AppStack Agent Version' = $AppStackIDSource.appstack.agent_version
                                    'AppStack Package Agent Version' = $AppStackIDSource.appstack.capture_version
                                    'AppStack OS Version' = $AppStackIDSource.appstack.primordial_os_name
                                    'AppStack Provisioning Duration' = $AppStackIDSource.appstack.provision_duration

                                } # Close Out $AppVolumesAppStacksPSObj = [PSCustomObject]
                                $AppVolumesAppStacksPSObj | Table -Name 'AppVolumes AppStack Detailes' -List -ColumnWidths 50,50
                            } # Close out section -Style Heading2 "AppVolumes AppStack Details"

                                
                            foreach($AppStackAssignment in $AppStackAssignments){                            
                                $AppStackAssignName = $AppStackAssignment.Name
                                $AppStackAssignNameSplit = $AppStackAssignName.split("`n")|ForEach-Object{$_.split('>')[1]}|ForEach-Object{$_.split('<')[-2]}

                                $AppVolumesAppStackAssignmentsPSObj = [PSCustomObject]@{
                                    'AppStack Assignment Name' = $AppStackAssignNameSplit
                                    'AppStack Assignment Type' = $AppStackAssignment.entity_type

                                } # Close Out $AppVolumesAppStackAssignmentsPSObj = [PSCustomObject]
                                $AppVolumesAppStackAssignmentsPSObj | Table -Name 'VMware AppVolumes AppStack Info' -List -ColumnWidths 50,50
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
                PageBreak
                section -Style Heading1 'AppVolumes Writable AppStack Information' {
                        
                    section -Style Heading2 "AppVolumes Writable Volumes Overview" {
                        $AppVolumesWritableOverviewPSObj = [PSCustomObject]@{
                            'Total Writeable Volumes' = $Writables.DataStores.Total_Count
                            'Total Writeable in Warning' = $Writables.DataStores.Warning_Count
                            'Total Writeable in Critical' = $Writables.DataStores.Critical_Count

                        } # Close Out $AppVolumesWritableOverviewPSObj = [PSCustomObject]
                        $AppVolumesWritableOverviewPSObj | Table -Name 'VMware AppVolumes Writable Volumes Overview' -List -ColumnWidths 50,50
                    }

                    if ($InfoLevel.AppVolumes.writeables -ge 2) {
                        foreach($Writable in $Writables.datastores.writable_volumes) {
                            $WritablesID = $Writable.id
                            $WritablesIDSource = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api//writables/$WritablesID/"

                            PageBreak
                            section -Style Heading2 "AppVolumes Writable Volume $($Writable.Name) Details" {
                                $AppVolumesWritablePSObj = [PSCustomObject]@{
                                    'Writeable Volume Name' = $Writable.Name
                                    'Writeable Volume Name HTML' = $Writable.Name_HTML
                                    'Writeable Volume Title' = $Writable.Title
                                    'Writeable Volume Title HTML' = $Writable.Title_HTML
                                    'Writeable Volume Owner' = $Writable.Owner_name
                                    'Writeable Volume Owner Type' = $Writable.Owner_Type
                                    'Writeable Volume Created Date' = $Writable.created_at_Human
                                    'Writeable Volume Last Updated Date' = $Writable.updated_At_human
                                    'Writeable Volume Last Mounted Date' = $Writable.mounted_At_Human
                                    'Writeable Volume Attachment State' = $Writable.attached
                                    'Writeable Volume Status' = $Writable.Status
                                    'Writeable Volume Size In MB' = $Writable.Size_mb
                                    'Writeable Volume Number of Times Mounted' = $Writable.Mount_Count
                                    'Writeable Volume Free Space In MB' = $Writable.free_mb
                                    'Writeable Volume Total Size In MB' = $Writable.total_mb
                                    'Writeable Volume Percent Space Available' = $Writable.percent_available
                                    'Writeable Volume Template Version' = $Writable.template_version
                                    'Writeable Volume Version Count' = $Writable.version_count
                                    'Writeable Volume Type' = $Writable.Display_Type
                                    'Writeable Volume Error Action' = $Writable.error_action
                                    'Writeable Volume Busy State' = $Writable.busy
                                    'Writeable Volume File Name' = $Writable.filename
                                    'Writeable Volume Path' = $Writable.path
                                    'Writeable Volume Datastore Name' = $Writable.Datastore_Name
                                    'Writeable Volume Datastore Protected' = $WritablesIDSource.protected
                                    'Writeable Volume Datastore Can Expand' = $WritablesIDSource.can_expand
                                    'Writeable Volume OS Version' = $WritablesIDSource.primordial_os_name
                                
                                } # Close Out $AppVolumesWritablePSObj = [PSCustomObject]
                                $AppVolumesWritablePSObj | Table -Name 'VMware AppVolumes Writable Volumes Details' -List -ColumnWidths 50,50
                            
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
                PageBreak
                section -Style Heading1 'AppVolumes Application Information' {
                        
                    foreach($ApplicationCT in $Applications.applications) {
                        $ApplicationCount++
                    } # Close out foreach($Application in $Applications.applications)
                    
                    section -Style Heading2 'AppVolumes Application Count' {
                        $ApplicationCountPSObj = [PSCustomObject]@{
                            'AppVolumes Total Applications is' = $ApplicationCount
                        }
                    $ApplicationCountPSObj | Table -Name 'AppVolumes Application Count' -List -ColumnWidths 50,50
                    } # Close out section -Style Heading2 "AppVolumes Application Count"
                    
                    if ($InfoLevel.AppVolumes.Applications -ge 2) {
                        $ii = 1
                        foreach($Application in $Applications.applications) {
                            
                            $AppStackInstalled = $Application.snapvol
                            #$AppStackInstalledSplit = $AppStackInstalled.split("`n")|ForEach-Object{$_.split('>')[1]}|ForEach-Object{$_.split('<')[-2]}
                            $AppStackInstalledSplit = $AppStackInstalled.split("`n")
                            $AppStackInstalledSplit = $AppStackInstalled.split('>')[1]
                            $AppStackInstalledSplit = $AppStackInstalledSplit.split('<')[-2]

                            $AppName = $Application.Name
                            $AppVersion = $Application.version

                            if(($ii % 4) -eq 0){
                                PageBreak
                            }
                            $ii++

                            if(!$AppName)
                            section -Style Heading2 "AppVolumes Application $($Application.Name) Details" {
                                $ApplicationPSObj = [PSCustomObject]@{
                                    'AppVolumes Application Name' = $AppName
                                    'AppVolumes Application Version' = $Appversion
                                    'AppVolumes Application Publisher' = $Application.publisher
                                    'AppVolumes Application Assignments Count' = $Application.assignments_count
                                    'AppVolumes Application Date Created' = $Application.created_at_human
                                    'AppVolumes Application Icon Location' = $Application.icon
                                    'AppVolumes Application AppStack Installed On' = $AppStackInstalledSplit
                                    'AppVolumes Application Assignable' = $Application.assignable
                                } # Close Out $ApplicationPSObj = [PSCustomObject]
                            $ApplicationPSObj | Table -Name 'AppVolumes Application Information' -List -ColumnWidths 50,50
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
                PageBreak
                section -Style Heading1 'AppVolumes Active Directory User Information' {
                    if ($InfoLevel.AppVolumes.ADUsers -ge 1) {
                        foreach($ADUserCT in $ActiveDirectoryUsers) {
                            $ADUserCount++
                        } # Close out foreach($ADDomainCT in $ADUser)
                                        
                        section -Style Heading2 'AppVolumes Active Directory User Count' {
                            $ADUserCountPSObj = [PSCustomObject]@{
                                'AppVolumes Total Active Directory Users is' = $ADUserCount
                            } # Close out $ApplicationCountPSObj = [PSCustomObject]
                        $ADUserCountPSObj | Table -Name 'AppVolumes Active Directory User Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Active Directory User Count"
                    } # Close out if ($InfoLevel.AppVolumes.ADUsers -ge 1)
                    BlankLine
                    if ($InfoLevel.AppVolumes.ADUsers -ge 2) {
                        section -Style Heading2 'AppVolumes Active Directory User Details' {
                            foreach($ActiveDirectoryUser in $ActiveDirectoryUsers) {   
                                $ActiveDirectoryUserPSObj = [PSCustomObject]@{
                                    'AppVolumes User Name' = $ActiveDirectoryUser.upn
                                    'AppVolumes User Last Logon' = $ActiveDirectoryUser.last_login_human
                                    'AppVolumes User Status' = $ActiveDirectoryUser.status
                                    "AppVolumes User Writable" = $ActiveDirectoryUser.writables
                                    "AppVolumes User AppStack" = $ActiveDirectoryUser.appstacks
                                    "AppVolumes User Attachment's" = $ActiveDirectoryUser.attachments
                                    "AppVolumes User Login's" = $ActiveDirectoryUser.logins
                                    "-----------------------------------------------" = "-----------------------------------------------"
                                } # Close Out $ActiveDirectoryUserPSObj = [PSCustomObject]
                                $ActiveDirectoryUserPSObj | Table -Name 'AppVolumes Active Directory User Information' -list -ColumnWidths 50,50
                                
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
                PageBreak
                section -Style Heading1 'AppVolumes Active Directory Group Information' {
                    if ($InfoLevel.AppVolumes.ADGroups -ge 1) {
                        foreach($ADGroupCT in $ActiveDirectoryGroups.groups) {
                            $ADGroupCount++
                        } # Close out foreach($ADDomainCT in $ADGroup)
                                        
                        section -Style Heading2 'AppVolumes Active Directory Group Count' {
                            $ADGroupCountPSObj = [PSCustomObject]@{
                                'AppVolumes Total Active Directory Groups is' = $ADGroupCount
                            } # Close out $ADGroupCountPSObj = [PSCustomObject]
                        $ADGroupCountPSObj | Table -Name 'AppVolumes Active Directory Group Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Active Directory Group Count"
                    } # Close out if ($InfoLevel.AppVolumes.ADGroups -ge 1)

                    if ($InfoLevel.AppVolumes.ADGroups -ge 2) {
                        section -Style Heading2 'AppVolumes Active Directory Group Details' {
                            $ActiveDirectoryGroupPSObj = foreach($ActiveDirectoryGroup in $ActiveDirectoryGroups.groups) {   
                                [PSCustomObject]@{
                                    'AppVolumes Group Name' = $ActiveDirectoryGroup.name
                                    'AppVolumes Group Last Logon' = $ActiveDirectoryGroup.last_login_human
                                    'AppVolumes Group Status' = $ActiveDirectoryGroup.status
                                } # Close Out $ActiveDirectoryGroupPSObj = [PSCustomObject]   
                            } # Close out foreach($ActiveDirectoryGroup in $ActiveDirectoryGroups)
                            $ActiveDirectoryGroupPSObj | Table -Name 'AppVolumes Active Directory Group Information' -ColumnWidths 50,30,20
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
                PageBreak
                section -Style Heading1 'AppVolumes Datastores' {
                    
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

                    section -Style Heading2 "AppVolumes Datastore Overview Information" {
                        $AppVolumesDataStoreOverviewPSObj = [PSCustomObject]@{
                            'AppVolumes Datastore Datacenter' = $Datastores.Datacenter
                            'AppVolumes Datastore Writable Storage Location' = $DatastoreWritableStorage
                            'AppVolumes Datastore AppStack Storage Location' = $DatastoreAppStorage
                            'AppVolumes Datastore Writeable Backup Location' = $DatastoreAWriteableBackupRecurrentDatastore
                            'AppVolumes Datastore AppStack Path' = $Datastores.appstack_path
                            'AppVolumes Datastore Writeable Path' = $Datastores.writable_path
                            'AppVolumes Datastore Writeable Archive Path' = $Datastores.writable_archive_path
                            'AppVolumes Datastore Writeable Backup Recurrent Path' = $Datastores.writable_backup_recurrent_path
                            'AppVolumes Datastore AppStack Template Path' = $Datastores.appstack_template_path
                            'AppVolumes Datastore Writeable Template Path' = $Datastores.writable_template_path
                        } # Close out $AppVolumesDataStoreOverviewPSObj = [PSCustomObject]
                        $AppVolumesDataStoreOverviewPSObj | Table -Name 'AppVolumes Datastore Overview Information' -List -ColumnWidths 50,50
                    } # Close out section -Style Heading2 'AppVolumes Datastore Overview Information'

                    if ($InfoLevel.AppVolumes.StorageLocations -ge 1) {
                        foreach($StorageLocationCT in $Datastores.datastores) {
                            $StorageLocationCount++
                        } # Close out foreach($StorageLocationCT in $StorageLocations)
                                        
                        section -Style Heading2 'AppVolumes Datastore Count' {
                            $StorageLocationCountPSObj = [PSCustomObject]@{
                                'AppVolumes Total Datastores is' = $StorageLocationCount
                            } # Close out $ApplicationCountPSObj = [PSCustomObject]
                        $StorageLocationCountPSObj | Table -Name 'AppVolumes Datastore Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Datastore Count"
                    } # Close out if ($InfoLevel.AppVolumes.StorageLocations -ge 1)

                    if ($InfoLevel.AppVolumes.StorageLocations -ge 2) {
                        $ii = 0
                        foreach($DataStore in $Datastores.datastores) {
                            if(($ii % 3) -eq 0){
                                PageBreak
                            }
                            $ii++
                            section -Style Heading2 "AppVolumes Datastore $($DataStore.name) Details" {
                                $AppvolumesDataStorePSObj = [PSCustomObject]@{
                                    'AppVolumes Datastore Name' = $DataStore.name
                                    'AppVolumes Datastore Display Name' = $DataStore.display_Name
                                    'AppVolumes Datastore Category' = $DataStore.Catagory
                                    'AppVolumes Datastore Datacenter ' = $DataStore.datacenter
                                    'AppVolumes Datastore Notes' = $DataStore.note
                                    'AppVolumes Datastore Description' = $DataStore.description
                                    'AppVolumes Datastore Accessible' = $DataStore.accessible
                                    'AppVolumes Datastore Host' = $DataStore.host
                                    'AppVolumes Datastore Template Storage' = $DataStore.template_storage
                                    'AppVolumes Datastore Host Username' = $DataStore.host_username
                                    'AppVolumes Datastore Free Space' = $DataStore.free_space
                                    'AppVolumes Datastore Capacity' = $DataStore.capacity

                                } # Close Out $AppvolumesDataStorePSObj = [PSCustomObject]
                                $AppvolumesDataStorePSObj | Table -Name 'AppVolumes Datastore Details' -List -ColumnWidths 50,50
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
                PageBreak
                section -Style Heading1 'AppVolumes Storage Groups' {
                    
                    if ($InfoLevel.AppVolumes.StorageGroups -ge 1) {
                        foreach($StorageGroupCT in $StorageGroups.storage_groups) {
                            $StorageGroupCount++
                        } # Close out foreach($StorageGroupCT in $StorageGroups)
                                        
                        section -Style Heading2 'AppVolumes Storage Group Count' {
                            $StorageGroupCountPSObj = [PSCustomObject]@{
                                'AppVolumes Total Storage Groups is' = $StorageGroupCount
                            } # Close out $ApplicationCountPSObj = [PSCustomObject]
                        $StorageGroupCountPSObj | Table -Name 'AppVolumes Storage Group Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes StorageGroup Count"
                    } # Close out if ($InfoLevel.AppVolumes.StorageGroups -ge 1)

                    if ($InfoLevel.AppVolumes.StorageGroups -ge 2) {
                        $ii = 1
                        foreach($StorageGroup in $StorageGroups.storage_groups) {
                            if(($ii % 3) -eq 0){
                                PageBreak
                            }
                            $ii++
                            section -Style Heading2 "AppVolumes Storage Group $($StorageGroup.name) Details" {
                                $StorageGroupPSObj = [PSCustomObject]@{
                                    'AppVolumes Storage Group Name' = $StorageGroup.name
                                    'AppVolumes Storage Group Distribution Strategy' = $StorageGroup.strategy
                                    'AppVolumes Storage Group Template Storage' = $StorageGroup.template_storage
                                    'AppVolumes Storage Group Members Count' = $StorageGroup.members
                                    'AppVolumes Storage Group Member Name Prefix' = $StorageGroup.member_prefix
                                    'AppVolumes Storage Group Space Used' = $StorageGroup.space_used
                                    'AppVolumes Storage Group Total Space' = $StorageGroup.space_total
                                    'AppVolumes Storage Group Creation Date' = $StorageGroup.created_at_human
                                    'AppVolumes Storage Group Auto Import' = $StorageGroup.auto_import
                                    'AppVolumes Storage Group Auto Replicate' = $StorageGroup.auto_replicate
                                    'AppVolumes Storage Group Last Replicated Date' = $StorageGroup.replicated_at_human
                                    'AppVolumes Storage Group Last Imported Date' = $StorageGroup.imported_at_human
                                    'AppVolumes Storage Group Last Curated Date' = $StorageGroup.curated_at_human
                                } # Close Out $StorageGroupPSObj = [PSCustomObject]
                            $StorageGroupPSObj | Table -Name 'AppVolumes Storage Group Information' -List
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
                PageBreak
                section -Style Heading1 'AppVolumes Active Directory Domains Information' {
                        
                    if ($InfoLevel.AppVolumes.ADDomains -ge 1) {
                        foreach($ADDomainCT in $LDAPDomains.ldap_domains) {
                            $ADDomainCount++
                        } # Close out foreach($ADDomainCT in $ADDomains)
                                        
                        section -Style Heading2 'AppVolumes AD Domain Count' {
                            $ADDomainCountPSObj = [PSCustomObject]@{
                                'AppVolumes Total AD Domains is' = $ADDomainCount
                            } # Close out $ApplicationCountPSObj = [PSCustomObject]
                        $ADDomainCountPSObj | Table -Name 'AppVolumes AD Domain Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes AD Domain Count"
                    } # Close out if ($InfoLevel.AppVolumes.ADDomains -ge 1)

                    if ($InfoLevel.AppVolumes.ADDomains -ge 2) {
                        $ii = 1
                        foreach($LDAPDomain in $LDAPDomains.ldap_domains) {
                            if(($ii % 3) -eq 0){
                                PageBreak
                            }
                            $ii++
                            section -Style Heading2 "AppVolumes Active Directory Domain $($LDAPDomain.domain) Details" {
                                $LDAPDomainsPSObj = [PSCustomObject]@{
                                    'AppVolumes Active Directory Domain' = $LDAPDomain.domain
                                    'AppVolumes Active Directory Username' = $LDAPDomain.username
                                    'AppVolumes Active Directory Base' = $LDAPDomain.base
                                    'AppVolumes Active Directory NetBIOS' = $LDAPDomain.netbios
                                    'AppVolumes Active Directory LDAPS' = $LDAPDomain.ldaps
                                    'AppVolumes Active Directory LDAP_TLS' = $LDAPDomain.ldap_tls
                                    'AppVolumes Active Directory SSL Verify' = $LDAPDomain.ssl_verify
                                    'AppVolumes Active Directory Port' = $LDAPDomain.port
                                    'AppVolumes Active Directory Effective Port' = $LDAPDomain.effective_port
                                    'AppVolumes Active Directory Created At' = $LDAPDomain.created_at
                                    'AppVolumes Active Directory Updated At' = $LDAPDomain.updated_at
                                } # Close Out $LDAPDomainsPSObj = [PSCustomObject]
                            $LDAPDomainsPSObj | Table -Name 'AppVolumes Active Directory Domains Information' -List -ColumnWidths 50,50
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
                PageBreak
                section -Style Heading1 'AppVolumes Administrator Roles Information' {
                    
                    if ($InfoLevel.AppVolumes.AdminGroups -ge 1) {
                        foreach($AdminGroupCT in $AdminGroups.group_permissions) {
                            $AdminGroupCount++
                        } # Close out foreach($AdminGroupCT in $AdminGroup)
                                        
                        section -Style Heading2 'AppVolumes Admin Groups Count' {
                            $AdminGroupCountPSObj = [PSCustomObject]@{
                                'AppVolumes Total Admin Groups is' = $AdminGroupCount
                            } # Close out $AdminGroupPSObj = [PSCustomObject]
                        $AdminGroupCountPSObj | Table -Name 'AppVolumes Admin Groups Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Admin Groups Count"
                    } # Close out if ($InfoLevel.AppVolumes.AdminGroup -ge 1)
                    
                    if ($InfoLevel.AppVolumes.AdminGroups -ge 2) {
                        $ii = 1
                        foreach($AdminGroup in $AdminGroups.group_permissions) {
                            if(($ii % 5) -eq 0){
                                PageBreak
                            }
                            $ii++
                            section -Style Heading2 'AppVolumes Administrator Roles Details' {
                                $AdminGroupsPSObj = [PSCustomObject]@{
                                    'AppVolumes Administrator Role' = $AdminGroup.Role
                                    'AppVolumes Administrator Assignee UPN' = $AdminGroup.assignee_upn
                                    'AppVolumes Administrator Assignee Type' = $AdminGroup.assignee_type
                                    'AppVolumes Administrator Assignment Created at' = $AdminGroup.created_at
                                    'AppVolumes Administrator Assignment Updated at' = $AdminGroup.updated_at
                                } # Close Out $AdminGroupsPSObj = [PSCustomObject]
                            $AdminGroupsPSObj | Table -Name 'AppVolumes Administrators Roles Information' -List -ColumnWidths 50,50
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
                PageBreak
                section -Style Heading1 'AppVolumes Machine Manager Information' {
                    
                    if ($InfoLevel.AppVolumes.MachineManagers -ge 1) {
                        foreach($MachineManagerCT in $MachineManagers.machine_managers) {
                            $MachineManagerCount++
                        } # Close out foreach($ADDomainCT in $MachineManagers)
                                        
                        section -Style Heading2 'AppVolumes Machine Managers Count' {
                            $MachineManagerPSObj = [PSCustomObject]@{
                                'AppVolumes Total Machine Managers is' = $MachineManagerCount
                            } # Close out $MachineManagerPSObj = [PSCustomObject]
                        $MachineManagerPSObj | Table -Name 'AppVolumes Machine Managers Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Machine Managers Count"
                    } # Close out if ($InfoLevel.AppVolumes.MachineManagers -ge 1)

                    if ($InfoLevel.AppVolumes.MachineManagers -ge 2) {
                        $ii = 1
                        foreach($MachineManager in $MachineManagers.machine_managers) {
                            if(($ii % 6) -eq 0){
                                PageBreak
                            }
                            $ii++
                            section -Style Heading2 "AppVolumes Machine Manager $($MachineManager.Host) Details" {
                                $MachineManagerPSObj = [PSCustomObject]@{
                                    'AppVolumes Machine Manager Name' = $MachineManager.host
                                    'AppVolumes Machine Manager Username' = $MachineManager.Username
                                    'AppVolumes Machine Manager Adapter Type' = $MachineManager.adapter_type
                                    'AppVolumes Machine Manager Type' = $MachineManager.type
                                    'AppVolumes Machine Manager Supports Multi' = $MachineManager.supports_multi
                                } # Close Out $MachineManagerPSObj = [PSCustomObject]
                            $MachineManagerPSObj | Table -Name 'AppVolumes Machine Manager Information' -List -ColumnWidths 50,50
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
                PageBreak
                section -Style Heading1 'AppVolumes Storage Information' {
                    
                    if ($InfoLevel.AppVolumes.Storage -ge 1) {
                        foreach($StrorageCT in $Storages.Storages) {
                            $StorageCount++
                        } # Close out foreach($StorageCT in $Storage)
                                        
                        section -Style Heading2 'AppVolumes Storage Count' {
                            $StorageCountPSObj = [PSCustomObject]@{
                                'AppVolumes Total Storage is' = $StorageCount
                            } # Close out $StorageCountPSObj = [PSCustomObject]
                        $StorageCountPSObj | Table -Name 'AppVolumes Storage Count' -List -ColumnWidths 50,50
                        } # Close out section -Style Heading2 "AppVolumes Storage Count"
                    } # Close out if ($InfoLevel.AppVolumes.Storage -ge 1)

                    if ($InfoLevel.AppVolumes.Storage -ge 2) {
                        $ii = 1
                        foreach($Storage in $Storages.Storages) {
                            
                            if(($ii % 4) -eq 0){
                                PageBreak
                            }
                            $ii++
                            
                            section -Style Heading2 "AppVolumes Storage $($Storage.Name) Details" {
                                $StoragePSObj = [PSCustomObject]@{
                                    'AppVolumes Storage Name' = $Storage.Name
                                    'AppVolumes Storage Host' = $Storage.host
                                    'AppVolumes Storage Space Users' = $Storage.space_used
                                    'AppVolumes Storage Space Total' = $Storage.space_total
                                    "AppVolumes Number of AppStack's" = $Storage.num_appstacks
                                    "AppVolumes Number of Writable's" = $Storage.num_writables
                                    'AppVolumes Storage Attachable' = $Storage.attachable
                                    'AppVolumes Storage Created Date' = $Storage.created_at_human
                                    'AppVolumes Storage Status' = $Storage.status
                                } # Close Out $StoragePSObj = [PSCustomObject]
                            $StoragePSObj | Table -Name 'AppVolumes Storage Information' -List -ColumnWidths 50,50
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
                PageBreak
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
                            'AppVolumes Settings UI Session Timeout' = $UISessionTimeout
                            'AppVolumes Settings Non-Domain Entities' = $NonDomainEntities
                            'AppVolumes Settings Writeable Volumes Regular Backups' = $RegularBackups
                            'AppVolumes Settings Writeable Volumes Regular Backups Interval' = $RegularBackupsInterval
                            'AppVolumes Settings Writeable Volumes Storage Location' = $DatastoreBackupName
                            'AppVolumes Settings Writeable Volumes Storage Path' = $StoragePath
                            'AppVolumes Settings Disable Volume Cache' = $DisableSnapVolumeCache
                            'AppVolumes Settings Disable Token AD Query' = $DisableTokenADQuery
                        } # Close Out $SettingsPSObj = [PSCustomObject]
                        $SettingsPSObj | Table -Name 'AppVolumes Settings Information' -List -ColumnWidths 50,50
                    } # Close out section -Style Heading2 'AppVolumes Settings Details'
                } # Close out section -Style Heading2 'AppVolumes Settings Information'
            } # Close out if ($InfoLevel.AppVolumes.Settings -ge 1)
        } # Close out if ($Settings)
    } # Close out foreach ($AppStacks in $Target)
} # Close out function Invoke-AsBuiltReport.VMware.AppVolumes