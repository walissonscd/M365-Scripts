# Authenticate to Microsoft Graph
$tenantID = "<YourTenantID>"
$applicationId = "<YourApplicationId>"
$clientSecret = "<YourClientSecret>"

$SecuredPasswordPassword = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force

$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $SecuredPasswordPassword

Connect-MgGraph -TenantId $tenantID -ClientSecretCredential $ClientSecretCredential

# Function to check if an administrative unit with the given name exists
function Get-AdministrativeUnit {
    param (
        [string]$administrativeUnitName
    )
    $administrativeUnits = Get-MgDirectoryAdministrativeUnit
    foreach ($unit in $administrativeUnits) {
        if ($unit.displayName -eq $administrativeUnitName) {
            return $true
        }
    }
    return $false
}

# Function to create an administrative unit with the given name
function New-AdministrativeUnit {
    param (
        [string]$administrativeUnitName
    )
    $params = @{
        displayName = $administrativeUnitName
    }
    New-MgDirectoryAdministrativeUnit -BodyParameter $params
}

# Function to add a user as a member of an administrative unit if they are not already a member
function Add-UserAsAdministrativeUnitMember {
    param (
        [string]$userId,
        [string]$administrativeUnitId
    )
    $user = Get-MgUser -UserId $userId
    $username = $user.DisplayName

    # Add user as a member
    $existingMembers = Get-MgDirectoryAdministrativeUnitMember -AdministrativeUnitId $administrativeUnitId -All | Select-Object -ExpandProperty Id
    if ($existingMembers -contains $user.id) {
        Write-Output "User with ID '$username' is already a member of the administrative unit."
    } else {
        $params = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($user.id)"
        }
        New-MgDirectoryAdministrativeUnitMemberByRef -AdministrativeUnitId $administrativeUnitId -BodyParameter $params
        Write-Output "User with ID '$username' added as a member of the administrative unit."
    }

    # Add user's group membership to administrative unit
    $userGroups = Get-MgUserMemberOfAsGroup -UserId $user.id
    foreach ($group in $userGroups) {
        $existingGroupMembers = Get-MgDirectoryAdministrativeUnitMember -AdministrativeUnitId $administrativeUnitId -all | Select-Object -ExpandProperty Id
        if ($existingGroupMembers -notcontains $group.id) {
            $groupParams = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/groups/$($group.id)"
            }
            New-MgDirectoryAdministrativeUnitMemberByRef -AdministrativeUnitId $administrativeUnitId -BodyParameter $groupParams
            Write-Output "Group with ID '$($group.DisplayName)' added as a member of the administrative unit."
        } else {
            Write-Output "Group with ID '$($group.DisplayName)' is already a member of the administrative unit."
        }
    }
}

# Retrieve all users
$allUsers = Get-MgUser -All

# Extract unique company names from users
$uniqueCompanyNames = $allUsers | Select-Object -ExpandProperty companyName -Unique

# Loop through unique company names
foreach ($companyName in $uniqueCompanyNames) {
    # Check if administrative unit exists, and create if it doesn't
    if (Get-AdministrativeUnit -administrativeUnitName $companyName) {
        Write-Output "Administrative unit '$companyName' already exists."
    } else {
        New-AdministrativeUnit -administrativeUnitName $companyName
        Write-Output "Administrative unit created with the name '$companyName'."
    }
}

# Get all administrative units
$administrativeUnits = Get-MgDirectoryAdministrativeUnit

# Loop through administrative units to add users
foreach ($administrativeUnit in $administrativeUnits) {
    $companyName = $administrativeUnit.displayName

    # Retrieve users with the specific company name
    $users = $allUsers | Where-Object { $_.companyName -eq $companyName }

    if ($users) {
        $administrativeUnitId = $administrativeUnit.id

        foreach ($user in $users) {
            Add-UserAsAdministrativeUnitMember -userId $user.id -administrativeUnitId $administrativeUnitId
        }

        Write-Output "Users with company name '$companyName' added as members of the administrative unit."
    } else {
        Write-Output "No users found with the company name '$companyName'."
    }
}
