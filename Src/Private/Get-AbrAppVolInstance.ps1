function Get-AbrAppVolInstance {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory OU information.
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
        Write-PScriboMessage "Instance InfoLevel set at $($InfoLevel.AppVolumes.Instances)."
        Write-PscriboMessage "Collecting Instance information."
    }

    process {
        if ($InfoLevel.AppVolumes.Instances -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Instances = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/manager_instances/related?api_version=4050"
                } else {$Instances = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/manager_instances/related?api_version=4050"}

                if ($Instances) {
                    section -Style Heading3 "App Volumes Instances" {
                        Paragraph "The following section provide a summary of App Volumes Instances for $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($Instance in $Instances.data) {

                            # Calculate Sync Count
                            $SyncCount = [int]$Instance.attributes.application_sync_count + [int]$Instance.attributes.package_sync_count + [int]$Instance.attributes.assignment_sync_count + [int]$Instance.attributes.marker_sync_count

                            # Determine Instance Type
                            If($Instance.attributes.is_source -eq 'True'){
                                $InstanceType = 'Source'
                            }
                            else{
                                $InstanceType = 'Target'
                            }

                            try {
                                $inObj = [ordered] @{
                                    'Name' = $Instance.attributes.Name
                                    'Host' = $Instance.attributes.Host
                                    'Type' = $InstanceType
                                    'Status' = $Instance.attributes.Status
                                    'Sync Count' = ($SyncCount).ToString()
                                    'Last Sync' = $Instance.attributes.synchronized_at_human
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "App Volumes Instances - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 20, 29, 12, 12, 12, 15
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj| Sort-Object -Property Name | Table @TableParams

                        if ($InfoLevel.AppVolumes.Instances -ge 2) {
                            #section -Style Heading4 "App Volumes Instance Details" {
                                foreach ($Instance in $Instances.data) {
                                    try {
                                        if ($Instance) {
                                            section -Style Heading5 "Instance Details - $($Instance.attributes.Name)" {
                                                $OutObj = @()
                                                $inObj = [ordered] @{
                                                    'App Volumes Server Name' = $Instance.attributes.Name
                                                    'Current Status' = $Instance.attributes.Status
                                                    'FQDN' = $Instance.attributes.Host
                                                    'Last Synchronized' = $Instance.attributes.synchronized_at_human
                                                    'Synchronized Applications' = $Instance.attributes.application_sync_count
                                                    'Synchronized Packages' = $Instance.attributes.package_sync_count
                                                    'Synchronized Markers' = $Instance.attributes.marker_sync_count
                                                    'Synchronized Assignments' = $Instance.attributes.assignment_sync_count
                                                    'Application Package Import' = $Instance.attributes.sync_application_import
                                                    'Package Symmetry Assurance' = $Instance.attributes.package_symmetry_assurance
                                                    'Sync Markers' = $Instance.attributes.sync_markers
                                                    'Sync Assignments' = $Instance.attributes.sync_assignments
                                                }
                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                $TableParams = @{
                                                    Name = "Instance Details - $($Instance.attributes.Name)"
                                                    List = $true
                                                    ColumnWidths = 50, 50
                                                }
                                                if ($Report.ShowTableCaptions) {
                                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                                }
                                                $OutObj | Table @TableParams
                                            }

                                        }
                                    }catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                            #}
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