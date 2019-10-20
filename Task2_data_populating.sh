#!/bin/bash


#moving to the directory where the .sql file exist
cd /mnt/e/ucd/bigdata/Project\ 1/Task2/test_db-master/test_db-master/

#changing the database name
sed 's/EXISTS employees;/EXISTS 17201082_db;/g' /mnt/e/ucd/bigdata/Project\ 1/Task2/test_db-master/test_db-master/employees.sql > employees_updated.sql
sed -i 's/USE employees;/USE 17201082_db;/' employees_updated.sql

#uploading database
mysql -h'127.0.0.1' -u root -pakashsri < employees_updated.sql

#populating mongodb from mysql
mysql -h'127.0.0.1' -u root -pakashsri 17201082_db -e "show tables;" > tables.csv
flag=0
IFSval=$IFS
for file in $(cat tables.csv)
do
        if [ $flag -ne 0 ]
                then
                mysql -h'127.0.0.1' -u root -pakashsri 17201082_db -e "desc $file;">table_str.tsv
                col_name=()
                col_data=()
                IFS=$'\n'
                flg=0
                for line in $(cat table_str.tsv)
                do

                        if [ $flg -ne 0 ]
                        then
                                col_name+=("$(echo $line|cut -d$'\t' -f1)")
                                col_data+=("$(echo $line|cut -d$'\t' -f2)")

                        else
                                flg=1
                        fi
                done
                flg1=0
                str="select json_object("
                i=0
                val=$((${#col_name[*]}-1))
                while [ $i -le $val ]
				  do
                        if [ $i -ne "$val" ]
                                then
                                str+="\"${col_name[$i]}\",${col_name[$i]},"
                                i=$(($i+1))
                        else
                                str+="\"${col_name[$i]}\",${col_name[$i]}"
                                i=$(($i+1))
                        fi
                done
                str+=") from $file;"
                mysql -h'127.0.0.1' -u root -pakashsri 17201082_db -e "$str">table_$file.js
                sed -i "s/^/db.$file.insert\(/g" table_$file.js
                sed -i "s/$/\)\;/g" table_$file.js
                sed -i "s/\"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ new Date(&/g" table_$file.js
                sed -i "s/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\"/&\)/g" table_$file.js
                tail -n+2 table_$file.js >$file.js
                mongo db1 --eval "db.$file.drop();"
                mongo db1 --eval "db.createCollection(\"$file\");"
                mongo db1<$file.js
                rm table_$file.js
                rm $file.js
                rm table_str.tsv
        else

                flag=1
        fi
done
rm tables.csv