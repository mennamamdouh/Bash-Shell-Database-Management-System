#!/bin/bash

# This file contains the main code of displaying the tables options.
# Also, it has all the functions that are responsible of each functionality in the options.
# Besides the tables functions, it has a function to check the data type of the inserted or updated data.

shopt -s extglob

listTBs(){
    # Retrieve the database's name
    DBName=$(pwd | awk -F/ '{print $NF}')
    # Check if its directory has any files or not
    if [[ -z "$(ls -p)" ]]
    then
        echo "There's no tables yet in ${DBName}."
    else
        # If files exist, print them
        echo "Tables:"
        echo "-------"
        ls -p | grep -v / | grep -v _META.txt | awk -F. '{print $1}'
    fi
}

deleteData(){
    while true
    do
        read -p "Please enter the table name: " TBName
        # Check first if the input is empty
        if [[ -z $TBName ]]
        then
            echo "Input is empty."
            continue
        else
            break
        fi
    done
    # Check if the same table/file exists or not
    if [[ -e ${TBName}.txt ]]
    then
        # Retrieve the columns' names and data types
        metaFileName="${TBName}_META.txt"
        columns=($(cat $metaFileName | cut -d: -f1))
        datatypes=($(cat $metaFileName | cut -d: -f2))
        while true
        do
            read -p "Enter ${columns[0]} for the targeted record: " id
            result=$(checkDataType ${id})
            if [[ "${result}" != "invalid" ]]
            then                    
                count=$(awk -v pat="$id" -F: '$1 ~ pat { print $0 }' ${TBName}.txt | wc -l)
                if [[ $count -ne 0 ]]
                then
                    # Fetch the record that has the ID which the user entered
                    oldLine=$(awk -v pat="$id" -F: '$1 ~ pat { print $0 }' ${TBName}.txt)
                    break
                else
                    echo "This value doesn't exist."
                    continue
                fi                                
            else
                echo "Unmatched data type of your input. You should enter ${datatypes[0]}."
                continue
            fi
        done
        # Remove the fetched line from the table's file
        sed -i "/${oldLine}/d" ${TBName}.txt
        echo "Data is deleted successfully."
    else
        echo "There's no table with the name ${TBName}."
    fi
}

updateData(){
    while true
    do
        read -p "Please enter the table name: " TBName
        # Check first if the input is empty
        if [[ -z $TBName ]]
        then
            echo "Input is empty."
            continue
        else
            break
        fi
    done
    # Check if the same table/file exists or not
    if [[ -e ${TBName}.txt ]]
    then
        # Retrieve the columns' names and data types
        metaFileName="${TBName}_META.txt"
        columns=($(cat $metaFileName | cut -d: -f1))
        datatypes=($(cat $metaFileName | cut -d: -f2))
        for i in "${!columns[@]}"
        do
            while true
            do
                # Get the ID or the PK column's value that the user wants to update
                if [[ $i -eq 0 ]]
                then
                    read -p "Enter ${columns[i]} for the targeted record: " id
                    result=$(checkDataType ${id})
                    if [[ "${result}" != "invalid" ]]
                    then                    
                        count=$(awk -v pat="$id" -F: '$1 ~ pat { print $0 }' ${TBName}.txt | wc -l)
                        if [[ $count -ne 0 ]]
                        then
                            # Fetch the record that has the ID which the user entered
                            oldLine=$(awk -v pat="$id" -F: '$1 ~ pat { print $0 }' ${TBName}.txt)
                            # Prepare the new line
                            newLine=${id}
                            break
                        else
                            echo "This value doesn't exist."
                            continue
                        fi                                
                    else
                        echo "Unmatched data type of your input. You should enter ${datatypes[i]}."
                        continue
                    fi
                # Gets the other columns' values and update them all
                else
                    read -p "Enter new value for ${columns[i]}: " newValue
                    result=$(checkDataType ${newValue})
                    if [[ "${result}" != "invalid" ]]
                    then
                        # Add the remaining data to the new line
                        newLine+=:${newValue}
                        break
                    else
                        echo "Unmatched data type of your input. You should enter ${datatypes[i]}."
                        continue
                    fi
                fi
            done
        done
        # Replace the old values with the new or updated values
        sed -i "s/${oldLine}/${newLine}/g" ${TBName}.txt
        echo "Data is updated successfully."
    else
        echo "There's no table with the name ${TBName}."
    fi
}

dropTB(){
    while true
    do
        read -p "Please enter the table name: " TBName
        # Check first if the input is empty
        if [[ -z $TBName ]]
        then
            echo "Input is empty."
            continue
        else
            break
        fi
    done
    # All we do here is removing the meta and data files of the targeted table
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
}

retrieveData(){
    while true
    do
        read -p "Please enter the table name: " TBName
        # Check first if the input is empty
        if [[ -z $TBName ]]
        then
            echo "Input is empty."
            continue
        else
            break
        fi
    done
    # Check if the same table/file exists or not
    if [[ -e ${TBName}.txt ]]
    then
        # Then print all its data after putting it in a user-friendly format if it contains data
        if [[ -z "$(cat ${TBName}.txt)" ]]
        then
            echo "There's no data yet in ${TBName}."
        else
            metaFileName="${TBName}_META.txt"
            result=$(cat $metaFileName | cut -d: -f1)
            echo $result
            cat ${TBName}.txt | awk -F: '{gsub(FS," ")} 1'
        fi
    else
        echo "There's no table with the name ${TBName}."
    fi
}

insertData(){
    while true
    do
        read -p "Please enter the table name: " TBName
        # Check first if the input is empty
        if [[ -z $TBName ]]
        then
            echo "Input is empty."
            continue
        else
            break
        fi
    done
    # Check if the same table/file exists or not
    if [[ -e ${TBName}.txt ]]
    then
        # Retrieves the columns' names and data types
        metaFileName="${TBName}_META.txt"
        columns=($(cat $metaFileName | cut -d: -f1))
        datatypes=($(cat $metaFileName | cut -d: -f2))
        line=""
        # Then take the value of each column, check its data type, and then append the data into the table's file
        for i in "${!columns[@]}"
        do
            while true
            do
                read -p "Enter ${columns[i]}: " data       
                result=$(checkDataType ${data})
                if [[ "${result}" != "invalid" ]]
                then
                    # This condition checks whether there're duplicates for the pk or not
                    if [[ $i -eq 0 ]]
                    then                      
                        count=$(awk -v pat="$data" -F: '$1 ~ pat { print $0 }' ${TBName}.txt | wc -l)
                        if [[ $count -eq 0 ]]
                        then
                            line+=:$data
                            break
                        else
                            echo "Duplicated value for the Primary Key."
                            continue
                        fi
                    fi
                    line+=:$data
                    break
                else
                    echo "Unmatched data type of your input. You should enter ${datatypes[i]}."
                    continue
                fi
            done
        done
        echo ${line:1} >> ${TBName}.txt
        echo "Data is inserted successfully."
    else
        echo "There's no table with the name ${TBName}."
    fi
}

createTB(){
    while true
    do
        read -p "Please enter table name: " TBName
        # Check first if the input is empty
        if [[ -z $TBName ]]
        then
            echo "Input is empty."
            continue
        else
            # Check if the table name entered starts with anything rather than a letter
            if [[ ${TBName:0:1} == [[:alpha:]] ]]
            then
                break
            else
                echo "Database name shouldn't start with a number."
                continue
            fi
        fi
    done
    # Check if the same table/file exists or not
    if [[ -e ${TBName}.txt ]]
    then
        echo "Table already exists."
    else
        while true
        do
            # Take the number of columns from the user and check its data type -> It has to be a "number"
            read -p "Please enter the number of columns: " colNumber
            result=$(checkDataType ${colNumber})
            if [[ "${result}" != "number" ]]
            then
                echo "Please enter a valid number."
                continue
            else
                break
            fi
        done
        # Create the meta file which has information about the columns of the table, their data types, and the column that is considered as primary key
        # and create the file which holds the data as well
        metaFileName="${TBName}_META.txt"
        touch $metaFileName
        touch "${TBName}.txt"

        # First, take the PK column's name and data type
        line=""
        echo "Enter the primary key's data"
        read -p "Name: " ColName
        line+=$ColName 
        read -p "DataType: " ColType
        # This loop validates the data type of the column
        while true
        do
            case $ColType in
                "number" | "varchar")
                    line+=":$ColType:PK"
                    echo $line >> $metaFileName
                    echo ""
                    break
                ;;

                *)
                    echo "Please enter one of the valid data types: number - varchar"
                    read -p "DataType: " ColType
                ;;
            esac
        done
        # After then, we take the remaining columns' names and data types and also validates their data types to be from the valid data types that we define
        for ((i=1; i<$colNumber; i++))
        do
            echo "Column number $((i+1)):"
            line=""
            read -p "Name: " ColName
            line+=$ColName
            read -p "DataType: " ColType
            while true
            do
                case $ColType in
                    "number" | "varchar")
                        line+=:$ColType
                        echo $line >> $metaFileName
                        echo ""
                        break
                    ;;

                    *)
                        echo "Please enter one of the valid data types: number - varchar"
                        read -p "DataType: " ColType
                    ;;
                esac
            done
        done
        echo "Table is created successfully."
    fi
}

checkDataType() {
    # Variable $1 represents the input that we want to check its data type
    case $1 in
        +([a-zA-Z]))
            echo "varchar"
        ;;

        +([1-9]))
            echo "number"
        ;;

        *)
            echo "invalid"
        ;;
    esac
}

displayTbOptions() {
    select option in "CREATE TABLE" "INSERT INTO TABLE" "SELECT * FROM TABLE" "DROP TABLE" "UPDATE TABLE" "DELETE FROM TABLE" "SHOW TABLES" "DISCONNECT" "Exit"
    do
        case $option in
            "CREATE TABLE")
                createTB
            ;;

            "INSERT INTO TABLE")         
                insertData
            ;;

            "SELECT * FROM TABLE")
                retrieveData
            ;;

            "DROP TABLE")
                dropTB
            ;;

            "UPDATE TABLE")         
                updateData
            ;;

            "DELETE FROM TABLE")
                deleteData
            ;;

            "SHOW TABLES")
                listTBs
            ;;

            "DISCONNECT")
                # This option redirects the user to the database options again after exit from the current connected database's directory
                echo "Database disconnected successfully."
                echo "In a few moments you'll be directed to the databases options..."
                sleep 3
                cd "$DBDir"
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