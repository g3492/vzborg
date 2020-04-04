# vzborg utility
Backup, restore and mantain your Proxmox vzdupms in 
- Deduplicated
- Local or remote
- Optionally encrypted

borg repositories
## Requirements
You need a proxmox 5.x or 6.x, and a suitable borg backup package installed.

If you are in proxmox 5.x you must enable stretch-backports repository and install it with:

`apt install -t stretch-backports borgbackup`

If you are in proxmox 6.x you can just install it with:

`apt install borgbackup`

## Installation
ToDo
## Use
`vzborg -c help`

## License
Licensed under GNU Affero General Public License, version 3.

## Feedback, bug-reports, requests, ...
They are [welcome](https://github.com/g3492/vzborg/issues)!

## Important note
By now vzborg is alfa software. You can test it at your own risk