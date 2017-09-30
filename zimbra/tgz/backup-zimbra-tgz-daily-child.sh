#!/bin/bash
# backup each mailbox
    echo "backup $mb" >> "$log"
    /opt/zimbra/bin/zmmailbox -z -m "$mb" getRestUrl "//?fmt=tgz" > "$bp/$mb.tgz"
    cow
    echo "complete backup $mb" >> "$log"