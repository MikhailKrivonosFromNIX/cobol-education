#!/bin/bash

# Set up environment
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

# Check Java availability
java -version

# Change to the cobolcheck directory
cd cobolcheck
echo "Changed to $(pwd)"
ls -al

# Make cobolcheck executable
chmod +x ./cobolcheck
echo "Made cobolcheck executable"

cd scripts
chmod +x linux_gnucobol_run_tests
echo "Made linux_gnucobol_run_tests executable"
cd ..

# Function to run cobolcheck and copy files
run_cobolcheck() {
    program=$1
    echo "Running cobolcheck for $program"

    # Run cobolcheck, but don't exit if it fails
    #./cobolcheck -p $program
    java -jar bin/cobol-check-0.2.17.jar -p $program
    echo "Cobolcheck execution completed for $program (exceptions may have occured)"

    # Check if CC##99.CBL was created, regardless of cobolcheck exit status
    if [ -f "CC##99.CBL" ]; then
        # Copy to the MVS dataset
        if sudo cp CC##99.CBL "//\${ZOWE_USERNAME}.CBL($program)'"; then
            echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
        else
            "Failed to copy CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
        fi
    else
        echo "CC##99.CBL not found for $program"
    fi

    # Copy the JCL file if it exists
    if [ -f "${program}.JCL" ]; then
        if sudo cp ${program}.JCL "//'${ZOWE_USERNAME}.JCL($program)'"; then
            echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)"
        else
            echo "Failed to copy ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)"
        fi
    else
        echo "${program}.JCL not found"
    fi
}

# Run for each program
for program in NUMBERS; do 
    run_cobolcheck $program
done

echo "Mainframe operations compoleted"