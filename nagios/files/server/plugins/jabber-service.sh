#/bin/bash
export HOME=/var/lib/nagios

if [ "$4" == "OK" ]; then
 /usr/bin/printf "%b" "***** Smile baby, everything is fine *****\n\nNotification Type: $1 \nHost: $2 \nService: $3, State: $4\n" | /usr/bin/sendxmpp -c /var/lib/nagios/.sendxmpprc -r emea.nagios --chatroom it@conference.emea.akqa.local
else
 #/usr/bin/printf "%b" "***** Nagios *****\nNotification Type: $1 \nHost: $2 \nService: $3, State: $4\nInfo: $5\nDate/Time: $6" | /usr/bin/sendxmpp -c /var/lib/nagios/.sendxmpprc -r emea.nagios --chatroom it@conference.emea.akqa.local
 /usr/bin/printf "%b" "***** Nagios *****\nNotification Type: $1 \nHost: $2 \nService: $3, State: $4\n" | /usr/bin/sendxmpp -c /var/lib/nagios/.sendxmpprc -r emea.nagios --chatroom it@conference.emea.akqa.local
fi
