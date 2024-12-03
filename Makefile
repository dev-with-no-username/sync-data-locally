# run the script using FTPS protocol
run:
	chmod +x sync_data.sh
	sudo ./sync_data.sh -d "/DCIM/Documenti"

# run the script using FTP protocol
run-ftp:
	chmod +x sync_data_ftp.sh
	sudo ./sync_data_ftp.sh -d "/DCIM/Documenti"