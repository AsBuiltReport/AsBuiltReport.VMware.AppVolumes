function Get-AbrAppVolADDomain {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume AD Domain information.
    .DESCRIPTION
        Documents the configuration of VMware APPVolume in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        1.2.0
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
        Write-PScriboMessage "ADDomains InfoLevel set at $($InfoLevel.AppVolumes.ADDomains)."
        Write-PScriboMessage "Collecting Active Directory Domain information."
    }

    process {
        if ($InfoLevel.AppVolumes.ADDomains -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $LDAPDomains = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/ldap_domains"
                } else { $LDAPDomains = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/ldap_domains" }
                if ($LDAPDomains) {
                    Section -Style Heading3 "Active Directory Domain" {
                        Paragraph "The following section details active directory doamins are used for authentication on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($LDAPDomain in $LDAPDomains.ldap_domains | Sort-Object -Property Domain) {

                            If ($LDAPDomain.ldaps -like 'True') {
                                $Security = 'LADPS'
                            } elseif ($LDAPDomain.ldaps -like 'False' -and $LDAPDomain.ldap_tls -like 'False') {
                                $Security = 'LADP'
                            } elseif ($LDAPDomain.ldap_tls -like 'True') {
                                $Security = 'LADPS over TLS'
                            }
                            Section -Style Heading4 "AD Domain Summary" {
                                try {
                                    $inObj = [ordered] @{
                                        'Domain' = $LDAPDomain.domain
                                        'NetBIOS' = $LDAPDomain.netbios
                                        'Base' = $LDAPDomain.base
                                        'Username' = $LDAPDomain.username
                                        'Security' = $Security
                                        'SSL Verify' = $LDAPDomain.ssl_verify
                                        'Port' = $LDAPDomain.effective_port
                                    }
                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                    $TableParams = @{
                                        Name = "AD Domain Summary - $($AppVolServer)"
                                        List = $false
                                        ColumnWidths = 20, 20, 15, 15, 10, 10, 10
                                    }
                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Table @TableParams
                                } catch {
                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                }
                                if ($InfoLevel.AppVolumes.ADDomains -ge 2) {
                                    $OutObj = @()
                                    foreach ($LDAPDomain in $LDAPDomains.ldap_domains | Sort-Object -Property Domain) {
                                        Section -ExcludeFromTOC -Style NOTOCHeading5 "AD Domain Details - $($LDAPDomain.domain)" {
                                            try {
                                                $inObj = [ordered] @{
                                                    'Username' = $LDAPDomain.username
                                                    'Base' = $LDAPDomain.base
                                                    'NetBIOS' = $LDAPDomain.netbios
                                                    'LDAPS' = $LDAPDomain.ldaps
                                                    'LDAP_TLS' = $LDAPDomain.ldap_tls
                                                    'SSL Verify' = $LDAPDomain.ssl_verify
                                                    'Port' = $LDAPDomain.effective_port
                                                    'Created At' = $LDAPDomain.created_at
                                                    'Updated At' = $LDAPDomain.updated_at
                                                }
                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                                $TableParams = @{
                                                    Name = "AD Domain Details - $($LDAPDomain.domain)"
                                                    List = $true
                                                    ColumnWidths = 50, 50
                                                }
                                                if ($Report.ShowTableCaptions) {
                                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                                }
                                                $OutObj | Table @TableParams
                                            } catch {
                                                Write-PScriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }
                                    }


                                }
                            }
                        }
                    }
                }
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}