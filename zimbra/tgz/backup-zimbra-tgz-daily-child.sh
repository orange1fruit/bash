#!/bin/bash
# variables
mb=$1
log=$2
bp=$3
# control of work
cow ()
{
    log=$1
    if [ $? -eq 0 ]; then
    echo -e "\n[OK]\n" >> "$log"
    else
    echo -e "\n[FAIL]\n" >> "$log"
    echo "The job backup-zimbra-tgz-daily was not executed. For more details, see the log" | /usr/bin/mutt -F /scripts/tgz/.muttrc -s "[Failed] The job backup-zimbra-tgz-daily was not executed" test@test.local -a $2
    fi
}
# backup each mailbox
    echo "backup $mb" >> "$log"
    /opt/zimbra/bin/zmmailbox -z -m "$mb" getRestUrl "//?fmt=tgz" > "$bp/$mb.tgz"
    cow $log
    echo "complete backup $mb" >> "$log"

# orangefruit v0.5