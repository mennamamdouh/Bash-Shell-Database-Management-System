#!/bin/bash

shopt -s extglob

listTBs(){
    DBName=$(pwd | awk -F/ '{print $NF}')
    if [[ -z "$(ls -p)" ]]
    then
        echo "There's no tables yet in ${DBName}."
    else
        echo "Tables:"
        echo "-------"
        ls -p | grep -v / | grep -v _META.txt | awk -F. '{print $1}'
    fi
}

deleteData(){
    read -p "Please enter the table name: " TBName
    if [[ -z $TBName ]]
    then
        echo "Input is empty."
        continue
    fi
    if [[ -e ${TBName}.txt ]]
    then
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
        sed -i "/${oldLine}/d" ${TBName}.txt
        echo "Data is deleted successfully."
    else
        echo "There's no table with the name ${TBName}."
    fi
}

updateData(){
    read -p "Please enter the table name: " TBName
    if [[ -z $TBName ]]
    then
        echo "Input is empty."
        continue
    fi
    if [[ -e ${TBName}.txt ]]
    then
        metaFileName="${TBName}_META.txt"
        columns=($(cat $metaFileName | cut -d: -f1))
        datatypes=($(cat $metaFileName | cut -d: -f2))
        for i in "${!columns[@]}"
        do
            while true
            do
                if [[ $i -eq 0 ]]
                then
                    read -p "Enter ${columns[i]} for the targeted record: " id
                    result=$(checkDataType ${id})
                    if [[ "${result}" != "invalid" ]]
                    then                    
                        count=$(awk -v pat="$id" -F: '$1 ~ pat { print $0 }' ${TBName}.txt | wc -l)
                        if [[ $count -ne 0 ]]
                        then
                            oldLine=$(awk -v pat="$id" -F: '$1 ~ pat { print $0 }' ${TBName}.txt)
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
                else
                    read -p "Enter new value for ${columns[i]}: " newValue
                    result=$(checkDataType ${newValue})
                    if [[ "${result}" != "invalid" ]]
                    then
                        newLine+=:${newValue}
                        break
                    else
                        echo "Unmatched data type of your input. You should enter ${datatypes[i]}."
                        continue
                    fi
                fi
            done
        done
        sed -i "s/${oldLine}/${newLine}/g" ${TBName}.txt
        echo "Data is updated successfully."
    else
        echo "There's no table with the name ${TBName}."
    fi
}

dropTB(){
    read -p "Please enter the table name: " TBName
    if [[ -z $TBName ]]
    then
        echo "Input is empty."
        continue
    fi
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
    read -p "Please enter the table name: " TBName
    if [[ -z $TBName ]]
    then
        echo "Input is empty."
        continue
    fi
    if [[ -e ${TBName}.txt ]]
    then
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
    read -p "Please enter the table name: " TBName
    if [[ -z $TBName ]]
    then
        echo "Input is empty."
        continue
    fi
    if [[ -e ${TBName}.txt ]]
    then
        metaFileName="${TBName}_META.txt"
        columns=($(cat $metaFileName | cut -d: -f1))
        datatypes=($(cat $metaFileName | cut -d: -f2))
        line=""
        for i in "${!columns[@]}"
        do
            while true
            do
                read -p "Enter ${columns[i]}: " data       
                result=$(checkDataType ${data})
                if [[ "${result}" != "invalid" ]]
                then
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
    read -p "Please enter table name: " TBName
    if [[ -z $TBName ]]
    then
        echo "Input is empty."
        continue
    fi
    if [[ -e ${TBName}.txt ]]
    then
        echo "Table already exists."
    else
        while true
        do
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
        metaFileName="${TBName}_META.txt"
        touch $metaFileName
        touch "${TBName}.txt"

        line=""
        echo "Enter the primary key's data"
        read -p "Name: " ColName
        line+=$ColName 
        read -p "DataType: " ColType 
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