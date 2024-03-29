#!/bin/bash

# This file contains the main code of displaying the database options.
# Also, it has all the functions that are responsible of each functionality in the options.

dropDB(){
    while true
    do
        read -p "Please Enter Database Name: " DBName
        # Check first if the input is empty
        if [[ -z $DBName ]]
        then
            echo "Input is empty."
            continue
        else
            break
        fi
    done
    # Check if the targeted directory exists before removing the directory
    if [[ -e $DBDir/$DBName ]]
    then
        rm -rf "$DBDir/$DBName"
        echo "The selected database was deleted successfully."
    else
        echo "Database does not exist."
    fi
}

listDBs(){
    # Check if there're files in the databases directory
    if [[ -z "$(find "$DBDir" -mindepth 1 -maxdepth 1)" ]]
    then
        echo "There's no databases."
    else
        echo "Databases:"
        echo "----------"
        ls -d "$DBDir"/* | awk -F/ '{print $NF}'
    fi
}

connectDB(){
    while true
    do
        read -p "Please enter the database name: " ConDB
        # Check first if the input is empty
        if [[ -z $ConDB ]]
        then
            echo "Input is empty."
            continue
        else
            break
        fi
    done
    # Check if the targeted database exists before connecting/directing to it
    if [[ -e "$DBDir/$ConDB" ]]
    then
        cd "$DBDir/$ConDB"
        echo "Database connected successfully."
        echo "In a few moments you'll be directed to the tables options..."
        sleep 3
        clear
        echo "Tables Options:"
        echo "---------------"
        # Call the function which displays the tables options. This function is stored in tb-options.sh file
        displayTbOptions
    else
        echo "Database does not exist."
    fi
}

createDB(){
    while true
    do
        read -p "Please enter database name: " DBName
        # Check first if the input is empty
        if [[ -z $DBName ]]
        then
            echo "Input is empty."
            continue
        else
            # Check if the database name entered starts with anything rather than a letter
            if [[ ${DBName:0:1} == [[:alpha:]] ]]
            then
                break
            else
                echo "Database name shouldn't start with a number."
                continue
            fi
        fi
    done        

    # Check if the same directory name already exists which means that the database already exists
    if [[ ! -e "$DBDir/$DBName" ]]
    then
        mkdir "$DBDir/$DBName"
        echo "Database created successfully."
    else
        echo "Database already exists."
    fi
}

displayDbOptions(){
    PS3="
Enter a valid option number# "
    select option in "CREATE DATABASE" "CONNECT DATABASE" "SHOW DATABASES" "DROP DATABASE" "CLEAR" "Exit"
    do
        case $option in
            "CREATE DATABASE")
                createDB
            ;;

            "CONNECT DATABASE")
                connectDB
            ;;

            "SHOW DATABASES")
                listDBs
            ;;

            "DROP DATABASE")
                dropDB
            ;;

            "CLEAR")
                # Clear the terminal and show the welcoming message and database options again
                main_program
            ;;

            "Exit")
                echo "You have now ended the connection with our server".
                echo "GOOD BYE :)"
                exit;
            ;;
        
            *)
                echo "Please enter a valid option."
            ;;
        esac
    done
}

source tb-options.sh