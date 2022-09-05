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
                $AppStacks = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products"
                if ($AppStacks) {
                    section -Style Heading2 'AppStacks Summary' {
                        $OutObj = @()
                        foreach ($AppStack in $AppStacks.data) {
                            try {
                                $AppStackID = $AppStack.id
                                $AppStackIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/app_packages?include=app_markers"
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
                            section -Style Heading3 "AppStacks Details" {
                                foreach ($AppStack in $AppStacks.data) {
                                    try {
                                        $AppStackID = $appstack.id
                                        $AppStackIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/app_packages?include=app_markers"
                                        $AppStackPackage =  $AppStackIDSource.data | Where-Object {$_.app_markers.name -eq 'CURRENT'}
                                        if ($AppStackPackage) {
                                            section -Style Heading4 "$($AppStack.Name)" {
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
                                                        section -ExcludeFromTOC -Style Heading5 "Packages" {
                                                            $OutObj = @()
                                                            foreach ($Package in $AppStackPackages) {
                                                                $inObj = [ordered] @{
                                                                    'Name' = $Package.Name
                                                                    'Version' = $Package.Version
                                                                    'Created' = $Package.created_at.Split()[0]
                                                                    'Mounted' = Switch ($Package.mounted_at) {
                                                                        $Null {'--'}
                                                                        default {$Package.mounted_at.ToString('yyyy-mm-dd')}
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
                                                                $AppStackPrograms = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$AppStackPackage/programs"
                                                                if ($AppStackPrograms) {
                                                                    section -ExcludeFromTOC -Style Heading6 "Programs" {
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
                                                    $AppStackAssignments = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/assignments?include=entities"
                                                    if ($AppStackAssignments) {
                                                        section -ExcludeFromTOC -Style Heading5 "Assignment" {
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