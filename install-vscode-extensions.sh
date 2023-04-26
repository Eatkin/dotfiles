#!/bin/bash

# Read existing extensions from file
IFS=$'\n' read -d '' -r -a existing_extensions < vscode-extensions.txt

# Read new extensions from file
IFS=$'\n' read -d '' -r -a new_extensions < new-vscode-extensions.txt

# Loop through new extensions and add to file if not already present
for extension in "${new_extensions[@]}"; do
    if [[ ! " ${existing_extensions[@]} " =~ " ${extension} " ]]; then
        echo "$extension" >> vscode-extensions.txt
        echo "Added $extension to vscode-extensions.txt"
    fi
done

# Install VSCode extensions listed in a file (with confirmation)
while read extension; do
	# Check if already installed
	if code --list-extensions | grep -q "$extension"; then
		echo "$extension is already installed"
	else
		# Install (if wanted)
		read -p "Do you want to install $extension? (y/n) " choice
		case "$choice" in
			y|Y ) code --install-extension "$extension";;
			n|N ) echo "Skipping $extension";;
			* ) echo "Invalid options, skipping $extension";;
		esac
	fi
done < vscode-extensions.txt
