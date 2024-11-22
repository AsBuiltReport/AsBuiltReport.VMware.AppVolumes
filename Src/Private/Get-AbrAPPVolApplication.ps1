function Get-AbrAPPVolApplication {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Product information.
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
        Write-PScriboMessage "Products InfoLevel set at $($InfoLevel.AppVolumes.Products)."
        Write-PScriboMessage "Collecting Products information."
    }

    process {
        if ($InfoLevel.AppVolumes.Products -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Products = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_products"
                } else { $Products = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_products" }

                if ($Products.data) {
                    Section -Style Heading3 'Application Summary' {
                        Paragraph "The following section provide a summary of the applications captured on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($Product in $Products.data) {
                            try {
                                $ProductID = $Product.id

                                if ($PSVersionTable.PSEdition -eq 'Core') {
                                    $ProductIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/app_packages?include=app_markers"
                                } else { $ProductIDSource = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/app_packages?include=app_markers" }

                                $ProductPackage = $ProductIDSource.data | Where-Object { $_.app_markers.name -eq 'CURRENT' }

                                $inObj = [ordered] @{
                                    'Name' = $Product.Name
                                    'Status' = $Product.Status
                                    'Created' = $Product.created_At_Human
                                    'Template Version' = $ProductPackage.template_version
                                    'Agent Version' = $ProductPackage.agent_version
                                    'Applications Count' = $ProductPackage.programs_count
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                        $TableParams = @{
                            Name = "Application Summary - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 25, 15, 15, 15, 15, 15
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name | Table @TableParams
                        if ($InfoLevel.AppVolumes.Products -ge 2) {
                            Section -Style Heading4 "Applications Details" {
                                foreach ($Product in $Products.data | Sort-Object -Property Name) {
                                    try {
                                        $ProductID = $Product.id

                                        if ($PSVersionTable.PSEdition -eq 'Core') {
                                            $ProductIDSource = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/app_packages?include=app_markers"
                                        } else { $ProductIDSource = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/app_packages?include=app_markers" }

                                        if ($PSVersionTable.PSEdition -eq 'Core') {
                                            $ActiveDirectoryUsers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users"
                                        } else { $ActiveDirectoryUsers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users" }

                                        foreach ($ActiveDirectoryUser in $ActiveDirectoryUsers) {
                                            if ($ActiveDirectoryUser) {
                                                if ($PSVersionTable.PSEdition -eq 'Core') {
                                                    $UserDetails = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users/$($ActiveDirectoryUser.id)"
                                                } else { $UserDetails = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users/$($ActiveDirectoryUser.id)" }
                                                if ($UserDetails.object_guid -like $Product.Owner_Guid) {
                                                    $OwnerName = $UserDetails.upn
                                                    Break
                                                }
                                            }
                                        }

                                        $ProductPackage = $ProductIDSource.data | Where-Object { $_.app_markers.name -eq 'CURRENT' }
                                        if ($Product) {
                                            Section -Style Heading5 "Application Details - $($Product.Name)" {
                                                $OutObj = @()
                                                $inObj = [ordered] @{
                                                    'Name' = $Product.Name
                                                    'Status' = $Product.Status
                                                    'Owner' = $OwnerName
                                                    'Total Assignments' = $Product.assignment_count
                                                    'Created' = $Product.created_At_Human
                                                    'Modified' = $Product.updated_at_human
                                                    'Description' = $Product.description
                                                    'RDS Package Attachment' = $Product.allow_multiple_package_attachment
                                                    'Last Synchronized' = $Product.synced_at_human
                                                    'Sync Status' = $Product.sync_status

                                                }
                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                $TableParams = @{
                                                    Name = "Application Details - $($Product.Name)"
                                                    List = $true
                                                    ColumnWidths = 50, 50
                                                }
                                                if ($Report.ShowTableCaptions) {
                                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                                }
                                                $OutObj | Table @TableParams
                                                try {
                                                    $ProductPackages = $ProductIDSource.data
                                                    if ($ProductPackage) {
                                                        Section -ExcludeFromTOC -Style NOTOCHeading6 "Application Packages" {
                                                            $OutObj = @()
                                                            foreach ($Package in $ProductPackages) {
                                                                $inObj = [ordered] @{
                                                                    'Name' = $Package.Name
                                                                    'Version' = $Package.Version
                                                                    'Created' = Switch ($Package.created_at) {
                                                                        $Null { '--' }
                                                                        default { ([DateTime]$Package.created_at).ToShortDateString() }
                                                                    }
                                                                    'Mounted' = Switch ($Package.mounted_at) {
                                                                        $Null { '--' }
                                                                        default { ([DateTime]$Package.mounted_at).ToShortDateString() }
                                                                    }
                                                                    'Size' = $Package.size_human
                                                                    'Current' = Switch ($Package.app_markers.name) {
                                                                        $null { 'No' }
                                                                        'CURRENT' { 'Yes' }
                                                                        default { '--' }
                                                                    }
                                                                }
                                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                            }

                                                            $TableParams = @{
                                                                Name = "Application Packages - $($Product.Name)"
                                                                List = $false
                                                                ColumnWidths = 25, 15, 15, 15, 15, 15
                                                            }
                                                            if ($Report.ShowTableCaptions) {
                                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                                            }
                                                            $OutObj | Sort-Object -Property 'Version' -Descending | Table @TableParams
                                                            try {
                                                                $ProductPackage = ($ProductIDSource.data | Where-Object { $_.app_markers.name -eq 'CURRENT' }).id

                                                                if ($PSVersionTable.PSEdition -eq 'Core') {
                                                                    $ProductPrograms = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_packages/$ProductPackage/programs"
                                                                } else { $ProductPrograms = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_packages/$ProductPackage/programs" }

                                                                if ($ProductPrograms.data) {
                                                                    Section -ExcludeFromTOC -Style NOTOCHeading6 "Application Programs" {
                                                                        $OutObj = @()
                                                                        foreach ($Program in $ProductPrograms.data) {
                                                                            $inObj = [ordered] @{
                                                                                'Name' = $Program.Name
                                                                                'Version' = $Program.Version
                                                                                'Created' = $Program.created_At_Human
                                                                            }
                                                                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                        }

                                                                        $TableParams = @{
                                                                            Name = "Application Programs - $($Product.Name)"
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
                                                                Write-PScriboMessage -IsWarning $_.Exception.Message
                                                            }
                                                        }
                                                    }
                                                } catch {
                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {
                                                    $ProductID = $Product.id

                                                    if ($PSVersionTable.PSEdition -eq 'Core') {
                                                        $ProductAssignments = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/assignments?include=entities"
                                                    } else { $ProductAssignments = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -ContentType 'application/json' -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/assignments?include=entities" }

                                                    if ($ProductAssignments.data) {
                                                        Section -ExcludeFromTOC -Style NOTOCHeading6 "Application Assignment" {
                                                            $OutObj = @()
                                                            foreach ($ProductAssignment in $ProductAssignments.data) {
                                                                try {
                                                                    $inObj = [ordered] @{
                                                                        'Name' = $ProductAssignment.entities.upn
                                                                        'Type' = $ProductAssignment.entities.entity_type
                                                                    }
                                                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                } catch {
                                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                                }
                                                            }

                                                            $TableParams = @{
                                                                Name = "Application Assignment - $($Product.Name)"
                                                                List = $false
                                                                ColumnWidths = 50, 50
                                                            }
                                                            if ($Report.ShowTableCaptions) {
                                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                                            }
                                                            $OutObj | Sort-Object -Property 'Name' |  Table @TableParams
                                                        }
                                                    }
                                                } catch {
                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }
                                        }
                                    } catch {
                                        Write-PScriboMessage -IsWarning $_.Exception.Message
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