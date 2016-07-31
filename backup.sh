#!/bin/bash

#
# Simple script for creating file and database backups.
#
# Created by: Aram Boyajyan
# http://www.aram.cz/

# Load our configuration file.
script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_directory/backup.cfg"
output_destination="$backup_directory/$project_name-$date-output.txt"

# Add the "header" in output file.
echo "Generated on: $date" > $output_destination

# Zip the directory.
zip -r "$backup_directory/$project_name-$date-files.zip" $website >> "$output_destination"

# Backup the database.
if [ -z ${db_user+x} ] && [ -z ${db_pass+x} ]
then
  # Credentials are not provided. This will work if you added the credentials to
  # .my.cnf file instead of adding them to backup.cfg file.
  mysqldump $db_name > "$backup_directory/$project_name-$date-database.sql"
else
  # Database username and password were provided in the configuration file. This
  # is not the best practice for security purposes.
  mysqldump -u$db_user -p$db_pass $db_name > "$backup_directory/$project_name-$date-database.sql"
fi

# Zip the database dump and remove the uncompressed file once done.
zip "$backup_directory/$project_name-$date-database.zip" "$backup_directory/$project_name-$date-database.sql" >> "$output_destination"
rm "$backup_directory/$project_name-$date-database.sql"

# Do the same with the output file.
zip "$backup_directory/$project_name-$date-output.zip" "$output_destination" > /dev/null 2>&1
rm "$output_destination"

# Done!
echo '********************************************************************************'
echo 'Successfully backed up the files and the database to:'
echo "    $backup_directory/$project_name-$date-database.zip"
echo "    $backup_directory/$project_name-$date-files.zip"
echo "    $backup_directory/$project_name-$date-output.zip"
echo '********************************************************************************'
