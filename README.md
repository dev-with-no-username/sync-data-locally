# sync-data-locally

script to sync data locally between smartphone and pc, using FTP/FTPS protocol with "Wifi FTP Server" android app

## run

to run the script you have to execute the following command

```bash
make run
```

in which you can change the available flags:

```bash
./sync_data.sh -d "<smartphone_directory_you_wanna_copy>" -u "usb_device_in_which_copy_files_as_seen_by_linux"
```

so for example

```bash
./sync_data.sh -d "/DCIM/Documenti" -u "/dev/sdc1"
```

when running the script, first of all you have to enter username and password of "Wifi FTP Server" app,
that you will see in the app once started it

```text
Enter your username:
Enter your password:
```

and then the script does all the job autonomously
