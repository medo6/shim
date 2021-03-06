#!/bin/bash

## --
## -- - read_* - --
## --

HOST=localhost
PORT=8088
HTTP_AUTH=homer:elmo

SHIM_DIR=$(mktemp --directory)
CURL="curl --digest --user $HTTP_AUTH --write-out %{http_code} --silent"
NO_OUT="--output /dev/null"
SHIM_URL="http://$HOST:$PORT"
# SCIDB_AUTH="user=root&password=Paradigm4"

set -o errexit

function cleanup {
    ## Cleanup
    kill -s SIGKILL %1
    rm --recursive $SHIM_DIR
}

trap cleanup EXIT


## Setup
mkdir --parents $SHIM_DIR/wwwroot
echo $HTTP_AUTH > $SHIM_DIR/wwwroot/.htpasswd
./shim -p $PORT -r $SHIM_DIR/wwwroot -f &
sleep 1


## 1. Execute query with save
## - Prep
res=$($CURL --output $SHIM_DIR/id "$SHIM_URL/new_session?$SCIDB_AUTH")
test "$res" == "200"
ID=$(<$SHIM_DIR/id)
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=csv")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "200"

res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=(string,int64,int64,string,bool,bool,string)")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

## - Cleanup
res=$($CURL "$SHIM_URL/release_session?id=$ID")
test "$res" == "200"


## 2. Execute query with save and multiple reads
## - Prep
res=$($CURL --output $SHIM_DIR/id "$SHIM_URL/new_session?$SCIDB_AUTH")
test "$res" == "200"
ID=$(<$SHIM_DIR/id)
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=csv")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "200"

res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=(string,int64,int64,string,bool,bool,string)")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

## - Cleanup
res=$($CURL "$SHIM_URL/release_session?id=$ID")
test "$res" == "200"


## 3. Execute query with save and delayed reads
## - Prep
res=$($CURL --output $SHIM_DIR/id "$SHIM_URL/new_session?$SCIDB_AUTH")
test "$res" == "200"
ID=$(<$SHIM_DIR/id)
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=csv")
test "$res" == "200"
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "200"

res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=(string,int64,int64,string,bool,bool,string)")
test "$res" == "200"
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

## - Cleanup
res=$($CURL "$SHIM_URL/release_session?id=$ID")
test "$res" == "200"


## 4. Execute multiple queries with save and delayed reads
## - Prep
res=$($CURL --output $SHIM_DIR/id "$SHIM_URL/new_session?$SCIDB_AUTH")
test "$res" == "200"
ID=$(<$SHIM_DIR/id)
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=csv")
test "$res" == "200"
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()")
test "$res" == "200"
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=csv")
test "$res" == "200"
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "200"

res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=(string,int64,int64,string,bool,bool,string)")
test "$res" == "200"
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()")
test "$res" == "200"
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=(string,int64,int64,string,bool,bool,string)")
test "$res" == "200"
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"


## - Cleanup
res=$($CURL "$SHIM_URL/release_session?id=$ID")
test "$res" == "200"


## 5. Execute query without save
## - Prep
res=$($CURL --output $SHIM_DIR/id "$SHIM_URL/new_session?$SCIDB_AUTH")
test "$res" == "200"
ID=$(<$SHIM_DIR/id)
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()")
test "$res" == "200"
err="Output not saved410"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "$err"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "$err"

## - Cleanup
res=$($CURL "$SHIM_URL/release_session?id=$ID")
test "$res" == "200"


## 6. Read empty result
## - Prep
res=$($CURL --output $SHIM_DIR/id "$SHIM_URL/new_session?$SCIDB_AUTH")
test "$res" == "200"
ID=$(<$SHIM_DIR/id)
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=csv")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "200"

err="Output not saved in binary format416"
res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "$err"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "200"

res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=(string,int64,int64,string,bool,bool,string)")
test "$res" == "200"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

err="Output not saved in text format416"
res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "$err"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

## - Cleanup
res=$($CURL "$SHIM_URL/release_session?id=$ID")
test "$res" == "200"


## 7. Read n bytes then n lines from empty result
## - Prep
res=$($CURL --output $SHIM_DIR/id "$SHIM_URL/new_session?$SCIDB_AUTH")
test "$res" == "200"
ID=$(<$SHIM_DIR/id)
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=csv")
test "$res" == "200"
err="EOF - range out of bounds416"

res=$($CURL "$SHIM_URL/read_lines?id=$ID&n=10")
test "$res" == "$err"

res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=list()&save=(string,int64,int64,string,bool,bool,string)")
test "$res" == "200"
err="EOF - range out of bounds416"

res=$($CURL "$SHIM_URL/read_bytes?id=$ID&n=10")
test "$res" == "$err"

## - Cleanup
res=$($CURL "$SHIM_URL/release_session?id=$ID")
test "$res" == "200"


## 8. Read lines from non-empty result
## - Prep
res=$($CURL --output $SHIM_DIR/id "$SHIM_URL/new_session?$SCIDB_AUTH")
test "$res" == "200"
ID=$(<$SHIM_DIR/id)
res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=build(<x:int64>\[i=0:2\],i)&save=csv")
out="0
1
2
200"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "$out"

err="Output not saved in binary format416"
res=$($CURL "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "$err"

res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "$out"

res=$($CURL $NO_OUT "$SHIM_URL/execute_query?id=$ID&query=build(<x:int64>\[i=0:2\],i)&save=(int64)")

res=$($CURL $NO_OUT "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

err="Output not saved in text format416"
res=$($CURL "$SHIM_URL/read_lines?id=$ID")
test "$res" == "$err"

res=$($CURL $NO_OUT "$SHIM_URL/read_bytes?id=$ID")
test "$res" == "200"

## - Cleanup
res=$($CURL $NO_OUT "$SHIM_URL/release_session?id=$ID")
test "$res" == "200"


echo "PASS"
exit 0
