function Get-AbrAppVolAssignment {
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
        Write-PScriboMessage "Assignment InfoLevel set at $($InfoLevel.AppVolumes.Assignments)."
        Write-PscriboMessage "Collecting Assignment information."
    }

    process {
        if ($InfoLevel.AppVolumes.Assignments -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $AssignmentsAll = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_assignments?include=entities,filters,app_package,app_marker&"
                } else {$AssignmentsAll = Invoke-RestMethod -WebSession $SourceServerSession -Method get -Uri "https://$AppVolServer/app_volumes/app_assignments?include=entities,filters,app_package,app_marker&"}

                if ($AssignmentsAll) {
                    section -Style Heading3 'Assignments Summary' {
                        Paragraph "The following section provide a summary of the assignments on $($AppVolServer.split('.')[0])."
                        Blankline
                        $OutObj = @()
                        foreach ($AA in $AssignmentsAll.data | Sort-Object -Property Name) {
                            if($aa.app_marker){
                                $Programs = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($aa.app_marker.app_package.id)/programs?"
                                $JoinedNames = ($Programs.data | ForEach-Object { $_.Name }) -join ', '
                            }elseif ($aa.app_package) {
                                $Programs = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$($aa.app_package.id)/programs?"
                                $JoinedNames = ($Programs.data | ForEach-Object { $_.Name }) -join ', '
                            }

                            # Filter Value
                            If(!([string]::IsNullOrWhitespace($AA.Filters.value))){
                                $filters = $AA.Filters.value
                            }
                            else{
                                $filters = 'All'
                            }

                            #App Marker Value
                            If([string]::IsNullOrWhitespace($AA.app_marker_name)){
                                $AppMarkerName = 'Package'
                            }
                            else{
                                $AppMarkerName = $AA.app_marker_name
                            }

                            try {
                                $inObj = [ordered] @{
                                    'Entity' = $aa.entities.upn
                                    'Marker' = $AppMarkerName
                                    'Package' = $aa.app_package_name
                                    'Applications' = $JoinedNames
                                    'Computers' = $filters
                                    'Assigned' = $aa.created_At_Human
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                        $TableParams = @{
                            Name = "Assignment Summary - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 20, 13, 20, 23, 12, 12
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name | Table @TableParams
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