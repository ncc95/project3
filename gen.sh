

counts=0
counte=414
increment=$counte

rm -f run.sh
for i in `seq 1 40`;
do 


if [ $i == 40 ]; then counte=16569; fi
sed "s/seq 1/seq $counts $counte/g" master.sh > test$i.sh

chmod +x test$i.sh
echo "./"test$i.sh" > test$i.log 2>&1 &" >> run.sh

echo $i $counts $counte

counts=$(( counts=counte+1 ))
counte=$(( counte=counte+increment))

done

counts=0
