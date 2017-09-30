# check of work
cow ()
{
    if [ $? -eq 0 ]; then
    echo -e "\n[OK]\n" >> "$log"
    else
    echo -e "\n[FAIL]\n" >> "$log"
    echo "The job backup-zimbra-tgz-daily was not executed. For more details, see the log" | /usr/bin/mutt -F /scripts/tgz/.muttrc -s "[Failed] The job backup-zimbra-tgz-daily was not executed" v.pupkin@test.local -a $log
    fi
}