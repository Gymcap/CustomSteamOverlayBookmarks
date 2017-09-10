#SingleInstance,Force
#Persistent
SetWorkingDir %A_ScriptDir%
OnExit, Exiting
Menu, Tray, NoStandard
Menu, Tray, add, Donate, Donation
Menu, tray, add
Menu, Tray, add, Kill Steam, KillSteam
Menu, tray, add
Menu, Tray, add, Update Backup Layout, UpdateBak
Menu, Tray, add, Get File Sizes, GetFileSizes
Menu, Tray, add, Set Steam Directory, SetDirectory
Menu, Tray, add, Pause Application, PauseApplication
Menu, Tray, add, Exit Application, ExitApplication
IniWrite, 1, CSOB.ini, Config, Help
IniRead, Steam, CSOB.ini, Config, SteamDirectory
IniRead, FinalDirectory, CSOB.ini,Config,Directory, DirectoryError
Steam = %Steam%\Steam.exe
SteamServiceOut = 0
If FinalDirectory = DirectoryError
{
	gosub, SetDirectory
}
else
{
	FileGetSize, OverlayDefault, %FinalDirectory%overlaydesktop.layout
	FileGetSize, OverlayBak, %FinalDirectory%overlaydesktop.layout.bak
	FileGetSize, OverlayOverwrite, %FinalDirectory%overlaydesktop.layout.Overwrite
	IniWrite, %OverlayDefault%, CSOB.ini, Config, Current layout
	IniWrite, %OverlayBak%, CSOB.ini, Config, Backup layout
	IniWrite, %OverlayOverwrite%, CSOB.ini, Config, Your layout
}	
SetTimer, IniCheck, 100
SetTimer, Timer, 100
return

IniCheck:
IfNotExist, CSOB.ini
{
	SetTimer, Timer, OFF
	SetTimer, IniCheck, OFF
	Gui, Add, Button, x52 y49 w100 h30 gRestart , Restart
	Gui, Add, Button, x172 y49 w100 h30 gClose , Close
	Gui, Add, Text, x22 y19 w290 h20 , Application ini file lost. Please restart or close this application.
	Gui, Show,, Oh no!
	Return
	Restart:
	Reload
	return
	GuiClose:
	Close:
	ExitApp
	return
	
}
return

Timer:
IniRead, SteamServiceOut, CSOB.ini, Config, SteamServiceRunning
Process, Exist, SteamService.exe
if !ErrorLevel = 0
{ ; Steam Service Running
	If SteamServiceOut = 1
	{
		return
	}
	else
	{	
		FileCopy, %FinalDirectory%overlaydesktop.layout.Overwrite, %FinalDirectory%overlaydesktop.layout, 1
		Sleep, 500
		TrayTip, Custom Steam Overlay Bookmark, Your layout has been restored, 1, 48
		IniWrite, 1, CSOB.ini, Config, SteamServiceRunning
	}
}
else
{ ; Steam Service not running
	If SteamServiceOut = 0
	{
		return
	}
	else
	{
		FileCopy, %FinalDirectory%overlaydesktop.layout.bak, %FinalDirectory%overlaydesktop.layout, 1
		Sleep, 500
		TrayTip, Custom Steam Overlay Bookmark, Default Layout has been restored, 1, 48
		IniWrite, 0, CSOB.ini, Config, SteamServiceRunning
	}
}
return

UpdateBak:
SetTimer, Timer, OFF
SetTimer, IniCheck, OFF
If SteamServiceOut = 1
{
	Msgbox, 1,Update Backup Layout, This will exit steam if running in order to grab a fresh file from steam services.
	IfMsgBox,OK
	{
		
		IfWinExist, ahk_exe Steam.exe
		{
			Process, Close, Steam.exe
			Sleep 1000
			Run, % Steam
			WinWait, Steam Login
			FileCopy, %FinalDirectory%overlaydesktop.layout, %FinalDirectory%overlaydesktop.layout.bak, 1
			TrayTip, Custom Steam Overlay Bookmark, Backup Layout has been updated, 1, 48
			Sleep, 2000
			Reload
			return
			
			
			
			
			
			
		}
	}
	return
	IfMsgBox,Cancel
	{
		return
	}
	return
}
else
{
	Msgbox, 1,Update Backup Layout, This will -exit steam in order to grab a fresh file from steam services.
	IfMsgBox,OK
	{
		Run, % Steam
		WinWait, Steam Login
		FileCopy, %FinalDirectory%overlaydesktop.layout, %FinalDirectory%overlaydesktop.layout.bak, 1
		TrayTip, Custom Steam Overlay Bookmark, Backup Layout has been updated, 1, 48
		Sleep, 2000
		Reload
		return
	}
	return
	IfMsgBox,Cancel
	{
		return
	}
	return
}
return

GetFileSizes:
FileGetSize, OverlayDefault, %FinalDirectory%overlaydesktop.layout
FileGetSize, OverlayBak, %FinalDirectory%overlaydesktop.layout.bak
FileGetSize, OverlayOverwrite, %FinalDirectory%overlaydesktop.layout.Overwrite
IniWrite, %OverlayDefault%, CSOB.ini, Config, Current layout
IniWrite, %OverlayBak%, CSOB.ini, Config, Backup layout
IniWrite, %OverlayOverwrite%, CSOB.ini, Config, Your layout
Msgbox, Backup Overlay: %OverlayBak%`nDefault Overlay: %OverlayDefault%`nYour Overlay: %OverlayOverwrite%
return

SetDirectory:
FileSelectFolder, OutputDirectory,,2 ,Please locate your Steam folder.
ifExist, %OutputDirectory%\resource\layout\
	{
		msgbox,, Directory Saved, %OutputDirectory%\resource\layout\
		IniWrite, %OutputDirectory%\resource\layout\, CSOB.ini, Config, Directory
		IniWrite, %OutputDirectory%, CSOB.ini, Config, SteamDirectory
		gosub, WriteFileSize
		Reload
	}
	else
	{
		Gui, Add, Button, x52 y49 w100 h30 gRetry, Retry
		Gui, Add, Button, x172 y49 w100 h30 gClose, Close
		Gui, Add, Text, x46 y19 w230 h20 , Failed to find Steam subfolders. Please try again.
		Gui, Show,, Oh no!
}
return

WriteFileSize:
FileGetSize, OverlayDefault, %FinalDirectory%overlaydesktop.layout
FileGetSize, OverlayBak, %FinalDirectory%overlaydesktop.layout.bak
FileGetSize, OverlayOverwrite, %FinalDirectory%overlaydesktop.layout.Overwrite
IniWrite, %OverlayDefault%, CSOB.ini, Config, Current layout
IniWrite, %OverlayBak%, CSOB.ini, Config, Backup layout
IniWrite, %OverlayOverwrite%, CSOB.ini, Config, Your layout
Return

Retry:
Gui, Destroy
Goto, SetDirectory
return

KillSteam:
Process,Close,steam.exe
return

PauseApplication:
Pause, Toggle
return

!1::
ExitApplication:
gosub, WriteFileSize
ExitApp
return

;Please don't steal from my work
Donation:
run, https://www.paypal.me/gymcap
return

!2::
msgbox, %OutputDirectory%Steam.exe
return

Exiting:
FileCopy, %FinalDirectory%overlaydesktop.layout.bak, %FinalDirectory%overlaydesktop.layout, 1
Sleep, 500
TrayTip, Custom Steam Overlay Bookmark, Default Layout has been restored, 1, 48
IniWrite, 0, CSOB.ini, Config, SteamServiceRunning
Goto, ExitApplication
return