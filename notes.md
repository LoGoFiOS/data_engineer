# Week 1

## Docker

Run the ubuntu image in interactive (-it) mode:

```bash
docker run -it ubuntu bash
```

There is one bash parameter. Everything that comes after the image name are a parameters.  
If you exit the container and then run it again, all changes will be lost. It will be a new container. It's an **isolation**.

To run a python and interact with it:

```bash
docker run -it python:3.10.12
```

To run a python with entrypoint (what is executed when a container is run):

```bash
docker run -it entrypoint=bash python:3.10.12
```

And install the libs into the container:

```bash
pip install pandas
```

After running a container, we need to install the libs inside it. To automate this, we can use dockerfile:

```dockerfile
# which image to use
FROM python:3.10.12
RUN pip install pandas
ENTRYPOINT ["bash"]
```

Then we need to create this dockerfile with name = "test_name", tag = "ver_01" and the current path = ":

```bash
docker build -t test_name:ver_01 .
```

Now we can run a new container:

```bash
docker run -it test_name:ver_01
```

There is an example with a more useful container:

```dockerfile
# which image we want to use
FROM python:3.10.12
RUN pip install pandas
# Work path where our files will be copied 
WORKDIR /app
# Copy file from current location to container /app path
COPY pipeline.py pipeline.py
ENTRYPOINT ["python", "pipeline.py"]
```

```python
import sys
import pandas as pd 
print(sys.argv)
first_parametr = sys.argv[1]
second_parametr = sys.argv[2]
print(first_parametr)
print(second_parametr)
print('Pipeline has finished!')
```

And there are commands to build and run this container:

```bash
docker build -t test_name:ver_01 .
docker run -it test_name:ver_01 hello! 42

>> It's a output
>> ['pipeline.py', 'hello!', '42']
>> hello!
>> 42
```

## Docker + Postgres

Install a client to access to Postgres:

```bash
pip install pgcli
sudo apt install pgcli
```

Then run (execute `pgcli`) pgcli and if you have these errors:

```bash
ImportError: no pq wrapper available.
Attempts made:
- couldn't import psycopg 'c' implementation: No module named 'psycopg_c'
- couldn't import psycopg 'binary' implementation: No module named 'psycopg_binary'
- couldn't import psycopg 'python' implementation: libpq library not found
```

Install postgresql on your system:

```bash
sudo apt-get install postgresql
```

Run Docker with Postgres:

```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v $(pwd)/postgresql/ny_taxi_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:16.2
```

`ny_taxi_data` will be the name of the database. And be careful with the Postgres path in the Docker. The correct path should be: `/var/lib/postgresql/data`!

## Access to Postgres via terminal

To access to the `ny_taxi_data` database:

```bash
pgcli -h localhost -p 5432 -u root -d ny_taxi
```

## Access to Postgres via Jupyther

Here is a data: https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/yellow

To get this data:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz
```

To create a table with a schema as in the existing table (via Jupyther):

```python
import pandas as pd
from sqlalchemy import create_engine
from time import time

# 2. Get data and DDL for Postgres 
# I load only 1000 rows to optimize
df = pd.read_csv('./../yellow_tripdata_2021-01.csv', nrows = 1000)
df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])
df.head()

df.dtypes

# Create DDL. I want to create a table in Postgres with same schema like in df
print(pd.io.sql.get_schema(df, name='yellow_tripdata_2021-01'))

# Create an engine to connect
user = "root"
password = "root"
port = 5432
db = "ny_taxi"
engine = create_engine(f"postgresql://{user}:{password}@localhost:{port}/{db}")
table_name = 'yellow_tripdata_2021-01'

# Create DDL. I want to create a table in Postgres with same schema
print(pd.io.sql.get_schema(df, name=table_name, con=engine))


# 3. Read and write df in DB by chunks
df_iter = pd.read_csv('./../yellow_tripdata_2021-01.csv', iterator=True, chunksize=100_000)
df_iter


%%time
# Process the first chunk separately to create/replace the table structure
t_start = time()
try:
    df = next(df_iter)
    df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
    df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])
    df.head(0).to_sql(name=table_name, con=engine, if_exists='replace')
    df.to_sql(name=table_name, con=engine, if_exists='append')
    t_end = time()
    print(f"Inserted first chunk..., took {t_end-t_start:.2f} seconds")
except StopIteration:
    print('No data to process.')


%%time
while True:
    t_start = time()
    try:
        df = next(df_iter)
        df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
        df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])
        df.to_sql(name=table_name, con=engine, if_exists='append')
        t_end = time()
        print(f"Inserted chunk..., took {t_end-t_start:.2f} seconds")
    except StopIteration:
        print('Finished processing all chunks.')
        break

# Check data
query = f"""
SELECT COUNT(1) FROM "{table_name}"
"""

pd.read_sql(query, con=engine)
```

If you get the error: `No module named 'psycopg2'`, run `pip install psycopg2-binary`.

To convert jupyther notebook to script:

```bash
jupyter nbconvert --to=script %NOTEBOOK_TO_CONVERT%
```

## pgAdmin

It's a tool to access to database via web browser:

```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    dpage/pgadmin4:latest
```

To use write in a browser:

```bash
localhost:8080
```

## Docker Network

Then we have to connect the container with pgAdmin and the container with Postgres. We're running both containers and connect them by Docker Network:

```bash
docker network create pg-network
```

Run 2 containers:

```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v $(pwd)/postgresql/ny_taxi_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database \
    postgres:16.2
```

The name parameter allows you to specify a name for the container.

```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    --network=pg-network \
    --name pgadmin \
    dpage/pgadmin4:latest
```

Now we can connect to database **pg-database**:

![](/home/logofios/snap/marktext/9/.config/marktext/images/2024-05-04-13-54-46-image.png)

## Upgrade pipeline

There is ingest_data.py:

```python
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
    csv_name = 'output.csv'

    # download file and write in csv_name
    os.system(f"wget {url} -O {csv_name}")

    engine = create_engine(f"postgresql://{user}:{password}@{host}:{port}/{db}")
    df_iter = pd.read_csv(f'{csv_name}', compression='gzip', low_memory=False, iterator=True, chunksize=100_000)

    # Process the first chunk separately to create/replace the table structure
    t_start = time()
    try:
        df = next(df_iter)
        df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
        df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])
        df.head(0).to_sql(name=table_name, con=engine, if_exists='replace')
        df.to_sql(name=table_name, con=engine, if_exists='append')
        t_end = time()
        print(f"Inserted first chunk..., took {t_end-t_start:.2f} seconds")
    except StopIteration:
        print('No data to process.')

    while True:
        t_start = time()
        try:
            df = next(df_iter)
            df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
            df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])
            df.to_sql(name=table_name, con=engine, if_exists='append')
            t_end = time()
            print(f"Inserted chunk..., took {t_end-t_start:.2f} seconds")
        except StopIteration:
            print('Finished processing all chunks.')
            break

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
```

To run via python:

```bash
python3 ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_tripdata \
    --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
```

Dockerfile:

```dockerfile
FROM python:3.10.12

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2-binary

# Work path where our files will be copied 
WORKDIR /app
# Copy file from current location to container /app path
COPY ingest_data.py ingest_data.py

ENTRYPOINT ["python", "ingest_data.py"]
```

To build it:

```bash
docker build -t taxi_ingest:v001 .
```

Run 2 containers with Postgres and pgAdmin:

```bash
docker start pg-database
docker start pgadmin
```

To run via Docker:

```bash
docker run -it \
    --network=pg-network \
    taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_tripdata \
    --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
```

Be careful with host parameter. There is have to be name of the Docker Postgres container!

## Docker compose

Instead, to run a few Docker containers, we can run Docker Compose file:

```dockerfile
services:
  pgdatabase:
    image: postgres:16.2
    environment:
      - POSTGRES_USER=root
      - POSTGRES_PASSWORD=root
      - POSTGRES_DB=ny_taxi
    volumes:
      - "./../../postgresql/ny_taxi_data:/var/lib/postgresql/data:rw"
    ports:
      - "5432:5432"
  pgadmin:
    image: dpage/pgadmin4:latest
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - "8080:80"
```

To install [click](https://docs.docker.com/compose/install/linux/#install-using-the-repository).

We don't have to think about networking. Docker Compose creates it for us.

```bash
docker compose up -d
```

There is a `-d` parameter which means that the terminal will be available after the run. To stop use `docker compose down` (or ctr + c if use without -d!).

Also there can be a some problems:

* cannot stop container ... permission denied:
  To solve it run `sudo systemctl restart docker.socket docker.service`
* PORT_NUMBER bind: address already in use
  To solve it run ```sudo kill -9 `sudo lsof -t -i:PORT_NUMBER````

After run we can use the previous code to ingest the data:

```bash
docker build -t taxi_ingest:v001 .
```

To find a Docker Compose Network:

```bash
docker network ls
```

In my case it was `third_pipeline_default`. And host will be the name from Docker Compose file:

```bash
docker run -it \
    --network=third_pipeline_default \
    taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pgdatabase \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_tripdata \
    --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
```

And a note about ports. I can use another ports. For example, let's use "5431:5432" for pgdatabase. To accept this database I have to use port 5431:  `pgcli -h localhost -p 5431 -u root -d ny_taxi`

But inside the Docker Compose I'll be use a port 5432:

![](/home/logofios/snap/marktext/9/.config/marktext/images/2024-05-06-21-04-35-image.png)

And there is a good video about ports: [click](https://www.youtube.com/watch?v=tOr4hTsHOzU&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=16)

## Terraform

Infrastructure as code
[video 1](https://www.youtube.com/watch?v=s2bOYDCKl_M&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=12)
[video 2](https://www.youtube.com/watch?v=Y2ux7gq3Z0o&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=12)
[video 3](https://www.youtube.com/watch?v=PBi0hHjLftk&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=13)

[Install](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## Connect to Google CP via terminal

[A good video](https://www.youtube.com/watch?v=ae-CV2KfoN0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=14)

1. Create a ssh key: [link](https://cloud.google.com/compute/docs/connect/create-ssh-keys)
2. Add the ssh key to VM compute engine metadata
3. To connect `ssh -i ~/.ssh/NAME_OF_FILE_WITH_SSH_KEY YOUR_LOGIN@IP_OF_VM`
4. Also you can create a config file in the ~/.ssh directory:

```bash
Host de-zoomcamp
    HostName IP_OF_VM
    User YOUR_LOGIN
    IdentityFile ~/.ssh/gcp
```

In my case NAME_OF_FILE_WITH_SSH_KEY is `gcp`. Now you can connect by `ssh de-zoomcamp`

And it easy to send files from localhost to GCP:

```bash
scp hello.txt de-zoomcamp:~/tmp
```

Or from GCP to localhost:

```bash
scp de-zoomcamp:~/tmp/hello.txt ~/tmp
```
