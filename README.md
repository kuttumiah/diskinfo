===============================================================================

                     _            _    _                  _          _
                    | |  __      |_|_ |_|_               |_|        | |
                    | | / / _  _ |_|_||_|_| _  _  __  __  _  _____  | |___
                    | |/ / | || || |  | |  | || || _\/_ || | \__  \ |  _  |
                    | |\ \ | || || |__| |__| || || |  | || | _/ __ \| | | |
                    |_| \_\|____||___/|___/|____||_|  |_||_|(____  /|_| |_|
                                                                \/
                                      DiskInfo Version 0.1
===============================================================================



diskinfo
========

This is a windows batch script solution to show disk space, used space and free space of a **Removable Disk**. This script is still in development stage. So, it is highly recommended not to use in production.

# Version 0.1
This is the most initial release of DiskInfo.

Usage
=====
In order to use DiskInfo Script you must call it from **cmd.exe** with Administrative Rights.

1. Run **cmd.exe** As Administrator.
2. Go to the directory where **diskInfo.bat** and **runadmin.vbs** is stored
3. Type **diskInfo \<Removable Device Name\>** and Press **Enter**
4. The result will be shown something like this...

```
TM = 3.76 GB
UM = 1.74 GB
FM = 2.03 GB
PR = 46%

This information also written into "DiskInfo.txt" in the specified disk.

Press any key to continue . . .
```
Here the terminology in used:
```
TM = Total Space
UM = Used Space
FM = Free Space
PR = Used Space in Percentage
```
