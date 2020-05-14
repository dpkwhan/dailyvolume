#!/bin/bash

usage() {
  echo "usage: fetch [[[-sd startDate ] [-ed endDate ] [-dd dataDir ]] | [-h]]"
}

log() {
    dateTime=$(date --rfc-3339=seconds)

    if [ -z "${1}" ]; then
        echo "${dateTime} - ERROR : LOGGING A MESSAGE"
        echo "${dateTime} - ERROR : INPUTS WERE: ${1}"
        exit 1
    fi

    logMessage="${1}"

    # Write log details to file
    echo "${dateTime}: ${logMessage}"
}

getYears() {
  local startDate=${1}
  local endDate=${2}
  local startYear=$((${startDate:0:4} + 0))
  local endYear=$((${endDate:0:4} + 0))

  years=()
  for (( y=$startYear; y<=$endYear; y++ ))
  do
    years+=($y)
  done
}

download() {
  year=${1}
  baseUrl="http://markets.cboe.com/us/equities/market_statistics/historical_market_volume"
  filename="market_history_${year}.csv"
  url="${baseUrl}/${filename}-dl"
  outfile="$dataDir/${filename}"
  cmd="curl $url -o $outfile"
  echo "cmd: $cmd"
  eval $cmd
}

while [ "$1" != "" ]; do
  case $1 in
    -sd | --startDate )
      shift
      startDate=$1
      ;;
    -ed | --endDate )
      shift
      endDate=$1
      ;;
    -dd | --dataDir )
      shift
      dataDir=$1
      ;;
    -h | --help )
      usage
      exit
      ;;
    * )
      usage
      exit 1
  esac
  shift
done

if [ -z "$endDate" ]; then
  endDate=$(date +%Y%m%d)
fi

if [ -z "$startDate" ]; then
  startDate=$(date -d "$endDate 7 day ago" +%Y%m%d)
fi

if [ -z "$dataDir" ]; then
  scriptDir=$(dirname "$0")
  dataDir="$scriptDir/data"
  if [[ ! -e $dataDir ]]; then
    mkdir -p $dataDir
  fi
fi

log "startDate=$startDate, endDate=$endDate, dataDir=$dataDir"

getYears $startDate $endDate

for y in "${years[@]}"
do
   download $y
done
