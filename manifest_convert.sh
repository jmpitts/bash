#!/bin/bash
# Quick script to change display name in Munki manifest. Takes existing display name
# and included manifest values and processes them to create a new display name that 
# conforms to our naming convention using xmllint and xmlstartlet 
#
MAN=/this/is/your/manifest/directory/*
#
# Recursively checks every file in the manifests directory, ensures that it
# is a file and then checks the display name value for a space, continuing
# if one is found.
#
for f in $MAN
	do
		if [ -f "$f" ]; then
			DN=$(xmllint --xpath "//plist/dict/string[1]/text()" "$f")
				if [[ "$DN" =~ \ |\' ]]
					then
						# Get and set group variable by parsing included manifest, cutting via delimiters as necessary
						GP=$(xmllint --xpath "//plist/dict/array[2]/string[1]/text()" "$f" | cut -d '/' -f 2 | cut -d ' ' -f 1 | cut -d "-" -f 1)
						# Get and set first initial and last name by parsing existing display name, cutting via delimiters and, setting in all caps.
						FI=$(echo "$DN" | cut -d ' ' -f 1 | cut -c1 | tr '[:lower:]' '[:upper:]')
						LN=$(echo "$DN" | cut -d ' ' -f 2 | tr  '[:lower:]' '[:upper:]')
						# Set new display name
						xml ed -L -u "//plist/dict/string[1]" -v "$GP-$FI$LN-MBP" "$f"
						# Add new xml keys and values in proper order, temporary name has to be set as item is created and then item is renamed
						# after the value is added. This is all done sequentially in order to create and preserve proper XML hierarchy for Munki
						xml ed -L -s "/plist/dict" -t elem -n temp -v "" "$f"
						xml ed -L -u "/plist/dict/temp" -v "user" "$f"
						xml ed -L -r "/plist/dict/temp" -v "key" "$f"
						xml ed -L -s "/plist/dict" -t elem -n temp -v "" "$f"
						xml ed -L -u "/plist/dict/temp" -v "$DN" "$f"
						xml ed -L -r "/plist/dict/temp" -v "string" "$f"
						# Echo new display name, could be sent to text file to provide simple log to confirm proper naming in accordance with
						# our naming convention.
						echo "$GP-$FI$LN-MBP"
				fi
		fi
	done