function Get-AbrAppVolComputer {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory users information.
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
        Write-PScriboMessage "Managed Computers InfoLevel set at $($InfoLevel.AppVolumes.Computers)."
        Write-PscriboMessage "Collecting Managed Computers information."
    }

    process {
        if ($InfoLevel.AppVolumes.Computers -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Computers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/computers?deleted=hide&"
                } else {$Computers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/computers?deleted=hide&"}

                if ($Computers) {
                    section -Style Heading3 "Managed Computers" {
                        Paragraph "The following section provide a summary of computers with app volumes agent installed and registered to $($AppVolServer.split('.')[0])."
                        Blankline
                        $OutObj = @()
                        foreach ($Computer in $Computers) {
                            try {
                                $inObj = [ordered] @{
                                    'Computer' = $Computer.name
                                    'Agent' = $Computer.agent_version
                                    'OS' = $Computer.OS
                                    'Writables' = $Computer.writables
                                    'Assignments' = $Computer.application_assignment_count
                                    'Attachments' = $Computer.attachments
                                    'Boots' = $Computer.logins
                                    'Last Boot' = $Computer.last_login_human
                                    'Status' = $Computer.Status
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Managed Computers - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 20, 14, 11, 7, 8, 8, 7, 15, 10
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj| Sort-Object -Property upn | Table @TableParams
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