function Get-AbrAppVolADDomain {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume AD Domain information.
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
        Write-PScriboMessage "ADDomains InfoLevel set at $($InfoLevel.AppVolumes.ADDomains)."
        Write-PscriboMessage "Collecting Active Directory Domain information."
    }

    process {
        if ($InfoLevel.AppVolumes.ADDomains -ge 1) {
            try {
                $LDAPDomains = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/ldap_domains"
                if ($LDAPDomains) {
                    section -Style Heading3 "Active Directory Domain" {
                        $OutObj = @()
                        foreach ($LDAPDomain in $LDAPDomains.ldap_domains | Sort-Object -Property Domain) {
                            section -Style Heading3 $LDAPDomain.domain {
                                try {
                                    $inObj = [ordered] @{
                                        'Username' = $LDAPDomain.username
                                        'Base' = $LDAPDomain.base
                                        'NetBIOS' = $LDAPDomain.netbios
                                        'LDAPS' = $LDAPDomain.ldaps
                                        'LDAP_TLS' = $LDAPDomain.ldap_tls
                                        'SSL Verify' = $LDAPDomain.ssl_verify
                                        'Port' = $LDAPDomain.port
                                        'Effective Port' = $LDAPDomain.effective_port
                                        'Created At' = $LDAPDomain.created_at
                                        'Updated At' = $LDAPDomain.updated_at
                                    }
                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                    $TableParams = @{
                                        Name = "Active Directory Domains - $($LDAPDomain.domain)"
                                        List = $true
                                        ColumnWidths = 50, 50
                                    }
                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Table @TableParams
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