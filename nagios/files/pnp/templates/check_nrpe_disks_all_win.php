<?php

#
# Pnp template for CheckDriveSize (NSClient++) checkcommand. Tested for NSClient++ 0.3.6 & 0.3.8
# Includes the possibility to choose if and how datasources are gathered.
# Exemple: $gather_graphs=1 means all percent datasources are plotted on a unique graph, while
# all bytes datasources are plotted on separate graphs.
# By Yannick Charton (tontonitch-pro@yahoo.fr)
# Based on Joerg Linge templates
#

#
# Define some colors ..
#

$_WARNRULE  = '#FFFF00';
$_CRITRULE  = '#FF0000';
$_MAXRULE   = '#000000';
$_AREA_PRCT = '#256aef';
$_AREA_BYTE = '#8FBC8F';
$_LINE      = '#000000';
$colors     = array("#FFD700","#DAA520","#A0522D","#800080",
"#CC3300","#CC3333","#CC3366","#CC3399","#CC33CC","#CC33FF",
"#336600","#336633","#336666","#336699","#3366CC","#3366FF",
"#33CC33","#33CC66","#609978","#922A99","#997D6D","#174099",
"#1E9920","#E88854","#AFC5E8","#57FA44","#FA6FF6","#008080",
"#D77038","#272B26","#70E0D9","#0A19EB","#E5E29D","#930526",
"#26FF4A","#ABC2FF","#E2A3FF","#808000","#000000","#00FAFA",
"#E5FA79","#F8A6FF","#FF36CA","#B8FFE7","#CD36FF");

#
# Define some functions ..
#

function size_to_bytes($cur_unit,$size)
{
 $convert = array(
    "B"  => 1, 
    "KB" => 1024, 
    "MB" => bcpow('1024', '2'), 
    "GB" => bcpow('1024', '3'), 
    "TB" => bcpow('1024', '4'), 
    "PB" => bcpow('1024', '5'), 
    "EB" => bcpow('1024', '6'), 
    "ZB" => bcpow('1024', '7'), 
    "YB" => bcpow('1024', '8'),
    "K"  => 1024, 
    "M"  => bcpow('1024', '2'), 
    "G"  => bcpow('1024', '3'), 
    "T"  => bcpow('1024', '4'), 
    "P"  => bcpow('1024', '5'), 
    "E"  => bcpow('1024', '6'), 
    "Z"  => bcpow('1024', '7'), 
    "Y"  => bcpow('1024', '8')
    );
 if(isset($convert["$cur_unit"])) {$size=$size*$convert["$cur_unit"];}
 return $size;
}

#
# Define some variables ..
#

## Parameters
$gather_graphs=1;   # 0: don't gather graphs
                    # 1: gather "percent" graphs
                    # 2: gather "percent" & "bytes" graphs
#Other variables
$num_graph=0;
$num_graph_percent=0;
$num_graph_bytes=0;
$for_check_command="CheckDriveSize (NSClient++)";

#
# Initial Logic ...
#

foreach($this->DS as $KEY => $VAL){
    $maximum  = "";
    $minimum  = "";
    $critical = "";
    $warning  = "";
    $vlabel   = "";
    $lower    = "";
    $upper    = "";

    if ($VAL['WARN'] != "")   {$warning = size_to_bytes($VAL['UNIT'],$VAL['WARN']);}
    if ($VAL['CRIT'] != "")   {$critical = size_to_bytes($VAL['UNIT'],$VAL['CRIT']);}
    if ($VAL['MIN'] != "")    {$lower = " --lower=" . $VAL['MIN']; $minimum = size_to_bytes($VAL['UNIT'],$VAL['MIN']);}
    if ($VAL['MAX'] != "")    {$maximum = size_to_bytes($VAL['UNIT'],$VAL['MAX']);}
    if ($VAL['UNIT'] == "%%") {$vlabel = "%"; $upper = " --upper=101 "; $lower = " --lower=0 ";}
        else                  {$vlabel = $VAL['UNIT'];}

    # Define the labels
    $label   = $VAL['LABEL'];
    $label_c = preg_replace("/:/","\:",rrd::cut($label, 20));

    # Percentage graph
    if($VAL['UNIT'] == '%%'){
        $num_graph++;
        if($gather_graphs > 0){
            if($num_graph_percent == 0){$num_graph_percent = $num_graph;}
            $ds_name[$num_graph_percent] = "Disk space usages (%)";
            $opt[$num_graph_percent] = '--vertical-label "%" -X0 --title "Disk space usages (%)" --rigid' . $upper . $lower;
            $opt[$num_graph_percent] .= ' --watermark="Template for '.$for_check_command.' by Yannick Charton"';
            if(!isset($def[$num_graph_percent])){$def[$num_graph_percent] = "";}
            $def[$num_graph_percent] .= rrd::def     ("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE");
            $def[$num_graph_percent] .= rrd::line1   ("var$KEY", $colors[$KEY], $label_c );
            $def[$num_graph_percent] .= rrd::gprint  ("var$KEY", array("LAST","MAX","AVERAGE"), "%5.2lf%%");
        }
        else{
            $ds_name[$num_graph] = "Disk space usages - $label";
            $opt[$num_graph] = '--vertical-label "%" -X0 --title "Disk space usages -  '.$label.'"  --rigid' . $upper . $lower;
            $opt[$num_graph] .= ' --watermark="Template for '.$for_check_command.' by Yannick Charton"';
            if(!isset($def[$num_graph])){$def[$num_graph] = "";}
            $def[$num_graph] .= rrd::def     ("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE");
            $def[$num_graph] .= rrd::area    ("var$KEY", $_AREA_PRCT, $label_c );
            $def[$num_graph] .= rrd::line1   ("var$KEY", $_LINE );
            $def[$num_graph] .= rrd::gprint  ("var$KEY", array("LAST","MAX","AVERAGE"), "%5.2lf%%");
            if ($warning != "") {
                $def[$num_graph] .= rrd::hrule($warning, $_WARNRULE, "Warning\:  $warning$vlabel \\n");
            }
            if ($critical != "") {
                $def[$num_graph] .= rrd::hrule($critical, $_CRITRULE, "Critical\: $critical$vlabel \\n");
            }
        }
    }
    #Bytes graphs
    elseif(($VAL['UNIT'] == 'B') || ($VAL['UNIT'] == 'K') || ($VAL['UNIT'] == 'M') || ($VAL['UNIT'] == 'G')){
        $num_graph++;
        if($gather_graphs > 1){
            if($num_graph_bytes == 0){$num_graph_bytes = $num_graph;}
            $ds_name[$num_graph_bytes] = "Disk space usages (Bytes)";
            $opt[$num_graph_bytes] = '--vertical-label "%" --title "Disk space usages (Bytes)" --lower=0';
            $opt[$num_graph_bytes] .= ' --watermark="Template for '.$for_check_command.' by Yannick Charton"';
            if(!isset($def[$num_graph_bytes])){$def[$num_graph_bytes] = "";}
            $multiplicator = size_to_bytes($VAL['UNIT'],1);
            $def[$num_graph_bytes] .= rrd::cdef    ("newvar$KEY", "var$KEY,$multiplicator,*" );
            $def[$num_graph_bytes] .= rrd::line1   ("newvar$KEY", $colors[$KEY], $label_c );
            $def[$num_graph_bytes] .= rrd::gprint  ("newvar$KEY", array("LAST","MAX","AVERAGE"), "%8.2lf%SB");
        }
        else{
            $num_graph++;
            $ds_name[$num_graph] = "Disk space usages - $label";
            $opt[$num_graph] = '--vertical-label "Bytes" --title "Disk space usages - '.$label.'" --lower=0';
            $opt[$num_graph] .= ' --watermark="Template for '.$for_check_command.' by Yannick Charton"';
            if(!isset($def[$num_graph])){$def[$num_graph] = "";}
            $def[$num_graph] .= rrd::def     ("var$KEY", $VAL['RRDFILE'], $VAL['DS'], "AVERAGE");
            $multiplicator = size_to_bytes($VAL['UNIT'],1);
            $def[$num_graph] .= rrd::cdef    ("newvar$KEY", "var$KEY,$multiplicator,*" );
            $def[$num_graph] .= rrd::area    ("newvar$KEY", $_AREA_BYTE, $label_c );
            $def[$num_graph] .= rrd::line1   ("newvar$KEY", $_LINE );
            $def[$num_graph] .= rrd::gprint  ("newvar$KEY", array("LAST","MAX","AVERAGE"), "%8.2lf%SB");
            if ($warning != "") {
                $def[$num_graph] .= rrd::hrule($warning, $_WARNRULE, "Warning\:  ".$VAL['WARN']."${vlabel}B \\n");
            }
            if ($critical != "") {
                $def[$num_graph] .= rrd::hrule($critical, $_CRITRULE, "Critical\: ".$VAL['CRIT']."${vlabel}B \\n");
            }
            if ($maximum != "") {
                $def[$num_graph] .= rrd::hrule($maximum, $_MAXRULE, "Maximum\:  ".$VAL['MAX']."${vlabel}B \\n");
            }
        }
    }
}

?>
