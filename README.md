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

You can use this set of rules to test it : 
```
git clone https://github.com/Yara-Rules/rules.git
```


Before starting, you must fill in at least in the config :
```
YaraBinaryPath = "yara64.exe"
YaraRulesPath = "rules\"
VirusTotalApiKey = ""  # if you want to use it
```

We also recommend choosing a repo of relevant yara rules and indexed patches (index.yar).

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

# Usage

For obvious reasons, the analysis typically focuses on files that are writable by the user by default, like : 

```
$env:USERPROFILE,
$env:LOCALAPPDATA,
$env:APPDATA,
$env:ProgramData,
$env:TEMP
```
! Do not use $env if you dont run the script from user env. will be added soon.

The aim is to keep false positives to a minimum and optimize the analysis.

A difference report is then generated.

Getting help :
```
.\main.ps1 help
```

Create the base of hash :
```
.\main.ps1 build -Out .\BaseScan.csv
```

Compare with hash base & generate report:
```
.\main.ps1 scan -In .\BaseScan.csv -Out .\diff.csv
```

Run a yara analysis on new and modified files :
```
.\main.ps1 scan -In .\BaseScan.csv -Out .\diff.csv -YaraScan 
```

Compare with hash base & yara + virustotal analysis :
```
.\main.ps1 scan -In .\BaseScan.csv -Out .\diff.csv -Vt
```


# Configuration File

This file centralizes the configuration settings for the script, facilitating the addition of new features and customization. It defines default paths, hash algorithms, limits, logging configurations, exclusion patterns, and report templates.

## Configuration Sections

### Default Paths

Defines the default directories to scan for file hash verification.

*   `DefaultPaths`: An array of paths to be included in the scan.  This includes user profiles, application data folders, and temporary directories.

### Default Exclusions

Defines a list of file patterns to exclude from the scan.

*   `DefaultExclusions`: An array of file patterns to exclude (e.g., "*.tmp", "*.cache").

### Report Template

Define the template of the report.

*   `ReportsTemplate` = "detailed"

### Yara rules match

Defines the rules used in YaraScan (like the -t parameter of the binary)

```
*   YaraMatchs = @(
        'Malware','Trojan','Ransomware','Spyware','Adware','Worm',
        'Virus','Backdoor','Keylogger','Botnet','PUA',
        'Packer','Crypter','UPX','Themida',
        'Suspicious','Heuristic','Indicator','C2','Exploit',
        'Policy','tc_policy','Test','Experimental','Global','Private',
        'APT28','Lazarus','MITRE_T1041','FileLess','Macro','Script'
        )``
