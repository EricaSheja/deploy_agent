ATTENDANCE TRACKER SETUP SCRIPT
OVERVIEW
This is a script written using Linux commands that creates a directory structure, with a parent directory which has 3 child directories with files inside them
It also asks the user if they want to update the attendance thresholds and then allows them to do so if they want, if not it stays with the default attendance thresholds.
It also implements a signal trap to handle user interrupts if the user clicks CTRL+C while the program is running.
It also performs a health check, where it checks if Python3 is installed on your local system.

FEATURES
DIRECTORY CREATION
Creates a parent directory named attendance_tracker_{input}, where {input} is user provided.
The parent directory contains 3 directories named: attendance_checker.py, Helpers and Reports
The "Helpers" directory contains 2 files named: assets.csv and config.json, we also add data in these files in the sript.
The "Reports" directory contains 1 file named: reports.log which also has data in it added through the script.

THRESHOLDS UPDATE
Prompts the user to update thresholds after the initial threshold setup.
The default threshold are: Warning(75%) and Failure(50%).
Input validation ensures that: values input are whole numbers between 1-100 and the failure threshold is strictly less than the warning threshold.
The sript uses sed for in place editing of the congif.json file.

SIGNAL TRAP
The script allows the user to interrupt the execution of the program by clicking CTRL+C.
It catches the signal and before exiting it bundles and archive the current state of the project directory and name it attendance_tracker_{input}_archive.
Then it removes the incomplete directory and keeps the workplace clean.
Then exits the process with a informative message to the user.

ENVIRONMENT HEALTH CHECK
The script checks if python 3 is installed using the command python --version.
Then checks the directory structure existence where it verifies if all 7 files and folders exist.
Then provides a clear success or warning message depending the outcome of the verification.
