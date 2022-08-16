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
                                $AppStackID = $appstack.id
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
                                $OutObj += [pscustomobject]$inobj

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
                        $OutObj | Table @TableParams
                        if ($InfoLevel.AppVolumes.AppStacks -ge 2) {
                            foreach ($AppStack in $AppStacks.data) {
                                try {
                                    section -Style Heading3 "$($AppStack.Name) Details" {
                                        $OutObj = @()
                                        $AppStackID = $appstack.id
                                        $AppStackIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/app_packages?include=app_markers" 
                                        $AppStackPackage =  $AppStackIDSource.data | Where-Object {$_.app_markers.name -eq 'CURRENT'} 
                                        
                                        $inObj = [ordered] @{
                                            'Name' = $AppStack.Name
                                            'Path' = $AppStackPackage.Path
                                            'Datastore Name' = $AppStackPackage.datastore_Name
                                            'Status' = $AppStackPackage.Status
                                            'Created' = $AppStackPackage.created_At_Human
                                            'Mounted' = $AppStackPackage.mounted_at
                                            'Size' = $AppStackPackage.size_human
                                            'Total Assignments' = $AppStackPackage.assignments_Total
                                            'Attachments Total' = $AppStackPackage.attachments_Total
                                            'Attachment Limit' = $AppStackPackage.attachment_limit
                                            'Description' = $AppStackPackage.description
                                            'Applications Count' = $AppStackPackage.application_count
                                            'Agent Version' = $AppStackPackage.agent_version
                                            'Package Agent Version' = $AppStackPackage.capture_version
                                            'OS Version' = $AppStackPackage.primordial_os_name
                                            'Provisioning Duration' = $AppStackPackage.provision_duration
                                        }
                                        $OutObj = [pscustomobject]$inobj

                                        $TableParams = @{
                                            Name = "AppStack - $($AppStack.Name)"
                                            List = $true
                                            ColumnWidths = 50, 50
                                        }
                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Table @TableParams
                                        section -Style Heading4 "Assignment" {
                                            $OutObj = @()
                                            $AppStackID = $appstack.id
                                            $AppStackAssignments = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$AppStackID/assignments?include=entities"

                                            foreach ($AppStackAssignment in $AppStackAssignments.data) {
                                                try {                                                    
                                                    $inObj = [ordered] @{
                                                        'Name' = $AppStackAssignment.entities.upn
                                                        'Type' = $AppStackAssignment.entities.entity_type
                                                    }
                                                    $OutObj += [pscustomobject]$inobj
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
                                            $OutObj | Table @TableParams
                                        }
                                    }
                                }
                                catch {
                                    Write-PscriboMessage -IsWarning $_.Exception.Message
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