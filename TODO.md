# Dotfiles TODO

## Active Tasks

| Status | Date Added | Task |
|--------|------------|------|
| [ ] | 2025-05-28 | [Clean up obsolete root directory files](#clean-up-obsolete-root-directory-files) |
| [ ] | 2025-05-28 | [Create credential scanner for dotfiles](#create-credential-scanner-for-dotfiles) |
| [ ] | 2025-05-28 | [Create go.sh setup script](#create-gosh-setup-script) |

---

## Completed Tasks

| Status | Date Added | Task | Date Completed |
|--------|------------|------|----------------|
| | | | |

---

## Task Details

### Clean up obsolete root directory files
**Added:** 2025-05-28

Analyze all files in the root directory of the dotfiles repository to identify and remove files that are no longer relevant, needed, or functional. This includes:

- Review each script and configuration file for current relevance
- Check if files are actually used by other scripts or processes
- Identify duplicated functionality that could be consolidated
- Remove legacy files from previous setups that are no longer applicable
- Document any files that are kept and their purpose

Current root directory files to analyze:
- Session.vim, brewSetup.sh, linkCloudStorageProviders.sh, linkFilesv3.sh
- linkShellConfigFiles.sh, syncCurrentState.sh, sshSetup.sh, inkdropSetup.sh
- homebrew-packages.json, and others

The goal is to have a clean, organized root directory with only actively used and relevant files.

### Create credential scanner for dotfiles
**Added:** 2025-05-28

Write a script that introspects the entire dotfiles directory to ensure no credentials, API keys, tokens, or other sensitive information is being saved to the repository. The scanner should:

- Check for common patterns of API keys, tokens, passwords
- Scan configuration files for sensitive data
- Look for private keys, certificates, and other security-related files
- Generate a report of any potential security issues found
- Be able to run as part of a pre-commit hook or CI/CD pipeline
- Support whitelisting certain files or patterns that are known to be safe

### Create go.sh setup script
**Added:** 2025-05-28

Create a comprehensive interactive setup script that can be run when pulling this repo down to a new machine. The script should guide the user through the installation process and handle all necessary setup steps to get the dotfiles environment fully configured.

The script should be interactive to:
- Prompt user for which components to install
- Ask for confirmation before making system changes
- Allow selective installation of different parts
- Provide clear feedback on what's happening at each step

Need to determine exactly what should be included:
- Running existing setup scripts (brewSetup.sh, linkFilesv3.sh, etc.)
- Installing dependencies
- Setting up symlinks
- Configuring shell environments
- Any other initialization steps required for a complete setup