@echo off
Powershell.exe -executionpolicy remotesigned -File  %cd%\content\blobstorageUpload.ps1
pause