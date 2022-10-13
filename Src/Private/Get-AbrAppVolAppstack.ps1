function Get-AbrAPPVolAppstack {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Appstack information.
    .DESCRIPTION
        Documents the configuration of VMware APPVolume in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.2.0
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
        Write-PScriboMessage "AppStacks InfoLevel set at $($InfoLevel.AppVolumes.AppStacks)."
        Write-PscriboMessage "Collecting AppStacks information."
    }

    process {
        if ($InfoLevel.AppVolumes.AppStacks -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $AppStacks = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products"
                } else {$AppStacks = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products"}

                if ($AppStacks) {
                    section -Style Heading3 'AppStacks Summary' {
                        Paragraph "The following section provide a summary of the AppStacks components on $($AppVolServer.split('.')[0])."
                        Blankline
                        $OutObj = @()
                        foreach ($AppStack in $AppStacks.data) {
                            try {
                                $AppStackID = $AppStack.id

                                if ($PSVersionTable.PSEdition -eq 'Core') {
                                    $AppStackIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/app_packages?include=app_markers"
                                } else {$AppStackIDSource = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/app_packages?include=app_markers"}

                                $AppStackPackage =  $AppStackIDSource.data | Where-Object {$_.app_markers.name -eq 'CURRENT'}

                                $inObj = [ordered] @{
                                    'Name' = $AppStack.Name
                                    'Status' = $AppStack.Status
                                    'Created' = $AppStack.created_At_Human
                                    'Template Version' = $AppStackPackage.template_version
                                    'Agent Version' = $AppStackPackage.agent_version
                                    'Applications Count' = $AppStackPackage.programs_count
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                        $TableParams = @{
                            Name = "AppStacks - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 25, 15, 15, 15, 15, 15
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name | Table @TableParams
                        if ($InfoLevel.AppVolumes.AppStacks -ge 2) {
                            section -Style Heading4 "AppStacks Details" {
                                Paragraph "The following section details AppStacks configuration information on $($AppVolServer.split('.')[0])."
                                Blankline
                                foreach ($AppStack in $AppStacks.data | Sort-Object -Property Name) {
                                    try {
                                        $AppStackID = $appstack.id

                                        if ($PSVersionTable.PSEdition -eq 'Core') {
                                            $AppStackIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/app_packages?include=app_markers"
                                        } else {$AppStackIDSource = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/app_packages?include=app_markers"}

                                        $AppStackPackage =  $AppStackIDSource.data | Where-Object {$_.app_markers.name -eq 'CURRENT'}
                                        if ($AppStackPackage) {
                                            section -Style Heading5 "$($AppStack.Name)" {
                                                $OutObj = @()
                                                $inObj = [ordered] @{
                                                    'Name' = $AppStack.Name
                                                    'Path' = $AppStackPackage.Path
                                                    'Datastore Name' = $AppStackPackage.datastore_Name
                                                    'Status' = $AppStackPackage.Status
                                                    'Created' = $AppStackPackage.created_At_Human
                                                    'Mounted' = $AppStackPackage.mounted_at
                                                    'Size' = $AppStackPackage.size_human
                                                    'Total Assignments' = $AppStackPackage.assignment_count
                                                    'Attachments Total' = $AppStackPackage.attachment_count
                                                    'Attachment Limit' = $AppStackPackage.attachment_limit
                                                    'Description' = $AppStackPackage.description
                                                    'Applications Count' = $AppStackPackage.programs_count
                                                    'Agent Version' = $AppStackPackage.agent_version
                                                    'Package Agent Version' = $AppStackPackage.capture_version
                                                    'OS Version' = $AppStackPackage.primordial_os_name
                                                    'Provisioning Duration' = $AppStackPackage.provision_duration
                                                }
                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                $TableParams = @{
                                                    Name = "AppStack Details - $($AppStack.Name)"
                                                    List = $true
                                                    ColumnWidths = 50, 50
                                                }
                                                if ($Report.ShowTableCaptions) {
                                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                                }
                                                $OutObj | Table @TableParams
                                                try {
                                                    $AppStackPackages =  $AppStackIDSource.data
                                                    if ($AppStackPackage) {
                                                        section -ExcludeFromTOC -Style NOTOCHeading6 "Packages" {
                                                            $OutObj = @()
                                                            foreach ($Package in $AppStackPackages) {
                                                                $inObj = [ordered] @{
                                                                    'Name' = $Package.Name
                                                                    'Version' = $Package.Version
                                                                    'Created' = Switch ($Package.created_at) {
                                                                        $Null {'--'}
                                                                        default {([DateTime]$Package.created_at).ToShortDateString()}
                                                                    }
                                                                    'Mounted' = Switch ($Package.mounted_at) {
                                                                        $Null {'--'}
                                                                        default {([DateTime]$Package.mounted_at).ToShortDateString()}
                                                                    }
                                                                    'Size' = $Package.size_human
                                                                    'Current' = Switch ($Package.app_markers.name) {
                                                                        $null {'No'}
                                                                        'CURRENT' {'Yes'}
                                                                        default {'--'}
                                                                    }
                                                                }
                                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                            }

                                                            $TableParams = @{
                                                                Name = "Packages - $($AppStack.Name)"
                                                                List = $false
                                                                ColumnWidths = 25, 15, 15, 15, 15, 15
                                                            }
                                                            if ($Report.ShowTableCaptions) {
                                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                                            }
                                                            $OutObj | Sort-Object -Property 'Version' -Descending | Table @TableParams
                                                            try {
                                                                $AppStackPackage =  ($AppStackIDSource.data | Where-Object {$_.app_markers.name -eq 'CURRENT'}).id

                                                                if ($PSVersionTable.PSEdition -eq 'Core') {
                                                                    $AppStackPrograms = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$AppStackPackage/programs"
                                                                } else {$AppStackPrograms = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$AppStackPackage/programs"}

                                                                if ($AppStackPrograms) {
                                                                    section -ExcludeFromTOC -Style NOTOCHeading6 "Programs" {
                                                                        $OutObj = @()
                                                                        foreach ($Program in $AppStackPrograms.data) {
                                                                            $inObj = [ordered] @{
                                                                                'Name' = $Program.Name
                                                                                'Version' = $Program.Version
                                                                                'Created' = $Program.created_At_Human
                                                                            }
                                                                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                        }

                                                                        $TableParams = @{
                                                                            Name = "Programs - $($AppStack.Name)"
                                                                            List = $false
                                                                            ColumnWidths = 50, 30, 20
                                                                        }
                                                                        if ($Report.ShowTableCaptions) {
                                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                                        }
                                                                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                                                    }
                                                                }
                                                            } catch {
                                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                                            }
                                                        }
                                                    }
                                                } catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {
                                                    $AppStackID = $appstack.id

                                                    if ($PSVersionTable.PSEdition -eq 'Core') {
                                                        $AppStackAssignments = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/assignments?include=entities"
                                                    } else {$AppStackAssignments = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/assignments?include=entities"}

                                                    if ($AppStackAssignments) {
                                                        section -ExcludeFromTOC -Style NOTOCHeading6 "Assignment" {
                                                            $OutObj = @()
                                                            foreach ($AppStackAssignment in $AppStackAssignments.data) {
                                                                try {
                                                                    $inObj = [ordered] @{
                                                                        'Name' = $AppStackAssignment.entities.upn
                                                                        'Type' = $AppStackAssignment.entities.entity_type
                                                                    }
                                                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                }
                                                                catch {
                                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                                }
                                                            }

                                                            $TableParams = @{
                                                                Name = "Assignment - $($AppStack.Name)"
                                                                List = $false
                                                                ColumnWidths = 50, 50
                                                            }
                                                            if ($Report.ShowTableCaptions) {
                                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                                            }
                                                            $OutObj | Sort-Object -Property 'Name' |  Table @TableParams
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