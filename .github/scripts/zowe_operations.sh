#!/bin/bash

# Convert username to lowercase
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Check if directory exists, create if it doesn't
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
	echo "Directory does not exist. Creating it..."
	zowe zos-files create uss-directory /z/$LOWERCASE_USERNAME/cobolcheck --zosmf-profile myprofile123
else
	echo "Directory already esizts."
fi

# Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" --zosmf-profile myprofile123
