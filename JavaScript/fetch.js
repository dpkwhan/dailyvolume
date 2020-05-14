const path = require('path');
const axios = require('axios');

const fs = require('fs-extra');
const writeFile = require('util').promisify(fs.writeFile);
const { createLogger, format, transports } = require('winston');
const argv = require('minimist')(process.argv.slice(2));

const logFormat = format.printf(
  (info) => `${info.timestamp} ${info.level} [${info.label}]: ${info.message}`
);
const logger = createLogger({
  format: format.combine(
    format.label({ label: 'DailyVolume' }),
    format.timestamp(),
    logFormat
  ),
  transports: [new transports.Console()],
});

async function download(baseURL, outfile) {
  logger.info(`Started downloading from ${baseURL}`);
  const api = axios.create({
    baseURL,
  });

  try {
    const res = await api.get();
    const fpath = path.dirname(outfile);
    fs.ensureDirSync(fpath);
    if (res.data) {
      await writeFile(outfile, res.data);
      logger.info(`Finished writing to ${outfile}`);
    } else {
      throw res.data;
    }
  } catch (error) {
    logger.error(`Failed in downloading from url: ${baseURL}`);
    logger.error(`Found error: ${error}`);
  }
}

function getFilepath() {
  return path.join(__dirname, 'data');
}

function getFilename(yyyy) {
  return `market_history_${yyyy}.csv`;
}

function downloadYear(yyyy) {
  const baseUrl = 'http://markets.cboe.com/us/equities/market_statistics';
  const url = `${baseUrl}/historical_market_volume`;
  const fname = getFilename(yyyy);
  const link = `${url}/${fname}-dl`;
  const fpath = getFilepath();
  const outfile = path.join(fpath, fname);
  download(link, outfile);
}

function getYears(startDate, endDate) {
  console.log(typeof startDate);
  console.log(typeof endDate);
  const startYear = +startDate.toString().slice(0, 4);
  const endYear = +endDate.toString().slice(0, 4);
  const years = [];
  for (let year = startYear; year <= endYear; year += 1) {
    years.push(year);
  }
  return years;
}

const d = new Date();
const endDate = argv.endDate === undefined ? d.getFullYear().toString() : argv.endDate;
d.setDate(d.getDate() - 6);
const startDate = argv.startDate === undefined ? d.getFullYear().toString() : argv.startDate;
logger.info(`startDate=${startDate}, endDate=${endDate}`)

const years = getYears(startDate, endDate);
console.log(years);
years.forEach(function (year) {
  console.log(year);
  downloadYear(year);
});
