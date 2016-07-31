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

# Store the current directory. We need this so we can change the directory to
# the destination when we want to create zip files. This way the zip files we
# will generate will NOT contain the full path on the server.
pwd=$(pwd)

# Add the "header" in output file.
echo "Generated on: $date" > $output_destination

# Zip the directory.
cd "$website"
zip -r "$backup_directory/$project_name-$date-files.zip" ./ >> "$output_destination"

# Go back to the backup directory.
cd "$backup_directory"

# Backup the database.
if [ -z ${db_user+x} ] && [ -z ${db_pass+x} ]
then
  # Credentials are not provided. This will work if you added the credentials to
  # .my.cnf file instead of adding them to backup.cfg file.
  mysqldump $db_name > "$project_name-$date-database.sql"
else
  # Database username and password were provided in the configuration file. This
  # is not the best practice for security purposes.
  mysqldump -u$db_user -p$db_pass $db_name > "$project_name-$date-database.sql"
fi

# Zip the database dump and remove the uncompressed file once done.
zip "$project_name-$date-database.zip" "$project_name-$date-database.sql" >> "$output_destination"
rm "$project_name-$date-database.sql"

# Do the same with the output file.
zip "$project_name-$date-output.zip" "$output_destination" > /dev/null 2>&1
rm "$output_destination"

# Go back to the initial working directory.
cd "$pwd"

# Done!
echo '********************************************************************************'
echo 'Successfully backed up the files and the database to:'
echo "    $backup_directory/$project_name-$date-database.zip"
echo "    $backup_directory/$project_name-$date-files.zip"
echo "All output messages have been stored here:"
echo "    $backup_directory/$project_name-$date-output.zip"
echo '********************************************************************************'
