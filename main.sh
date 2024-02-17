#!/bin/bash

checkDbDir(){
    if [[ ! -d databases/ ]]
    then
        mkdir databases
    fi
}

# Main program
main_program(){
    # Welcoming message
    clear
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Welcome to our Bash Shell Database Management System!<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo ""
    echo "Using this program you can retrieve and store your data on Hard-disk in an easy way."
    echo "We hope you enjoy your experience. If you face any issue, don't hesitate to contact our admins."
    echo "Admins: mennamamdouh@gmail.com - nourhanelsayed@gmail.com"
    echo ""
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ENJOY<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo ""

    # Start the program
    echo "Databases Options:"
    echo "------------------"
    DBDir=$(pwd)/databases
    displayDbOptions
}

# Check the required directory for the databases
checkDbDir

# Calling the main program
source db-options.sh
main_program