#/bin/bash
export HOME=/var/lib/nagios
/usr/bin/printf "%b" "***** Nagios *****\n\nHost: $1 \nState: $2 \nInfo: $3" | /usr/bin/sendxmpp -c /var/lib/nagios/.sendxmpprc -r emea.nagios --chatroom it@conference.emea.akqa.local

