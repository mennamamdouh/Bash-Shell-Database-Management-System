#!/bin/bash

dropDB(){
    read -p "Please Enter Database Name: " DBName
    if [[ -z $DBName ]]
    then
        echo "Input is empty."
        continue
    fi

    if [[ -e $DBDir/$DBName ]]
    then
        rm -rf "$DBDir/$DBName"
        echo "The selected database was deleted successfully."
    else
        echo "Database does not exist."
    fi
}

listDBs(){
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
    read -p "Please enter the database name: " ConDB
    if [[ -z $ConDB ]]
    then
        echo "Input is empty."
        continue
    fi

    if [[ -e "$DBDir/$ConDB" ]]
    then
        cd "$DBDir/$ConDB"
        echo "Database connected successfully."
        echo "In a few moments you'll be directed to the tables options..."
        sleep 3
        clear
        echo "Tables Options:"
        echo "---------------"
        displayTbOptions
    else
        echo "Database does not exist."
    fi
}

createDB(){
    read -p "Please enter database name: " DBName
    if [[ -z $DBName ]]
    then
        echo "Input is empty."
        continue
    fi
    
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