#!/bin/bash

#TODO: Check the data types of the inserted data --> List of data types --> Check if the word contains characters - number - boolean - or both
#TODO: Back to database options (DONE)
#TODO: Password for databases

displayTbOptions() {
    select option in "CREATE TABLE" "INSERT INTO TABLE" "SHOW TABLES" "SELECT * FROM TABLE" "DROP TABLE" "DISCONNECT" "Exit"
    do
        case $option in
            "CREATE TABLE")
                read -p "Please enter table name: " TBName
                if [[ -e ${TBName}.txt ]]
                then
                    echo "Table already exists."
                else
                    read -p "Please enter the number of columns: " colNumber
                    metaFileName="${TBName}_META.txt"
                    touch $metaFileName
                    touch "${TBName}.txt"

                    for ((i=0; i<$colNumber; i++))
                    do
                        echo "Column number $((i+1)):"
                        line=""
                        read -p "Name: " ColName
                        line+=$ColName
                        read -p "DataType: " ColType
                        line+=:$ColType
                        echo $line >> $metaFileName
                        echo ""
                    done
                    echo "Table is created successfully."
                fi
            ;;

            "INSERT INTO TABLE")         
                read -p "Please enter the table name: " TBName
                if [[ -e ${TBName}.txt ]]
                then
                    metaFileName="${TBName}_META.txt"
                    result=$(cat $metaFileName | cut -d: -f1)
                    line=""
                    for i in $result
                    do
                        read -p "Enter $i: " data
                        line+=:$data
                    done
                    echo ${line:1} >> ${TBName}.txt
                    echo "Data is inserted successfully."
                else
                    echo "There's no table with the name ${TBName}."
                fi
            ;;

            "SHOW TABLES")
                DBName=$(pwd | awk -F/ '{print $NF}')
                if [ -z "$(ls -p)" ]
                then
                    echo "There's no tables yet in ${DBName}."
                else
                    echo "Tables:"
                    echo "-------"
                    ls -p | grep -v / | grep -v _META.txt | awk -F. '{print $1}'
                fi
            ;;

            "SELECT * FROM TABLE")
                read -p "Please enter the table name: " TBName
                if [[ -e ${TBName}.txt ]]
                then
                    metaFileName="${TBName}_META.txt"
                    result=$(cat $metaFileName | cut -d: -f1)
                    echo $result
                    cat ${TBName}.txt | awk -F: '{gsub(FS," ")} 1'
                else
                    echo "There's no table with the name ${TBName}."
                fi
            ;;
            
            "DROP TABLE")
                read -p "Please enter the table name: " TBName
                metaFileName="${TBName}_META.txt"
                if [[ -e ${TBName}.txt && -e ${metaFileName} ]]
                then
                    rm -f ${TBName}.txt
                    rm -f $metaFileName
                    if [[ $? -eq 0 ]]
                    then
                        echo "The selected table was deleted successfully."
                    fi
                else
                    echo "There's no table with the name ${TBName}."
                fi
            ;;

            "DISCONNECT")
                echo "Database disconnected successfully."
                echo "In a few moments you'll be directed to the databases options..."
                sleep 5
                cd ../..
                clear
                echo "Databases Options:"
                echo "------------------"
                displayDbOptions
                break;
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

displayDbOptions(){
    PS3="
Enter a valid option number# "
    select option in "CREATE DATABASE" "CONNECT DATABASE" "SHOW DATABASES" "DROP DATABASE" "Exit"
    do
        case $option in
            "CREATE DATABASE")
                read -p "Please enter database name: " DBName
                if [ -z $DBName ]
                then
                    echo "Input is empty."
                    continue
                fi
                
                if [ ! -e databases/$DBName ]
                then
                    mkdir databases/$DBName
                    echo "Database created successfully."
                else
                    echo "Database already exists."
                fi
            ;;

            "CONNECT DATABASE")
                read -p "Please enter the database name: " ConDB
                if [ -z $ConDB ]
                then
                    echo "Input is empty."
                    continue
                fi

                if [ -e databases/$ConDB ]
                then
                    cd databases/$ConDB
                    echo "Database connected successfully."
                    echo "In a few moments you'll be directed to the tables options..."
                    sleep 5
                    clear
                    echo "Tables Options:"
                    echo "---------------"
                    displayTbOptions
                else
                    echo "Database does not exist."
                fi
            ;;

            "SHOW DATABASES")
                if [ -z "$(find databases -mindepth 1 -maxdepth 1)" ]
                then
                    echo "There's no databases."
                else
                    echo "Databases:"
                    echo "----------"
                    ls -d databases/* | awk -F/ '{print $2}'                    
                fi
            ;;

            "DROP DATABASE")
                read -p "Please Enter Database Name: " DBName
                if [ -z $DBName ]
                then
                    echo "Input is empty."
                    continue
                fi

                if [ -e databases/$DBName ]
                then
                    rm -rf databases/$DBName
                    echo "The selected database was deleted successfully."
                else
                    echo "Database does not exist."
                fi
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

checkDbDir(){
    if [[ ! -d databases/ ]]
    then
        mkdir databases
        cd databases/
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
    checkDbDir
    displayDbOptions
}

# Calling the main program
main_program