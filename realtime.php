<!doctype html>
<html lang="ja"><meta charset="utf-8"><body>
<?php
date_default_timezone_set("Asia/Tokyo");
echo "<p>".date('jS/M/Y H:i:sT')."</p>";
$line = @file('/var/log/nginx/access.log', FILE_IGNORE_NEW_LINES);
$eol = count($line);
for($i=1;$i<=$eol;$i++) {
  $log = explode('"',$line[$i]);
  $break = explode(" ",$log[0]);
  $address = trim($break[1]);
  $referer = trim($log[3]);
  $agent = trim($log[5]);
  $list[$address] = $list[$address].$referer." ".$agent."@@@";
}
echo "<div style='width:90%; margin:auto; padding:0.5em 1em; height:40em; border:solid 1px #000; overflow-y:auto;'><ul>";
foreach($list as $address => $value) {
  $array = explode("@@@",$value);
  $uniq = array_count_values($array);
  $string = "";
  foreach($uniq as $key => $data) {
    if($key != "") {
      $string = $string."[".$data."] ".$key."<br>";
    }
  }
//  $command = "host ".$address;
//  $result = exec($command);
  echo "<li>".$address."<br>".$string."</li>";
}
echo "</ul></div>";
?>
</body></html>
