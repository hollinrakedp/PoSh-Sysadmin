# Use During Imaging or initial deployment. Adding these keys won't change settings for existing users.

# Load the default user registry
REG LOAD "HKU\Default" "C:\Users\Default\NTUSER.DAT"

# Hide Taskbar News Feed
REG ADD "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /T REG_DWORD /d 2 /f

# Hide Cortana Search Box
REG ADD "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchBoxTaskbarMode /d 0 /f

# Hide Cortana Button
REG ADD "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCortanaButton /d 0 /f

# Hide Task View Button
REG ADD "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /d 0 /f

# Show File Extensions
REG ADD "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /d 0 /f

# Unload the default user registry
REG UNLOAD "HKU\Default"