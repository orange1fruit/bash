#!/bin/bash
# script settings #
# backup path
bp="/mnt/backup/tgz/"
# temp file
tf="$bp/temp"
# currect date
cd=$(date +%d-%m-%Y)
# log
log="$bp/backup-zimbra-tgz-daily-log-$cd"
# cron
cron="$bp/cron"
# max children
mc=5
# job counter
jcf ()
{
    jcv=`ps ax -Ao ppid | grep $$ | wc -l`
}
# control of work
cow ()
{
    if [ $? -eq 0 ]; then
    echo -e "\n[OK]\n" >> "$log"
    else
    echo -e "\n[FAIL]\n" >> "$log"
    echo "The job backup-zimbra-tgz-daily was not executed. For more details, see the log" | /usr/bin/mutt -F /scripts/tgz/.muttrc -s "[Failed] The job backup-zimbra-tgz-daily was not executed" test@test.local -a $log
    fi
}
# script body #
echo "Start of job - $(date +%F) $(date +%T)" >> "$log"
# begin time
bt="$(date +%s)"
# Create list closed & locked mailbox
echo "Create list active mailbox" >> "$log"
su zimbra -c /opt/zimbra/bin/zmaccts | grep active | awk '{print $1}' | grep @ > "$tf"
cow
# backup
for mb in $( cat $tf)
do
    jcf
    /scripts/tgz/backup-zimbra-tgz-daily-child.sh $mb $log $bp &
    while [ $jcv -ge $mc ]
    do
        jcf
        sleep 1
    done
    sleep 1 &
done
# delete temp file
echo "delete temp file" >> $log
rm $tf
cow
# technical information
uspbd=`df -h | grep sdd | grep -o -E "[0-9]{2}"`
fspbd=$((100 - $uspbd))
fsbd=`df -h | grep sdd | awk '{print $4}'`
uspsd=`df -h | grep store | awk '{print $5}' | grep -o -E "[0-9]{2}"`
fspsd=$((100 - $uspsd))
fssd=`df -h | grep store | awk '{print $4}'
# spent time
end_time=`date +%s`
elapsed_time=$(($end_time - $begin_time))
hours=$(($elapsed_time / 3600))
elapsed_time=$(($elapsed_time - $hours * 3600))
minutes=$(($elapsed_time / 60))
seconds=$(($elapsed_time - $minutes * 60))
total_time=`echo "Spent time on job $hours hours  $minutes minutes  $seconds seconds" | tee -a $log
# send mail with log
if [ $fspbd -lt 10 ]
then
body="The job backup-zimbra-tgz-daily is executed. For more details, see the log\n\n(!) Free space on backup datastore - ${fsbd} / ${fspbd}% (!)\n\nFree space on storage datastore - ${fssd} / ${fspsd}%&\n\n${total_time}"
head="[Warning] The job backup-zimbra-tgz-daily is executed"
elif [ $fspsd -lt 5 ]
then
body="The job backup-zimbra-tgz-daily is executed. For more details, see the log\n\nFree space on backup datastore - ${fsbd} / ${fspbd}%\n\n(!) Free space on storage datastore - ${fssd} / ${fspsd}% (!)\n\n${total_time}"
head="[Warning] The job backup-zimbra-tgz-daily is executed"
else
body="The job backup-zimbra-tgz-daily is executed. For more details, see the log\n\nFree space on backup datastore - ${fsbd} / ${fspbd}%\n\nFree space on storage datastore - ${fssd} / ${fspsd}%\n\n${total_time}"  
head="[Success] The job backup-zimbra-tgz-daily is executed"
fi
echo -e $body | /usr/bin/mutt -F /scripts/tgz/.muttrc -s "$head" test@test.local -a $log $cron

# orangefruit v0.5
