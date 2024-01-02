function Get-AbrAppVolPackage {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Appstack information.
    .DESCRIPTION
        Documents the configuration of VMware APPVolume in Word/HTML/Text formats using PScribo.
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
    )

    begin {
        Write-PScriboMessage "Packages InfoLevel set at $($InfoLevel.AppVolumes.Packages)."
        Write-PscriboMessage "Collecting Packages information."
    }

    process {
        if ($InfoLevel.AppVolumes.Packages -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $AppPackages = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages?include=app_markers%2Clifecycle_stage%2Cbase_app_package%2Capp_product"
                } else {$AppPackages = Invoke-RestMethod -WebSession $SourceServerSession -Method get -Uri "https://$AppVolServer/app_volumes/app_packages?include=app_markers%2Clifecycle_stage%2Cbase_app_package%2Capp_product"}

                if ($AppPackages.data) {
                    section -Style Heading3 'Packages Summary' {
                        Paragraph "The following section provide a summary of the packages on $($AppVolServer.split('.')[0])."
                        Blankline
                        $OutObj = @()
                        foreach ($AppPackage in $AppPackages.data) {
                            try {
                                $AppPackageID = $AppPackage.id

                                $inObj = [ordered] @{
                                    'Name' = $AppPackage.Name
                                    'Application' = $AppPackage.app_product.name
                                    'Stage' = $AppPackage.lifecycle_stage.name
                                    'Status' = $AppPackage.status
                                    'Version' = $AppPackage.version
                                    'Size' = $AppPackage.size_human
                                    'Added' = $AppPackage.added_at_human
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                        $TableParams = @{
                            Name = "Packages - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 20, 15, 15, 10, 15, 15, 10
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name | Table @TableParams
                        #>
                        if ($InfoLevel.AppVolumes.Packages -ge 2) {
                            section -Style Heading4 "Packages Details" {
                                foreach ($AppPackage in $AppPackages.data | Sort-Object -Property Name) {
                                    try {
                                        if ($AppPackage) {
                                            section -Style Heading5 "Package - $($AppPackage.Name)" {
                                                $OutObj = @()
                                                $inObj = [ordered] @{
                                                    'App Name' = $AppPackage.Name
                                                    'Application Name' = $AppPackage.app_product.name
                                                    'Version #' = $AppPackage.version
                                                    'Current Status' = $AppPackage.status
                                                    'Life Cycle Stage' = $AppPackage.lifecycle_stage.name
                                                    'Delivery' = $AppPackage.delivery
                                                    'Total Attachments' = $AppPackage.Total_Use_Count
                                                    'File Name' = $AppPackage.filename
                                                    'Format' = $AppPackage.format
                                                    'Template' = $AppPackage.template_file_name
                                                    'Agent Version' = $AppPackage.agent_version
                                                    'Base Package' = $AppPackage.base_app_package.name
                                                    'Date Added' = $AppPackage.created_At_Human
                                                    'Modified' = $AppPackage.updated_at_human
                                                    'Description' = $AppPackage.description
                                                    'Note' = $AppPackage.note
                                                    'Programs Count' = $AppPackage.programs_count
                                                    'Operating Systems Count' = $AppPackage.operating_systems_count
                                                    'Package Size' = $AppPackage.size_human
                                                    'On-Demand Capable' = $AppPackage.capable_of_on_demand
                                                    'Attachment Limit' = $AppPackage.attachment_limit
                                                    'Path' = $AppPackage.Path
                                                    'Datastore Name' = $AppPackage.datastore_Name
                                                    'OS Version' = $AppPackage.primordial_os_name
                                                    'Provisioning Duration' = $AppPackage.provision_duration
                                                    'Is Current' = $AppPackage.app_markers.name
                                                }
                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                $TableParams = @{
                                                    Name = "Package Details - $($AppPackage.Name)"
                                                    List = $true
                                                    ColumnWidths = 30, 70
                                                }
                                                if ($Report.ShowTableCaptions) {
                                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                                }
                                                $OutObj | Table @TableParams
                                                try {
                                                    if ($PSVersionTable.PSEdition -eq 'Core') {
                                                        $Programs = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($AppPackage.id)/programs"
                                                    } else {$Programs = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($AppPackage.id)/programs"}
                                                    Write-PscriboMessage "Working on Programs for $($AppPackage.Name)."
                                                    if ($Programs.data) {
                                                        section -ExcludeFromTOC -Style NOTOCHeading6 "Programs" {
                                                            $OutObj = @()
                                                            foreach ($Program in $Programs.data) {
                                                                if($Program) {
                                                                    Write-PscriboMessage "Gathering on Program info for $($Program.name)."
                                                                    $inObj = [ordered] @{
                                                                        'Program Name' = $Program.name
                                                                        'Build #' = $Program.version
                                                                        'Publisher Name' = $Program.publisher
                                                                        'Program Created' = Switch ($Program.created_At_Human) {
                                                                            $Null {'--'}
                                                                            default {$Program.created_At_Human}
                                                                        }
                                                                        'Program Updated' = Switch ($Program.Updated_At_Human) {
                                                                            $Null {'--'}
                                                                            default {$Program.Updated_At_Human}
                                                                        }
                                                                    }
                                                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                }
                                                            }

                                                            $TableParams = @{
                                                                Name = "Programs for Application - $($AppPackage.Name)"
                                                                List = $false
                                                                ColumnWidths = 25, 10, 25, 20, 20
                                                            }
                                                            if ($Report.ShowTableCaptions) {
                                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                                            }
                                                            $OutObj | Sort-Object -Property 'Program Name' -Descending | Table @TableParams
                                                        }
                                                    }
                                                } catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {

                                                    if ($PSVersionTable.PSEdition -eq 'Core') {
                                                        $OperatingSystems = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($AppPackage.id)/operating_systems"
                                                    } else {$OperatingSystems = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($AppPackage.id)/operating_systems"}
                                                    if ($OperatingSystems.data) {
                                                        section -ExcludeFromTOC -Style NOTOCHeading6 "Operating Systems" {
                                                            $OutObj = @()
                                                            foreach ($OS in $OperatingSystems.data) {
                                                                if($OS){
                                                                    $inObj = [ordered] @{
                                                                        'OS Name' = $OS.Name
                                                                        'OS Version' = $($($OS.major_version)+'.'+$($OS.minor_version))
                                                                        'Processor Arch' = $OS.proc_arch
                                                                        'Type' = $OS.product_type_human
                                                                    }
                                                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                }
                                                            }

                                                            $TableParams = @{
                                                                Name = "Operating Systems for - $($AppStack.Name)"
                                                                List = $false
                                                                ColumnWidths = 30, 30, 20, 20
                                                            }
                                                            if ($Report.ShowTableCaptions) {
                                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                                            }
                                                            $OutObj | Sort-Object -Property 'OS Name' | Table @TableParams
                                                        }
                                                    }
                                                } catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {
                                                    if ($PSVersionTable.PSEdition -eq 'Core') {
                                                        $StorageLocations = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($AppPackage.id)/files?"
                                                    } else {$StorageLocations = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($AppPackage.id)/files?"}

                                                    if ($StorageLocations.data) {
                                                        section -ExcludeFromTOC -Style NOTOCHeading6 "Storage Locations for - $($AppPackage.Name)" {
                                                            $OutObj = @()
                                                            foreach ($StorageLocation in $StorageLocations.data) {
                                                                try {
                                                                    $inObj = [ordered] @{
                                                                        'Location' = $StorageLocation.storage_location
                                                                        'Path' = $StorageLocation.path
                                                                        'Host' = $StorageLocation.machine_manager_host
                                                                        'File Status' = $StorageLocation.reachable
                                                                        'Created' = $StorageLocation.created_At_Human
                                                                    }
                                                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                }
                                                                catch {
                                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                                }
                                                            }

                                                            $TableParams = @{
                                                                Name = "Storage Location for - $($AppPackage.Name)"
                                                                List = $false
                                                                ColumnWidths = 20, 30, 20, 15, 15
                                                            }
                                                            if ($Report.ShowTableCaptions) {
                                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                                            }
                                                            $OutObj | Sort-Object -Property 'Location' |  Table @TableParams
                                                        }
                                                    }
                                                }  catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {
                                                    if ($PSVersionTable.PSEdition -eq 'Core') {
                                                        $AppLinks = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($AppPackage.id)/app_links?"
                                                    } else {$AppLinks = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($AppPackage.id)/app_links?"}

                                                    if ($AppLinks.data) {
                                                        section -ExcludeFromTOC -Style NOTOCHeading6 "Application links for - $($AppPackage.Name)" {
                                                            $OutObj = @()
                                                            foreach ($AppLink in $AppLinks.data) {
                                                                If($AppLink){
                                                                    if($AppLink.name){
                                                                        $ApplinkName = $AppLink.name
                                                                    }else{
                                                                        $ApplinkName = '--'
                                                                    }
                                                                    if($AppLink.entry_point){
                                                                        $ApplinkEntryPoint = $AppLink.entry_point
                                                                    }else{
                                                                        $ApplinkEntryPoint = '--'
                                                                    }

                                                                    try {
                                                                        $inObj = [ordered] @{
                                                                            'App Link Name' = $ApplinkName
                                                                            'Entry Point' = $ApplinkEntryPoint
                                                                        }
                                                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                    }
                                                                    catch {
                                                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                                                    }
                                                                }
                                                            }

                                                            $TableParams += @{
                                                                Name = "Application links for - $($AppPackage.Name)"
                                                                List = $false
                                                                ColumnWidths = 20, 80
                                                            }
                                                            if ($Report.ShowTableCaptions) {
                                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                                            }
                                                            $OutObj | Sort-Object -Property 'App Link Name' |  Table @TableParams
                                                        }
                                                    }
                                                }  catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }
                                        }
                                    }catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}