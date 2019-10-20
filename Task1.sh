#!/bin/bash


cat book1.txt | tr -d '[:punct:]' |tr -s ' ' $'\n'> New_book1.txt
cat book2.txt | tr -d '[:punct:]' |tr -s ' ' $'\n'>> New_book1.txt
cat book3.txt | tr -d '[:punct:]' |tr -s ' ' $'\n'>> New_book1.txt
cat book4.txt | tr -d '[:punct:]' |tr -s ' ' $'\n'>> New_book1.txt
cat book5.txt | tr -d '[:punct:]' |tr -s ' ' $'\n'>> New_book1.txt
cat book6.txt | tr -d '[:punct:]' |tr -s ' ' $'\n'>> New_book1.txt



echo "Top 20 words in a Text:"
cat New_book1.txt |tr '[:upper:]' '[:lower:]'|sort |uniq -c  |sort -nr |head -20



grep -i -v -w -F -f stopwords.txt New_book1.txt>NoStop_book1.txt


echo "==================After Stop word removal==========================="
echo "Top 20 Words After Stop Word Removal"

cat NoStop_book1.txt |tr '[:upper:]' '[:lower:]'|sort |uniq -c |sort -nr |head -20                                             