#!/bin/bash
for i in $1/*.jpg
do 
d=`identify -format "%w %h" $i`;
if [[ $d == "445 311" || $d == "1490 1040" || $d == "1482 1042" ]]
then convert -resize 400x279! -quality 95 $i $i
elif [[ $d == "223 310" ]]
then convert -crop 200x285+11+12 -quality 95 $i $i
elif [[ $d == "300 429" ]]
then convert -crop 278x407+10+13 -quality 95 $i $i
elif [[ $d == "1040 1490" || $d == "433 620" ]]
then convert -resize 300x429! -quality 100 $i $i; convert -crop 278x407+11+11 -quality 95 $i $i
elif [[ $d == "350 489" ]]
then convert -crop 316x455+17+17 -quality 100 $i $i; convert -resize 200x285! -quality 95 $i $i
elif [[ $d == "265 370" ]]
then convert -crop 239x344+13+13 -quality 100 $i $i; convert -resize 200x285! -quality 95 $i $i
fi
done
