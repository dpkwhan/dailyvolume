import requests
import logging as logger
from pathlib import Path
import argparse
from datetime import datetime, timedelta

BASE_URL = 'http://markets.cboe.com/us/equities/market_statistics/historical_market_volume'


def fetch(yyyy):
    fname = f'market_history_{yyyy}.csv'
    url = f'{BASE_URL}/{fname}-dl'

    fpath = Path(__file__).resolve().parent / "data"
    fpath.mkdir(parents=True, exist_ok=True)
    ffile = fpath / fname

    req = requests.get(url)
    with ffile.open('w') as f:
        f.write(req.text)
    logger.info(f'Saving data to {ffile}')


def get_years(date1, date2):
    year1 = date1.year
    year2 = date2.year + 1
    for y in range(year1, year2):
        yield y


if __name__ == '__main__':
    logger.basicConfig(
        level=logger.INFO,
        format='%(asctime)s %(levelname)-5.5s [%(name)s] %(message)s'
    )

    parser = argparse.ArgumentParser(description='Download daily volume data')
    parser.add_argument('--startDate',
                        dest='startDate',
                        action='store',
                        default=None,
                        help='Start date of the data period. Format: yyyymmdd'
                        )
    parser.add_argument('--endDate',
                        dest='endDate',
                        action='store',
                        default=None,
                        help='End date of the data period. Format: yyyymmdd'
                        )
    args = parser.parse_args()
    if args.startDate is None:
        start_date = datetime.today() - timedelta(days=6)
    else:
        start_date = datetime.strptime(args.startDate, '%Y%m%d')

    if args.endDate is None:
        end_date = datetime.today()
    else:
        end_date = datetime.strptime(args.endDate, '%Y%m%d')

    logger.info(f'startDate={start_date}, endDate={end_date}')

    years = get_years(start_date, end_date)
    for year in years:
        fetch(year)
