# Changelog

All notable changes to TmuxAI Enhanced Installer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2026-01-31

### Added
- **Debug mode**: Set `DEBUG=1` to enable verbose logging for troubleshooting
- **Version pinning**: Support for `TMUXAI_VERSION` environment variable
- **YAML validation**: Automatic syntax validation after configuration generation
- **Error recovery**: Automatic rollback to backup if installation fails
- **Cleanup trap**: Proper cleanup of temporary files on exit
- **More package managers**: Added support for dnf and pacman

### Changed
- **Refactored script structure**: Better organization with helper functions
- **Improved API key handling**: Safer sed replacement with special character escaping
- **Better user feedback**: Clearer step-by-step progress indicators
- **Enhanced error messages**: More actionable error descriptions
- **Cleaner output**: Removed debug output from production code

### Fixed
- **Security**: API key special characters no longer break sed replacement
- **Robustness**: Script now properly handles installation failures
- **Terminal detection**: Better handling when running via `curl | bash`
- **Whitespace handling**: More reliable API key trimming

### Security
- **No more debug logging in production**: Debug output only when explicitly enabled
- **Backup preservation**: Original config preserved even after successful install
- **Temp file cleanup**: Automatic removal of temporary files

## [2.1.0] - 2025-XX-XX

### Added
- Enhanced configuration with 100+ whitelisted commands
- Improved AI prompts for better context awareness
- Support for development tools (npm, pip, cargo, maven)

### Changed
- Better error handling for API key validation
- Improved user feedback during installation

## [2.0.0] - 2025-XX-XX

### Added
- Initial release of Enhanced Installer
- Mistral Devstral model support
- Security-first whitelist configuration
- Backup functionality for existing configs

---

## Upgrade Guide

### From 2.1.x to 2.2.0

No breaking changes. Simply run the installer again:

```bash
curl -fsSL https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/install.sh | bash
```

Your existing configuration will be backed up automatically.

### Debug Mode

To troubleshoot installation issues:

```bash
DEBUG=1 bash install.sh
```

### Version Pinning

To install a specific TmuxAI version (when supported):

```bash
TMUXAI_VERSION="1.0.0" bash install.sh
```
