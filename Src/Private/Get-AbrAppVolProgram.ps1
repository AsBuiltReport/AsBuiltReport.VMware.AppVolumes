function Get-AbrAppVolProgram {
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
        Write-PScriboMessage "Programs InfoLevel set at $($InfoLevel.AppVolumes.Programs)."
        Write-PscriboMessage "Collecting Programs information."
    }

    process {
        if ($InfoLevel.AppVolumes.Packages -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $ProgramsAll = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_programs"
                } else {$ProgramsAll = Invoke-RestMethod -WebSession $SourceServerSession -Method get -Uri "https://$AppVolServer/app_volumes/app_programs"}

                if ($ProgramsAll) {
                    section -Style Heading3 'Programs Summary' {
                        Paragraph "The following section provide a summary of the programs on $($AppVolServer.split('.')[0])."
                        Blankline
                        $OutObj = @()
                        foreach ($PA in $ProgramsAll.data) {
                            try {
                                $inObj = [ordered] @{
                                    'App Name' = $PA.Name
                                    'Version #' = $PA.version
                                    'Publisher Name' = $PA.publisher
                                    'Package Name' = $PA.app_package.name
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                        $TableParams = @{
                            Name = "Programs - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 25, 25, 25, 25
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name | Table @TableParams
                        if ($InfoLevel.AppVolumes.Programs -ge 2) {
                            section -Style Heading4 "Program Details" {
                                foreach ($PA in $ProgramsAll.data | Sort-Object -Property Name) {
                                    try {
                                        if ($PA) {
                                            section -Style Heading5 "Program Details - $($PA.Name)" {
                                                $OutObj = @()
                                                $inObj = [ordered] @{
                                                    'Name' = $PA.Name
                                                    'Package' = $PA.app_package.name
                                                    'Publisher' = $PA.publisher
                                                    'Install Location' = $PA.install_location
                                                    'Version Number' = $PA.version
                                                    'Created' = $PA.created_At_Human
                                                    'Updated' = $PA.Updated_At_Human
                                                    'Icon' = $PA.icon
                                                }
                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                $TableParams = @{
                                                    Name = "Program Details - $($PA.Name)"
                                                    List = $true
                                                    ColumnWidths = 30, 70
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