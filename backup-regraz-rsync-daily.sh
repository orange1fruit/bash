#!/bin/bash

#####################
# Настройки скрипта #
#####################

# Файл с переменными
source /scripts/pass
# log
log="/var/log/regraz-log-${cd}"
# Значение текущей даты
cd=$(date +%d-%m-%Y)
# check of work
cow ()      
{
    if [ $? -eq 0 ]; then
    echo -e "\n[OK]\n" >> "${log}"
    else
    echo -e "\n[FAIL]\n" >> "${log}"
    echo "The job backup-regraz-rsync-daily was not executed. For more details, see the log" | mutt -s "[Failed] Бекап Regraz не выполнен" it-report@ruan.local -b m.semashko@ruan.local -a ${Log}
    exit
    echo
    fi
}
################
# Тело скрипта #
################

echo "Начало бекапа - $(date +%F) $(date +%T)" >> "${Log}"
echo "" >> "${Log}"
# Запоминаем время начала бекапа
Begin_time="$(date +%s)"
# Монтирование //192.168.0.94/shares
echo "Монтирование //192.168.0.94/shares"
echo "Монтирование //192.168.0.94/shares" >> "${Log}"
mount.cifs //murzik.ruan.local/shares /mnt/shares/ -o username=backup,domain=ruan.local,password="${murzik}",guest
complete
# Бекапим /mnt/shares/Regraz/Экофин/БАЗА ДОГОВОРОВ
echo "Бекапим /mnt/shares/Regraz/Экофин/БАЗА ДОГОВОРОВ"
echo "Бекапим /mnt/shares/Regraz/Экофин/БАЗА ДОГОВОРОВ" >> "${Log}"
echo "" >> "${Log}"
sshpass -p "${k15backup}" rsync -cavP "/mnt/shares/Regraz/ЭкоФин/БАЗА ДОГОВОРОВ" k15backup@192.168.4.1:/home/k15backup >> "${Log}"
complete
# Бекапим /mnt/shares/Regraz/Экофин/REGIONS
echo "Бекапим /mnt/shares/Regraz/Экофин/REGIONS" >> "${Log}"
echo "Бекапим /mnt/shares/Regraz/Экофин/REGIONS"
echo "" >> "${Log}"
sshpass -p "${k15backup}" rsync -cavP "/mnt/shares/Regraz/ЭкоФин/REGIONS" k15backup@192.168.4.1:/home/k15backup >> "${Log}"
complete
# Размонтирование //192.168.0.94/shares
echo "Размонтирование //192.168.0.94/shares"
echo "Размонтирование //192.168.0.94/shares" >> "${Log}"
umount /mnt/shares/ 
complete
# Вычисление времени работы бекапа
End_time=$(date +%s)
Elapsed_time=$(expr ${End_time} - ${Begin_time})
Hours=$((${Elapsed_time} / 3600))
Elapsed_time=$((${Elapsed_time} - ${Hours} * 3600))
Minutes=$((${Elapsed_time} / 60))
Seconds=$((${Elapsed_time} - ${Minutes} * 60))
echo "Затрачено времени на бекап ${Hours} час ${Minutes} минут ${Seconds} секунд" >> ${Log}
# Отправка письма с отчётом
echo "Бекап Regraz выполнен. Для подробностей смотри лог" | mutt -s "[Success] Бекап Regraz выполнен" it-report@ruan.local -b m.semashko@ruan.local -a ${Log}