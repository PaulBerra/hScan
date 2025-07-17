# hScan
A small powershell module to track file modifications and additions in specific corporate contexts

<p style="display: center">
<img width="1536" height="1024" alt="20250715_1727_hScan Logo Design_simple_compose_01k07b2ph9f9rvh9qexhvyvx11" src="https://github.com/user-attachments/assets/ac31f9ee-6169-47d1-a524-b5dd3a9890d5" />
</p>

# Installation

```
git clone https://github.com/PaulBerra/hScan.git
cd hScan
```

We provide a release of Yara, but we recommend that you download the latest version: 
```
git clone https://github.com/VirusTotal/yara/releases
cp yara/yara_XX.exe .
rm -rf yara/
```

We also provide a set of yara rules found on github, which you are free to improve or contribute to.

# Concept
In most organizations, PC fleets are generally deployed with images customized to the company.
hScan aims to be a diagnostic utility with a company-specific tuning.

Specifically, it allows you to :

- Establish image reference mapping.
- Analyze differences between the moment of analysis and the original image (Additions, Deletions, Modifications).
- Analyze modified and added files using Sigma rules
- Generate reports on :
    - Modifications and additions
    - Yara analyses

Incoming :
- Define the most at-risk files
- Automatically submit the most dangerous files to VirusTotal
- Automatically create an e-mail request to reset the workstation, if VirusTotal detection exceeds a certain threshold.

# Usage

For obvious reasons, the analysis typically focuses on files that are writable by the user by default, like : 

```
$env:USERPROFILE,
$env:LOCALAPPDATA,
$env:APPDATA,
$env:ProgramData,
$env:TEMP
```

The aim is to keep false positives to a minimum and optimize the analysis.

A difference report is then generated.

Getting help :
```
.\main.ps1 help
```

Create the base of hash :
```
.\main.ps1 build -Out BaseScan.csv
```

Compare with hash base & generate report:
```
.\main.ps1 scan -In .\BaseScan.csv -Report report.csv
```

Run a yara analysis on new and modified files :
```
.\main.ps1 scan -In .\BaseScan.csv -Report .\report.csv -YaraScan 
```

## Incoming

Compare with hash base & yara + virustotal analysis :
```
.\main.ps1 scan -In .\BaseScan.csv -YaraScan -Vt
```

Same + mail 
```
.\main.ps1 scan -In .\BaseScan.csv -YaraScan -Vt -Email <mail>
```

# Configuration File

This file centralizes the configuration settings for the script, facilitating the addition of new features and customization. It defines default paths, hash algorithms, limits, logging configurations, exclusion patterns, and report templates.

## Configuration Sections

### 1. Default Paths

Defines the default directories to scan for file hash verification.

*   `DefaultPaths`: An array of paths to be included in the scan.  This includes user profiles, application data folders, and temporary directories.

### 2. Hash Algorithms

Specifies the hashing algorithms used for file verification.

*   `Default`: The default hashing algorithm to use (e.g., "SHA256").
*   `Available`: An array of supported hashing algorithms.

### 3. Limits

Defines various limits for the script's operation.

*   `MaxFileSizeMB`:  The maximum file size (in MB) to be processed. Files larger than this limit will be skipped.
*   `BatchSize`: The number of files processed in each batch.


### 4. Logging (currently hs)

Configures the script's logging behavior.

*   `ErrorLogFile`: The name of the file to store error logs.
*   `DebugLogFile`: The name of the file to store debug logs.
*   `MaxLogSizeMB`: The maximum size (in MB) of the log files.
*   `RetentionDays`: The number of days to retain log files.

### 5. Default Exclusions

Defines a list of file patterns to exclude from the scan.

*   `DefaultExclusions`: An array of file patterns to exclude (e.g., "*.tmp", "*.cache").


### 6. Reports

Configures the reporting options for the script.

*   `DefaultTemplate`: The default report template to use.
*   `Templates`: Defines the available report templates and their settings.
    *   `Standard`: A standard report template with basic information.
        *   `IncludeStatistics`:  Whether to include statistical information in the report.
        *   `IncludeTimestamp`: Whether to include timestamps in the report.
        *   `GroupByStatus`: Whether to group results by status.
    *   `Detailed`: A detailed report template with comprehensive information. Includes all `Standard` settings plus:
        *   `IncludeFileDetails`: Whether to include detailed file information.
        *   `IncludeSizeInfo`: Whether to include file size information.
    *   `Minimal`: A minimal report template with limited information.  Disables statistics, timestamps, and grouping.

