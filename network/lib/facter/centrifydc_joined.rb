Facter.add("centrifydc_joined") do
        setcode do
                if File.exist?("/usr/bin/adinfo")
			%x{ CMD=$(adinfo | grep 'Joined to domain:' | awk '{print $4}'); if [ "$CMD" != "" ];then echo $CMD; else echo 'false'; fi }.chomp
                else

                end
        end
end
