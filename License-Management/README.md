  # User License Assignment Script

This script is designed to assign licenses to users in a batch-processing manner, based on information provided in a CSV file. It utilizes PowerShell and Microsoft Graph API to perform the license assignment operations. The script also includes error handling and the ability to store a CSV file with the users who encountered errors during the license assignment process.

  # Prerequisites

* PowerShell: Ensure that you have PowerShell installed on your system. The script is compatible with PowerShell version 5.1 and later.
* Microsoft Graph PowerShell SDK: Install the Microsoft Graph PowerShell SDK by running the following command in PowerShell:
  
      Install-Module -Name Microsoft.Graph  
- CSV File: Prepare a CSV file with the user information, including Display Name, User Principal Name, and Licenses. Ensure that the CSV file follows the correct format and contains the necessary columns.

# Usage

Open a PowerShell console or PowerShell Integrated Scripting Environment (ISE).
Modify the following line in the script to specify the path to your CSV file:

        $CSVPath = "C:\users.CSV"

Replace "C:\users.CSV" with the actual path to your CSV file.
Review and modify other parameters in the script, if needed:
* $batchSize: Adjust the batch size to control the number of users processed in each batch. The default value is 5.
* $pause: Adjust the pause duration (in seconds) between batches to avoid potential throttling issues. The default value is 35 seconds.
 Run the script by executing it in the PowerShell console or ISE.

# Script Execution Flow

1. The script starts by importing the CSV file using the Import-Csv cmdlet and storing the user information in the $Users variable.
2. It calculates the number of batches required based on the batch size and user count.
3. For each batch, the script retrieves a subset of users to process.
4. Within each batch, the script iterates over the users and performs the following actions:
5. Retrieves the Display Name, User Principal Name, and Licenses from the CSV file.
6. Uses the Microsoft Graph API to check if the user exists.

If the user exists:

* Parses the license information and checks if the licenses are valid.
* Assigns licenses to the user by updating their Usage Location and applying for the appropriate licenses.
* Checks the current license status of the user to ensure a successful assignment.
* Prints relevant information about the license assignment process.
* If any errors occur during license assignment, the user is added to the $usersWithError array.
* If the user does not exist, it prints a message indicating that the user was not found.
7. After processing all batches and users, the script exports the contents of the $usersWithError array to a CSV file named "users_with_errors.csv" using the Export-Csv cmdlet.

# Error Handling

The script includes error handling to capture and handle exceptions that may occur during the license assignment process. If an error occurs while assigning licenses to a user or retrieving user information, the script will print an error message indicating the user and the specific error message.

The users who encounter errors during the license assignment process are added to the $usersWithError array. This array is then exported to a CSV file named "users_with_errors.csv" after the script completes execution.

# Limitations and Considerations

- Ensure that the CSV file contains the correct column headers and data format for Display Name, User Principal Name, and Licenses.
- The script utilizes the Microsoft Graph API for retrieving user information and performing license assignments. Ensure that the necessary permissions and authentication are set up correctly for the script to access the Graph API.
- Adjust the batch size and pause duration between batches based on your specific requirements and the limitations of the Microsoft Graph API rate limits.
- It's recommended to review the script and test it thoroughly in a controlled environment before using it in a production environment.
- Regularly update and maintain the Microsoft Graph PowerShell SDK to ensure compatibility and access to the latest features and bug fixes.
