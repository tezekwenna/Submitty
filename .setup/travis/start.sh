#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve
  # it relative to the path where the symlink file was located
  [[ ${SOURCE} != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source ${DIR}/../common/common_env.sh

echo "Starting selenium"
nohup bash -c "xvfb-run java -jar \"${SELENIUM_JAR}\" 2>&1 &"
sleep 5

wget --retry-connrefused --tries=5 --waitretry=5 --output-file=/dev/null "${SELENIUM_HUB_URL}/wd/hub/status" -O /dev/null
if [ ! $? -eq 0 ]; then
    echo "Selenium server not started."
else
    echo "Finished setup. Selenium server has started."
    wget -q -O - "$@" ${SELENIUM_HUB_URL}/wd/hub/status
    curl "http://localhost:4444/wd/hub/status"
fi