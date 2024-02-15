#!/bin/bash

displayTbOptions() {
    clear
    select option in CreateTB InsertTb ListTB SelectTB DeleteTB Exit
    do
        case $option in
            "CreateTB")
                read -p "Please Enter Table Name: " TBName
                read -p "Please Enter Column Numbers: " colNumber
  metaFileName=".${TBName}meta"
  touch "$metaFileName"
                touch $TBName

                for ((i=0; i<$colNumber; i++))
                do
                    line=""
                    read -p "Enter Column Name: " ColName
                    line+=$ColName
                    read -p "Enter Column DataType: " ColType
                    line+=:$ColType
                    echo $line >> $metaFileName
                done
                echo "Table is created"
                ;;
            "InsertTb")         
  read -p "Please Enter Table Name: " TBName
  metaFileName=".${TBName}meta"
                result=$(cat $metaFileName | cut -d: -f1)
                line=""
                for i in $result
                do
                    read -p "Please enter $i: " data
                    line+=:$data
                done
                echo ${line:1} >> $TBName
  echo The Data Inserted successfully
                ;;
           "ListTB")
  ls -p | grep -v /
  ;;
           "SelectTB")
  read -p "Please Enter Table Name: " TBName
                metaFileName=".${TBName}meta"
                result=$(cat $metaFileName | cut -d: -f1)
  echo $result 
  cat $TBName
  ;;
        "DeleteTB")
  read -p "Please Enter Table Name: " TBName
                metaFileName=".${TBName}meta"
  rm -f $TBName
  rm -f $metaFileName
  echo The selected Table Deleted successfully
  ;;
           "Exit")
         echo You have now ended the connection with the database.
  echo " GOOD BYE :)"
                break;
                ;;
            *)
                echo Please Enter a valid Option!!
                ;;

        esac
    done
}
PS3="Enter The OPtion Number# "
select option in CreateDB ConnectDB ListDB DeleteDB Exit
do
    case $option in
        "CreateDB")
            read -p "Please Enter Database Name: " DBName

            
            if [ -z $DBName ]
            then
                echo "Input is empty"
                continue
            fi

            
            if [ ! -e $DBName ]
            then
                mkdir $DBName
                echo "Database Created Successfully"
            else
                echo "Database is Already exist"
            fi
            ;;
        "ConnectDB")
            read -p "Please Enter Database Name: " ConDB
            if [ -z $ConDB ]
            then
                echo "Input is empty"
                continue
            fi
            if [ -e $ConDB ]
            then
                cd $ConDB
                echo "Database connected Successfully"
                displayTbOptions
            else
                echo "Database does not exist"
            fi
            ;;
    "ListDB")
     ls -d */
     ;;
    "DeleteDB")
     read -p "Please Enter Database Name: " DBName
     rm -rf $DBName
     echo The selected DataBase Deleted successfully
     ;;
      "Exit")
       echo "GOOD BYE :)"
            break;
            ;;
    *)
     echo Please Enter a valid Option!!
     ;;
    esac
done