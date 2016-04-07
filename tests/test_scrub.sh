#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2015-07-28 18:47:41 +0100 (Tue, 28 Jul 2015)
#
#  https://github.com/harisekhon/tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

test_num="${1:-}"
parallel=""
if [ "$test_num" = "p" ]; then
    parallel="1"
    test_num=""
fi

cd "$srcdir/..";

. ./tests/utils.sh

src[0]="2015-11-19 09:59:59,893 - Execution of 'mysql -u root --password=somep@ssword! -h myHost.internal  -s -e \"select version();\"' returned 1. ERROR 2003 (HY000): Can't connect to MySQL server on 'host.domain.com' (111)"
dest[0]="2015-11-19 09:59:59,893 - Execution of 'mysql -u root --password=<password> -h <fqdn>  -s -e \"select version();\"' returned 1. ERROR 2003 (HY000): Can't connect to MySQL server on '<fqdn>' (111)"

src[1]="2015-11-19 09:59:59 - Execution of 'mysql -u root --password=somep@ssword! -h myHost.internal  -s -e \"select version();\"' returned 1. ERROR 2003 (HY000): Can't connect to MySQL server on 'host.domain.com' (111)"
dest[1]="2015-11-19 09:59:59 - Execution of 'mysql -u root --password=<password> -h <fqdn>  -s -e \"select version();\"' returned 1. ERROR 2003 (HY000): Can't connect to MySQL server on '<fqdn>' (111)"

src[2]='File "/var/lib/ambari-agent/cache/common-services/RANGER/0.4.0/package/scripts/ranger_admin.py", line 124, in <module>'
dest[2]='File "/var/lib/ambari-agent/cache/common-services/RANGER/0.4.0/package/scripts/ranger_admin.py", line 124, in <module>'

src[3]='File "/usr/lib/python2.6/site-packages/resource_management/libraries/script/script.py", line 218, in execute'
dest[3]='File "/usr/lib/python2.6/site-packages/resource_management/libraries/script/script.py", line 218, in execute'

src[4]='resource_management.core.exceptions.Fail: Ranger Database connection check failed'
dest[4]='resource_management.core.exceptions.Fail: Ranger Database connection check failed'

src[5]='21 Sep 2015 02:28:45,580  INFO [qtp-ambari-agent-6292] HeartBeatHandler:657 - State of service component MYSQL_SERVER of service HIVE of cluster ...'
dest[5]='21 Sep 2015 02:28:45,580  INFO [qtp-ambari-agent-6292] HeartBeatHandler:657 - State of service component MYSQL_SERVER of service HIVE of cluster ...'

src[6]='21 Sep 2015 14:54:44,811  WARN [ambari-action-scheduler] ActionScheduler:311 - Operation completely failed, aborting request id:113'
dest[6]='21 Sep 2015 14:54:44,811  WARN [ambari-action-scheduler] ActionScheduler:311 - Operation completely failed, aborting request id:113'

src[7]="curl  -iuadmin:'mysecret' 'http://myServer:8080/...'"
dest[7]="curl  -iu<user>:<password> 'http://<hostname>:8080/...'"

src[8]="curl  -u admin:mysecret 'http://myServer:8080/...'"
dest[8]="curl  -u <user>:<password> 'http://<hostname>:8080/...'"

src[9]="curl  -u admin:'my secret' 'http://myServer:8080/...'"
dest[9]="curl  -u <user>:<password> 'http://<hostname>:8080/...'"

src[10]="curl  -u admin:\"my secret\" 'http://myServer:8080/...'"
dest[10]="curl  -u <user>:<password> 'http://<hostname>:8080/...'"

src[11]="curl -u=admin:'mysecret' 'http://myServer:8080/...'"
dest[11]="curl -u=<user>:<password> 'http://<hostname>:8080/...'"

src[12]=" main.py:74 - loglevel=logging.INFO"
dest[12]=" main.py:74 - loglevel=logging.INFO"

# creating an exception for this would prevent scrubbing legitimate .PY domains after a leading timestamp, which is legit, added main.py to 
src[13]="INFO 1111-22-33 44:55:66,777 main.py:8 -  Connecting to Ambari server at https://ip-1-2-3-4.eu-west-1.compute.internal:8440 (1.2.3.4)"
dest[13]="INFO 1111-22-33 44:55:66,777 main.py:8 -  Connecting to Ambari server at https://<fqdn>:8440 (<ip>)"

src[14]=" Connecting to Ambari server at https://ip-1-2-3-4.eu-west-1.compute.internal:8440 (1.2.3.4)"
dest[14]=" Connecting to Ambari server at https://<fqdn>:8440 (<ip>)"

src[15]="INFO 2015-12-01 19:52:21,066 DataCleaner.py:39 - Data cleanup thread started"
dest[15]="INFO 2015-12-01 19:52:21,066 DataCleaner.py:39 - Data cleanup thread started"

src[16]="INFO 2015-12-01 22:47:42,273 scheduler.py:287 - Adding job tentatively"
dest[16]="INFO 2015-12-01 22:47:42,273 scheduler.py:287 - Adding job tentatively"

src[17]="/usr/hdp/2.3.0.0-2557"
dest[17]="/usr/hdp/2.3.0.0-2557"

# can't safely prevent this without potentially exposing real IPs
#src[18]="/usr/hdp/2.3.0.0"
#dest[18]="/usr/hdp/2.3.0.0"

src[19]="ranger-plugins-audit-0.5.0.2.3.0.0-2557.jar"
dest[19]="ranger-plugins-audit-0.5.0.2.3.0.0-2557.jar"

src[20]="yarn-yarn-resourcemanager-ip-172-31-1-2.log"
dest[20]="yarn-yarn-resourcemanager-<aws_hostname>.log"

test_scrub(){
    src="$1"
    dest="$2" 
    #[ -z "${src[$i]:-}" ] && { echo "skipping test $i..."; continue; }
    result="$($perl -T $I_lib ./scrub.pl -ae <<< "$src")"
    if grep -Fq "$dest" <<< "$result"; then
        echo "SUCCEEDED scrubbing test $i"
    else
        echo "FAILED to scrub line during test $i"
        echo "input:    $src"
        echo "expected: $dest"
        echo "got:      $result"
        exit 1
    fi
}

if [ -n "$test_num" ]; then
    grep -q '^[[:digit:]]\+$' <<< "$test_num" || { echo "invalid test '$test_num', not a positive integer"; exit 2; }
    i=$test_num
    [ -n "${src[$i]:-}" ]  || { echo "invalid test number given: src[$i] not defined"; exit 1; }
    [ -n "${dest[$i]:-}" ] || { echo "code error: dest[$i] not defined"; exit 1; }
    test_scrub "${src[$i]}" "${dest[$i]}"
    exit 0
fi

# suport sparse arrays so that we can easily comment out any check pair for convenience
# this gives the number of elements and prevents testing the last element(s) if commenting something out in the middle
#for (( i = 0 ; i < ${#src[@]} ; i++ )); do
for i in ${!src[@]}; do
    [ -n "${src[$i]:-}" ]  || { echo "code error: src[$i] not defined";  exit 1; }
    [ -n "${dest[$i]:-}" ] || { echo "code error: dest[$i] not defined"; exit 1; }
    if [ -n "$parallel" ]; then
        test_scrub "${src[$i]}" "${dest[$i]}" &
    else
        test_scrub "${src[$i]}" "${dest[$i]}"
    fi
done

# test ip prefix
src="4.3.2.1"
dest="<ip_prefix>.1"
result="$($perl -T $I_lib ./scrub.pl --ip-prefix <<< "$src")"
if grep -Fq "<ip_prefix>.1" <<< "$result"; then
    echo "SUCCEEDED scrubbing test ip_prefix"
else
    echo "FAILED to scrub line during test ip_prefix"
    echo "input:    $src"
    echo "expected: $dest"
    echo "got:      $result"
    exit 1
fi

if [ -n "$parallel" ]; then
    # can't trust exit code for parallel yet, only for quick local testing
    exit 1
#    for i in ${!src[@]}; do
#        let j=$i+1
#        wait %$j
#        [ $? -eq 0 ] || { echo "FAILED"; exit $?; }
#    done
fi
exit 0
