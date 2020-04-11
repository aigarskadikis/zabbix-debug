<?php

ini_set('display_errors', '1');

$cnf = [
                        'host' => 'ldaps://u18',
                        'port' => '636',
                        'bind_dn' => 'CN=LDAP Search,OU=UsersForZabbix,OU=TopSecret,DC=catonrug,DC=net',
                        'bind_password' => 'Abc12345',
                        'base_dn' => 'OU=UsersForZabbix,OU=TopSecret,DC=catonrug,DC=net',
                        'search_attribute' => 'sAMAccountName',
                        'userfilter' => '(%{attr}=%{user})',
                        'groupkey' => 'cn',
                        'mapping' => [
                                'alias' => 'uid',
                                'userid' => 'uidnumbera',
                                'passwd' => 'userpassword'
                        ],
                        'referrals' => 0,
                        'version' => 3,
                        'starttls' => null,
                        'deref' => null
                ];

$ds = ldap_connect($cnf['host'], $cnf['port']);


if (ldap_set_option($ds, LDAP_OPT_PROTOCOL_VERSION, $cnf['version'])) {      
	ldap_set_option(NULL, LDAP_OPT_DEBUG_LEVEL, 7);
    ldap_start_tls($ds);
    ldap_set_option($ds, LDAP_OPT_REFERRALS, $cnf['referrals']);
}

if (isset($cnf['deref'])) {
    ldap_set_option($ds, LDAP_OPT_DEREF, $cnf['deref']);
}

ldap_bind($ds, $cnf['bind_dn'], $cnf['bind_password']);

$sr = ldap_search($ds, $cnf['base_dn'], '(sAMAccountName=jacpzc)');
$result = is_resource($sr) ? ldap_get_entries($ds, $sr) : [];

print_r($result);

print 'All accounts';

$sr = ldap_search($ds, $cnf['base_dn'], '(sAMAccountName=*)');
$result = is_resource($sr) ? ldap_get_entries($ds, $sr) : [];

print_r($result)

?>
