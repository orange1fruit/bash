#!/bin/bash
# script settings #
# source
source /scripts/backup/library
# archive path
ap="/mnt/archive/tgz/"
# temp file
tf="$ap/temp"
# currect date
cd=$(date +%d-%m-%Y)
# log
log="$ap/archive-zimbra-tgz-daily-log-$cd"
# cron
cron="$ap/cron"
# control of work
cow ()

    if [ $? -eq 0 ]; then
    echo -e "\n[OK]\n" >> "$log"
    else
    echo -e "\n[FAIL]\n" >> "$log"
    echo "The job archive-zimbra-tgz-daily was not executed. For more details, see the log" | /usr/bin/mutt -F /scripts/tgz/.muttrc -s "[Failed] The job archive-zimbra-tgz-daily was not executed" test@test.local -a $log
    fi

# script body #
echo "Start of job - $(date +%F) $(date +%T)" >> "$log"
# begin time
bt="$(date +%s)"
# Create list closed & locked mailbox
echo "Create list closed & locked mailbox" >> "$log"
su zimbra -c /opt/zimbra/bin/zmaccts | grep -E 'closed|locked' | awk 'print $1' | grep @ > "$tf"
cow
# create archive each mailbox
echo "create archive each mailbox" >> "$log"
for mb in $( cat $tf)
do
    echo "beginning create mailbox archive - $mb - $(date +%T)" >> "$log"
    # create folder for archive
    echo "create folder for archive $mb" >> "$log"
    mkdir "$ap/$mb"
    cow
    # save fullname
    echo "save fullname $mb"
    echo "save fullname $mb" >> "$log"
    su zimbra -c /opt/zimbra/bin/zmprov ga $mb | grep displayName >> "$ap/$mb/fullname-$mb.txt"
    cow    
    # account activation
    echo "account activation $mailbox"
    echo "account activation $mailbox" >> "$Log"
    su zimbra -c /opt/zimbra/bin/zmprov ma $mb zimbraAccountStatus active
    cow
    # Выполняем архивирование указанного почтового ящика 
    echo "Выполняем архивирование почтового ящика $mailbox"
    echo "Выполняем архивирование почтового ящика $mailbox" >> "$Log"
/opt/zimbra/bin/zmmailbox -z -m "$mailbox" getRestUrl "//?fmt=tgz"|pv > "$Path_backup/$mailbox/$mailbox.tgz"
complete
# Удаляем учётные записи, перенесённые в архив
echo "Выполняем удаление учётной записи $mailbox"
echo "Выполняем удаление учётной записи $mailbox" >> "$Log"
/opt/zimbra/bin/zmprov da "$mailbox"
complete
# Предоставление прав на папку архива $mailbox
echo "Предоставление прав на папку архива $mailbox"
echo "Предоставление прав на папку архива $mailbox" >> "$Log"
chmod -R 755 "$Path_backup/$mailbox"
complete
# Запись в итоговый лог $mailbox
echo "Запись в итоговый лог $mailbox"
Log_all="$Path_backup/archive"
echo "$mailbox - $DN deleted" >> "$Log_all"
complete
echo "Конец архивирования $mailbox - $(date +%T)" >> "$Log"
done
# Удаление временного файла
echo "Удаление временного файла"
echo "Удаление временного файла" >> $Log
rm $Path_backup/temp
complete
# Вычисление времени работы архива почтовых ящиков
End_time=$(date +%s)
Elapsed_time=$(expr $End_time - $Begin_time)
Hours=$(($Elapsed_time / 3600))
Elapsed_time=$(($Elapsed_time - $Hours * 3600))
Minutes=$(($Elapsed_time / 60))
Seconds=$(($Elapsed_time - $Minutes * 60))
echo "Затрачено времени на архивирование и удаление: $Hours час $Minutes минут $Seconds секунд"
echo "Затрачено времени на архивирование и удаление: $Hours час $Minutes минут $Seconds секунд" >> $Log