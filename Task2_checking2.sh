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
for file in $(cat tables.csv)
do
        if [ $flag -ne 0 ]
        then
                mysql -h'127.0.0.1' -u root -pakashsri 17201082_db -e "select * from $file">table_$file.tsv
                mysql -h'127.0.0.1' -u root -pakashsri 17201082_db -e "desc $file;">table_str.tsv
                col_name=()
                col_data=()
                IFS=$'\n'
                flg=0
                for line in $(cat table_str.tsv)
                do
                        if [ $flg -ne 0 ]
                        then
                                col_name+=("$(echo $line|cut -d'        ' -f1)")
                                col_data+=("$(echo $line|cut -d'        ' -f2)")
                        else
                                flg=1
                        fi
                done
                i=0
                head -1 table_$file.tsv>tmp.tsv
                tail -n +2 table_$file.tsv>tmp1.tsv
                while [ $i -lt "${#col_name[*]}" ]
                do
                        sed -i "s/${col_name[$i]}/${col_name[$i]}.${col_data[$i]}/" tmp.tsv
                        sed -i "s/${col_name[$i]}.char(.*)/${col_name[$i]}.string()/g" tmp.tsv
                        sed -i "s/${col_name[$i]}.int(.*)/${col_name[$i]}.int32()/g" tmp.tsv
                        sed -i "s/${col_name[$i]}.date/${col_name[$i]}.date(2006-01-02)/g" tmp.tsv
                        sed -i "s/${col_name[$i]}.varchar(.*)/${col_name[$i]}.string()/g" tmp.tsv
                        sed -i "s/${col_name[$i]}.enum(.*)/${col_name[$i]}.string()/g" tmp.tsv
                        i=$(($i+1))
                done
                cat tmp.tsv>table_$file.tsv
                cat tmp1.tsv>>table_$file.tsv
                mongoimport -d db1 -c $file --drop --type tsv --columnsHaveTypes --file table_$file.tsv --headerline
                rm tmp.tsv
                rm tmp1.tsv
        else
                flag=1
        fi
        rm table_$file.tsv
        rm table_str.tsv
done
rm tables.tsv