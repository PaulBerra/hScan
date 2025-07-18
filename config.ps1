# ====================================================================
# CONFIGURATION FILE
# ====================================================================
# This file can be used to centralize configuration
# and make it easier to add new features

@{

    VirusTotalApiKey = ""

    # Report configuration template
    ReportsTemplate = "detailed"
    
    # Setting default paths
    DefaultPaths = @(
        #$env:USERPROFILE,
        #$env:LOCALAPPDATA,
        #$env:APPDATA,
        #$env:ProgramData,
        $env:TEMP
    )

    # Hash algorithm configuration
    HashAlgorithms = @{
        Default = "SHA256"
        Available = @("MD5", "SHA1", "SHA256", "SHA384", "SHA512")
    }
    
    # Setting limits
    Limits = @{
        MaxFileSizeMB = 9999999
        BatchSize = 100
    }
    
    # Log configuration
    Logging = @{
        ErrorLogFile = "hash_errors.log"
        DebugLogFile = "hash_debug.log"
        MaxLogSizeMB = 10
        RetentionDays = 7
    }
    
    # Default exclusion patterns
    DefaultExclusions = @(
        "*.tmp",
        "*.temp",
        "*.cache",
        "~*",
        "thumbs.db",
        "desktop.ini",
        "*.lnk"
    )
    
    YaraConf = @{
        #YaraTemplate = "compact" # compact; standard; detailled
        YaraReport = $true
        YaraBinaryPath = "C:\dev\hScan\bin\yara64.exe"
        YaraRulesPath = "C:\dev\hScan\rules"
        YaraMatchs = @(
        'Malware','Trojan','Ransomware','Spyware','Adware','Worm',
        'Virus','Backdoor','Keylogger','Botnet','PUA',
        'Packer','Crypter','UPX','Themida',
        'Suspicious','Heuristic','Indicator','C2','Exploit',
        'Policy','tc_policy','Test','Experimental','Global','Private',
        'APT28','Lazarus','MITRE_T1041','FileLess','Macro','Script'
        )
    }
}
