Facter.add("swapsize_b") do
        setcode do
                if File.exist?("/proc/swaps")
                        %x{ cat /proc/swaps | awk '{print $3}' | awk 'NR==2' }.chomp
		else
                end
        end
end
