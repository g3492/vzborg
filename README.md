# VzBorg utility
## **Deduplicated, encrypted, local or remote backups for the [Proxmox Virtual Environment](https://pve.proxmox.com/ )**

With VzBorg you can:
- Backup, restore, delete, list and maintain your PVE backups in a flexible and efficient way.
- Use default retention settings to keep your desired number of last, hourly, daily, weekly, monthly and yearly backups.
- Set up simple automated backups to remote repositories using ssh keys.

VzBorg uses vzdump and [BorgBackup](https://www.borgbackup.org/) to allow deduplicated, compressed backups of Proxmox guests, in an optionally encrypted repository.

## Requirements
You need a proxmox 5.x or 6.x server with a suitable BorgBackup package installed. 

If you are running proxmox 6.x you can install BorgBackup with:

`apt install borgbackup`

If you are running proxmox 5.x you must enable stretch-backports repository:

`echo "deb http://ftp.debian.org/debian stretch-backports main" >>/etc/apt/sources.list`

 Then install BorgBackup from it:

`apt update`

`apt install -t stretch-backports borgbackup`

If you want to use a remote repository, you need BorgBackup installed on the remote computer, with the same or a greater version, than the one in your proxmox server. If your remote repository is on another proxmox server, you can also install VzBorg on it.

## Installation
As user root in your Proxmox server run:

`wget -O - https://raw.githubusercontent.com/g3492/vzborg/master/install_and_update_vzborg.sh | bash`

## Usage:
`vzborg <COMMAND> [OPTIONS]`

After the \<COMMAND\> VzBorg only uses options. Specified, but not used options, are ignored.

### Commands:

VzBorg accepts one of the following commands:

| Command   | Description                        |
|:----------|:-----------------------------------|
|  backup   |Perform a backup job.               |
|  delete   |Delete backups.                     |
|  getdump  |Recreate a dump file from a backup. |
|  help     |Show VzBorg help.                   |
|  info     |Show repository or backup info      |
|  list     |List backups in a repository.       |
|  purge    |Purge a repository.                 | 
|  restore  |Restore backup from a repository.   |
|  version  |Show VzBorg, Borg and PVE versions. |
            
Examples:

`vzborg list`

List backups in default repository

`vzborg backup -i 121`

Backup guest with ID 121 to default repository

### Options
| Option          | Value      |Use with commands          |Description                             |
|:----------------|:-----------|:--------------------------|:---------------------------------------|
|-b (--backup)    |backup_name |delete/getdump/info/restore|Name of an existing backup (archive)    |
|-c (--config)    |config_name |all except help/version    |Name of a config file in /etc/vzborg dir|
|-d (--dry-run)   |            |purge                      |Just perform a simulation               |
|-f (--force)     |            |restore                    |Force overwrite of existing VM/CT       |
|-h (--help)      |            |all except help/version    |Display command help                    |
|-i (--id)        |vm_id       |backup/delete/purge/restore|PVE VM/CT ID or list of PVE VM/CT IDs   |
|-k (--keep)      |retention   |backup/purge               |List of retention settings              |
|-m (--mode)      |mode        |backup                     |vzdump mode (default = snapshot)        |
|-n (--new-id)    |vm_id       |restore                    |New vm_id for restored backup           |
|-r (--repository)|repository  |all except help/version    |Borg repository                         |
|-s (--storage)   |storage     |getdump/restore            |Proxmox storage (default = local)       |

### Configuration file:

 `/etc/vzborg/default`

Edit before using VzBorg, to customize defaults values for repository, encryption, etc..

You can have different config files in /etc/vzborg for managing different repositories or environments.
You can instruct vzborg to read an additional configuration file with the -c option. Ex:

`vzborg backup -c remoterepo -i 121`

Backup guest with ID 121 reading additional configuration file /etc/vzborg/remoterepo.

### Repositories
The `vzborg backup` command, automatically creates a repository using default values, if the related directory does not exist.

The best way to start with VzBorg is to edit the `/etc/vzborg/default` file with some sensible values, and run a backup of a small guest.

After that, you will have a repository with one backup to test other VzBorg commands.

### Backup names

VzBorg creates backups encoding the guest ID and the backup time into the name, for example:

`vzborg-104-2020_04_02-17_12_34.tar` for an lxc container

or

`vzborg-105-2020_04_02-17_15_11.vma` for a virtual machine

When recreating a Proxmox backup file (getdump command), VzBorg will use the default PVE naming convention, for example:

`vzdump-lxc-104-2020_04_02-17_12_34.tar.lzo` for an lxc container

or

`vzdump-qemu-105-2020_04_02-17_15_11.vma.lzo` for a virtual machine


### Examples
`vzborg restore -h`

Show help about restore command.

`vzborg backup --id 201`

Backup guest 201 to default repository with default mode snapshot.

`vzborg backup --id all`

Backup all guest in proxmox node to default repository.

`vzborg backup --id '101 102 307' --mode stop --purge`

Backup guests 101, 102 and 307 with mode stop to default repository, purging with default retention settings.

`vzborg restore --backup vzborg-300-2020_03_20-13_11_46.vma --new-id 1300 --storage local_lvm`

Restore VM from backup with name vzborg-300-2020_03_20-13_11_46.vma as VM with ID 1300 to storage local_lvm.

`vzborg restore --id 102 --storage local_lvm --force`

Restore last backup of VM 102 forcing overwrite if guest exists.

`vzborg list`

List all backups in the default repository.

`vzborg list --id 303 --repository ssh://example.com:22/mnt/remote_borg_repo`

List all backups of guest with ID 303 existing on remote repository ssh://example.com:22/mnt/remote_borg_repo

`vzborg list --id '1230 1040 2077' --repository /mnt/vzborg`

List all backups of guests with IDs 1230, 1040 and 2077 existing in local repository /mnt/vzborg


`vzborg getdump --backup vzborg-13998-2020_03_20-13_08_35.tar --storage backups`

Recreate from backup name vzborg-13998-2020_03_20-13_08_35.tar an lxc dump file in PVE storage backups 
(the file will be recreated as the compressed file vzdump-lxc-13998-2020_03_20-13_08_35.tar.lzo)

`vzborg purge --id '101 102 307'`

Purge backups of guests with IDs 101, 102 and 307, on default repository, using default retentions.

`vzborg purge --id all --keep-last=2`

Purge backups keeping only the last 2 of each guest.

`vzborg purge --id '101 102 307' --keep-weekly=4 --keep-monthly=6 --keep-yearly=2`

Purge backups of guests with IDs 101, 102 and 307 on default repository, keeping 4 weekly, 6 monthly and 2 yearly backups.

## License
Licensed under GNU Affero General Public License, version 3.

## Feedback, bug-reports, requests, ...
They are welcome [here!](https://github.com/g3492/vzborg/issues)

## Important note
VzBorg is under development. Use it at your own risk.