# Specify the path to the CSV file
$CSVPath = "C:\users.csv"

# Import the CSV file
$Users = Import-Csv -Path $CSVPath

$batchSize = 5  # Adjust the batch size as desired
$pause = 35      # Adjust the pause duration (in seconds) between batches as desired

$usersCount = $Users.Count
$batchCount = [Math]::Ceiling($usersCount / $batchSize)
$location = BR

# Create an array to store the users with errors
$usersWithError = @()

for ($batchIndex = 0; $batchIndex -lt $batchCount; $batchIndex++) {
    $startIndex = $batchIndex * $batchSize
    $endIndex = [Math]::Min(($startIndex + $batchSize - 1), ($usersCount - 1))

    $batchUsers = $Users[$startIndex..$endIndex]

    foreach ($user in $batchUsers) {
        $displayName = $user.DisplayName
        $userPrincipalName = $user.UserPrincipalName
        $Licensess = $user.Licenses -split ',' | ForEach-Object { $_.Trim() }

        $userObj = Get-MgUser -UserId $userPrincipalName -ErrorAction SilentlyContinue

        if ($userObj) {
            
            $addLicenses = @()
            foreach ($Licenses in $Licensess) {
                $sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq $Licenses
                if ($sku) {
                    $addLicenses += @{ SkuId = $sku.SkuId }
                }
            }

            try {
                Update-MgUser -UserId $userObj.Id -UsageLocation $location
                Set-MgUserLicense -UserId $userObj.Id -AddLicenses $addLicenses -RemoveLicenses @()
                Write-Host "Licenses assigned to user $displayName ($userPrincipalName)." -ForegroundColor Green

                # Check the current license status of the user
                $updatedUserObj = Get-MgUser -UserId $userObj.Id -Select AssignedLicenses -ErrorAction SilentlyContinue

                if ($updatedUserObj) {
                    Write-Host "User $displayName ($userPrincipalName) has the following licenses applied:"
                    foreach ($assignedLicense in $updatedUserObj.AssignedLicenses) {
                        Write-Host "- $($assignedLicense.SkuId)"
                    }
                } else {
                    Write-Host "Error: Failed to retrieve user $displayName ($userPrincipalName) information after applying the license." -ForegroundColor Red
                    # Add the user to the array of users with errors
                    $usersWithError += $user
                }
            } catch {
                Write-Host "Failed to assign licenses to user $displayName ($userPrincipalName). Error: $($_.Exception.Message)" -ForegroundColor Red
                # Add the user to the array of users with errors
                $usersWithError += $user
            }
        } else {
            Write-Host "User $displayName ($userPrincipalName) not found." -ForegroundColor Red
            # Add the user to the array of users with errors
            $usersWithError += $user
        }
    }

    if ($batchIndex -lt ($batchCount - 1)) {
        Write-Host "Pausing for $pause seconds before processing the next batch..."
        Start-Sleep -Seconds $pause
    }
}

# Export the users with errors to a CSV file
$usersWithError | Export-Csv -Path "C:\users-error.csv" -NoTypeInformation
