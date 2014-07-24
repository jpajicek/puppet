
#!/bin/bash
echo
read -n1 -p "This is one-off first time run script to import Nagios host and service definitions into clean Nagios server install

Type 'Y' to continue:" 
echo
if [[ ! $REPLY == "Y" ]]
then
    exit 1
fi


cd /opt

if [ ! -d nagios ]; then
  git clone ssh://git@stash.akqa.net:7999/emeait/nagios.git nagios
else
  echo "Has someone already ran this script?...Not a clean install aborting!"
  exit 1
fi

if [ ! -d capistrano ]; then
  git clone ssh://git@stash.akqa.net:7999/emeait/capistano.git capistrano
else
  echo "Has someone already ran this script?...Not a clean install aborting!"
  exit 1
fi

echo -e "Importing hosts...\n"
cp -r nagios/etc/nagios3/conf.d/hosts/defined/* /etc/nagios3/conf.d/hosts/defined/

echo -e "Importing services...\n"
cp -r nagios/etc/nagios3/conf.d/services/defined/* /etc/nagios3/conf.d/services/defined/

echo -e "Importing gui defined object...\n"
cp -r nagios/etc/nagios3/gui /etc/nagios3/
chown nagios -R /etc/nagios3/gui

echo -e "Importing dependencies...\n"
cp -r nagios/etc/nagios3/conf.d/dependencies/* /etc/nagios3/conf.d/dependencies/

echo -e "Importing hostgroups...\n"
cp -r /opt/nagios/etc/nagios3/conf.d/hostgroups/defined/* /etc/nagios3/conf.d/hostgroups/defined/

echo -e "Importing servicegroups...\n"
cp -r /opt/nagios/etc/nagios3/conf.d/servicegroups/* /etc/nagios3/conf.d/servicegroups/

echo -e "Running pre-flight check...\n"
nagios3 -v /etc/nagios3/nagios.cfg

if [[ $? != 0 ]] ; then
    echo -e "\n\n\nSome problems were detected...happy fixing!\n"
fi
