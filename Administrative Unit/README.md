# GraphAdminMembership Powershell Script

The GraphAdminMembership.ps1 script is a PowerShell tool designed to facilitate the management of administrative units and user memberships within Microsoft Graph. This script interacts with the Microsoft Graph API to create and manage administrative units based on company names and adds users as members to the corresponding administrative units.

# Prerequisites

Azure AD Application Setup:
        Register an application in the Azure portal to obtain the required Application ID.
        Generate a Client Secret for the application.
        Grant necessary permissions (User.ReadWrite.All, Group.ReadWrite.All, Directory.ReadWrite.All) to the application.
https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0#use-delegated-access-with-a-custom-application-for-microsoft-graph-powershell

Microsoft Graph PowerShell SDK:
 Install the Microsoft Graph PowerShell SDK using the following command:
    
    Install-Module -Name Microsoft.Graph

# Script Configuration

* Open the GraphAdminMembership.ps1 script in a text editor of your choice.
* Locate the following variables and replace the placeholders with your actual values:
  * $tenantID: Your Azure AD Tenant ID.
  * $applicationId: Your registered Azure AD Application ID.
  * $clientSecret: The generated Client Secret for the application.

# Running the Script

Authentication:
        Open PowerShell on your computer.
        Navigate to the directory containing the script using the cd command, for example:
     
       cd C:\Path\To\Script

Run the script by typing its filename and pressing Enter:

        .\GraphAdminMembership.ps1

The script will authenticate using the provided credentials and proceed with administrative unit management.

# Script Execution:
The script performs the following steps:
* Authenticates to Microsoft Graph using the provided Azure AD application credentials.
* Checks for existing administrative units based on company names and creates them if necessary.
* Adds users and groups that users are members to corresponding administrative units based on their company names.

# Monitoring Progress:

Follow the script's output in the PowerShell console to monitor its progress.
The script will provide messages indicating the creation of administrative units and the addition of users.

# Limitations and Considerations

* The script assumes that user data is correctly structured with accurate company names for administrative unit organization.
* Enhance error handling, logging, and advanced error reporting for production use.
* The script does not handle updating or deleting administrative units, and it may need customization for more complex scenarios.
