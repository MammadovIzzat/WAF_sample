<?php
$_XSS_regex = "/<script.*?>.*?<\/script>|javascript:|on[a-z]+=|eval(.*?)|prompt|(?:https?|ftp)?:\/\/|((?:https?|ftp):)?\/\/|(?:mailto|file|data|javascript|vbscript|about|view-source):/i";

$memcached = new Memcached();
$memcached->addServer("127.0.0.1", 11211);
foreach ($_SERVER as $key => $value) {
    XSS_test($key);
    XSS_test($value);
}

function XSS_test($data) {
    global $_XSS_regex;
    $data = urldecode($data);
    if (preg_match($_XSS_regex, $data, $matches)) {
        $matched_data = $matches[0];
        XSS_logging($matched_data);
        print "You are blocked.";
        exit;
    }
}

function XSS_logging($matched_data) {
    global $memcached;
    $key = "xss_log_" . time(); 
    $logData = [
        'timestamp' => date("Y-m-d H:i:s"),
        'matched_data' => $matched_data,
        'ip' => $_SERVER['REMOTE_ADDR'],
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] 
    ];
    $memcached->set($key, json_encode($logData));
}
?>
