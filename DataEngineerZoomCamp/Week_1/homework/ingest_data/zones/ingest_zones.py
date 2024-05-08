# # 0. Description

# https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/yellow
# 
# wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz
# 

# Yellow Trips: 
# * https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf
#   
# Green Trips:
# * https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_green.pdf

import os
import pandas as pd
import argparse 
from sqlalchemy import create_engine
from time import time

def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url
    csv_name = 'tmp_zones_output.csv'

    # download file and write in csv_name
    os.system(f"wget {url} -O {csv_name}")

    engine = create_engine(f"postgresql://{user}:{password}@{host}:{port}/{db}")
    df = pd.read_csv(f'{csv_name}', low_memory=False)
    df.to_sql(name=table_name, con=engine, if_exists='append')
    print('Finished saving zones table.')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')
    parser.add_argument('--user', help='username for Postgres')
    parser.add_argument('--password', help='password for Postgres')
    parser.add_argument('--host', help='host for Postgres')
    parser.add_argument('--port', help='port for Postgres')
    parser.add_argument('--db', help='database for Postgres')
    parser.add_argument('--table_name', help='Name of table where results will been')
    parser.add_argument('--url', help='url to CSV with data')
    args = parser.parse_args()
    #print(args.accumulate(args.integers))

    main(args)