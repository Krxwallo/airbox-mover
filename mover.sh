#!/bin/bash

source_dir="/var/mobile/Containers/Data/Application/EEF046E5-C9AA-426A-B9F0-13BAB981B259/Documents/Inbox"
source_dir2="/var/mobile/Downloads/com.apple.AirDrop/"
# dest directory = current directory !!!

while true; do
  # Add number and move files to final dir
  for file in "$source_dir"/* "$source_dir2"/*/*/*; do
    if [ -f "$file" ]; then
      modified_time=$(stat -c %Y "$file")
      current_time=$(date +%s)
      time_difference=$((current_time - modified_time))

      if [ $time_difference -gt 1 ]; then
        # Transfer should have finished; move file
        filename=$(basename "$file")
        # File names should be "counting down", so they get sorted correctly in browser
        new_filename="$((3390263402 - $(date +%s)))_$filename"

        # .goodnotes files
        if [[ $file == *.goodnotes ]]; then
          echo "Found .goodnotes file: $file"
          unzip -q "$file" -d temp_extracted
          attachments_dir="temp_extracted/attachments"
          if [ -d "$attachments_dir" ]; then
            i=0
            for attachment_file in temp_extracted/attachments/*; do
              i=$((i+1))
              echo "Found attachment file $attachment_file ($i)"
              dest="$new_filename-attachment-$i.pdf"
              cp $attachment_file $dest
              echo "Copied attachment file to $dest"
              #dest="$((new_filename))_attachment_$i.pdf"
              #echo "Copying attachment file $i: $attachment_file -> $dest"
              #cp $attachment_file $dest
            done
          else
            echo "No attachments directory found in .goodnotes file!"
          fi
          rm -r temp_extracted
        fi # Move .goodnotes file aswell
        mv "$file" "$new_filename"
        echo "Moved $file to $new_filename"
        counter=$counter-1
      fi
    fi
  done

  # Move old files (older than 20min) from final dir to archive dir
  for file in *; do
    if [ -f "$file" ]; then
      modified_time=$(stat -c %Y "$file")
      current_time=$(date +%s)
      time_difference=$((current_time - modified_time))

      if [ $time_difference -gt 1200 ]; then
        archive_dir="archive"
        if [ ! -d "$archive_dir" ]; then
          mkdir -p "$archive_dir"
        fi
        mv "$file" "$archive_dir/"
        echo "Moved $file to $archive_dir/"
      fi
    fi
  done

  sleep 1  # Wait for 1 second before checking again
done
