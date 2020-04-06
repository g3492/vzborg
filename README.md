# vzborg utility
**Deduplicated, encrypted backups for the Proxmox Virtual Environment.**

With vzborg you can:
- Backup, restore, delete, list and mantain your backups in a flexible and efficient way.
- Use default retention settings to keep your desired number of hourly, daily, weekly, monthly and yearly backups.
- Set up automated backups to remote repositories, simply setting appropriate ssh keys.

Vzborg uses vzdump and [BorgBackup](https://www.borgbackup.org/) to allow deduplicated, compressed backups of Proxmox guests, in an optionally encrypted repository.

## Requirements
You need a proxmox 5.x or 6.x server with a suitable BorgBackup package installed. 

If you are in proxmox 6.x you can install BorgBackup with:

`apt install borgbackup`

If you are in proxmox 5.x you must enable stretch-backports repository and install Borg backup from it with:

`apt install -t stretch-backports borgbackup`

If you want to use a remote repository, you need borg backup installed on it, with the same or a greater version, than the one installed in your proxmox server. If your remote repository is in another proxmox server, you can also install vzborg on it.

## Installation
In your proxmox server run as root:

`wget -O - https://raw.githubusercontent.com/g3492/vzborg/master/install_and_update_vzborg.sh | bash`

## Usage:
`vzborg [OPTIONS]`

vzborg only uses options as parameters. Spcecified, but not used options, are ignored.

### Required option:

` -c COMMAND`

Where COMMAND is one of:

| Command   | Description                        |
|:----------|:-----------------------------------|
|  backup   |Perform a backup job.               |
|  delete   |Delete a specific backup.           |
|  discard  |Discard all backups of given guests.|
|  getdump  |Recreate a dump file from a backup. |
|  help     |Show vzborg help.                   |
|  list     |List backups in repository.         |
|  prune    |Prune (purge) repository.           | 
|  restore  |Restore backup from repository.     |
|  version  |Show vzborg, borg and pve version.  |
            

### Additional options
| Option          | Value      | Use                    |Description                        |
|:----------------|:-----------|:-----------------------|:-----------------------------------|
|-b (--backup)    |BACKUP_NAME |delete/restore          |Name of an existing backup (archive)|
|-d (--dry-run)   |            |backup/prune            |Just perform a simulation|
|-f (--force)     |            |restore                 |Force overwrite of existing VM/CT|
|-h (--help)      |            |all except help/version |Display command help. Requires -c option|
|-i (--id)        |VM_ID       |backup/discard/restore  |PVE VM/CT ID or list of PVE VM/CT IDs  |
|-k (--keep)      |RETENTION   |prune                   |List of retention settings |
|-m (--mode)      |MODE        |backup                  | vzdump mode (default = snapshot)|
|-r (--repository)|REPOSITORY  |all except help/version | Borg repository |
|-s (--storage)   |STORAGE     |getdump/restore         | Proxmox storage (default = local)|

### Configuration file:

 `/etc/vzborg.conf`

Edit before using vzborg, to customize defaults parameters.

### Backup names

vzborg creates backups encoding the guest ID and the backup time into the filename, for example:

`vzborg-104-2020_04_02-17_12_34.tar` for an lxc container

`vzborg-104-2020_04_02-17_15_11.vma` for a virtual machine

When recreating a Proxmox backup file (getdump command) vzborg will use the default PVE naming convention, for example:

`vzdump-lxc-104-2020_04_02-17_12_34.tar.lzo` for an lxc container

`vzdump-qemu-104-2020_04_02-17_15_11.vma.lzo` for a virtual machine


### Examples
`vzborg -c restore -h`

Show help about restore command.

`vzborg -c backup -i '101 102 307'`

Backup guests 101, 102 and 307 with default options.

`vzborg -c restore -b vzborg-300-2020_03_20-13_11_46.vma -i 1300 -s local_lvm`

Restore VM from backup with name vzborg-300-2020_03_20-13_11_46.vma as VM with ID 1300 to storage local_lvm.

`vzborg -c list`

List all backups in default repository.

`vzborg -c list -i 303 -r ssh://example.com:22/mnt/remote_borg_repo`

List all backups of guest with ID 303 existing on remote repository ssh://example.com:22/mnt/remote_borg_repo

`vzborg -c list -i '1230 1040 2077' -r /mnt/vzborg`

List all backups of guests with IDs 12030, 1040 and 2077 existing in local repository /mnt/vzborg


`vzborg -c getdump -b vzborg-13998-2020_03_20-13_08_35.tar -s backups`

Recreate from backup name vzborg-13998-2020_03_20-13_08_35.tar an lxc dump file in PVE storage backups (the file will be recreated as the compressed file vzdump-13998-2020_03_20-13_08_35.tar.lzo)

`vzborg -c prune -i '101 102 307'`

Prune or purge backups of guests with IDs 101, 102 and 307, on default repository, using default retentions.

`vzborg -c prune -i '101 102 307' -k '--keep-weekly=4 --keep-monthly=6 --keep-yearly=2'`

Prune or purge backups of guests with IDs 101, 102 and 307 on default repository, keeping 4 weekly, 6 monthly an 2 yearly backups.

## License
Licensed under GNU Affero General Public License, version 3.

## Feedback, bug-reports, requests, ...
They are welcome [here!](https://github.com/g3492/vzborg/issues)

## Important note
vzborg is alfa software under development. Use it at your own risk