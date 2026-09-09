# scripts

## MapDrives

`MapDrives.ps1` maps the network drives configured for the current Windows user.
Its configuration is kept in the user's home directory so the script contains no
usernames, passwords, drive letters, or share paths.

On the first run, the script prompts for the network-share username and password,
then saves them as:

```powershell
$HOME\MapDrivesCredential.txt
```

The password in that file is protected by Windows DPAPI and can be decrypted only
by the same user on the same computer.

Copy `MapDrivesList.example.csv` to `$HOME\MapDrivesList.csv`, then edit the rows:

```powershell
Copy-Item .\MapDrivesList.example.csv "$HOME\MapDrivesList.csv"
```

The CSV has two columns:

```csv
DriveLetter,RemotePath
L,\\server\share
```

Run `MapDrives.cmd` directly or from a startup shortcut. The first run stays
visible while collecting the credential. Later runs append their output to
`%TEMP%\MapDrives.log`.
