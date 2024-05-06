# which image we want to use
FROM python:3.10.12

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2-binary

# Work path where our files will be copied 
WORKDIR /app
# Copy file from current location to container /app path
COPY ingest_data.py ingest_data.py

ENTRYPOINT ["python", "ingest_data.py"]


# python3 ingest_data.py \
#     --user=root \
#     --password=root \
#     --host=localhost \
#     --port=5432 \
#     --db=ny_taxi \
#     --table_name=yellow_tripdata \
#     --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"


# docker build -t taxi_ingest:v001 .

# docker run -it \
#     --network=pg-network \
#     taxi_ingest:v001 \
#     --user=root \
#     --password=root \
#     --host=pg-database \
#     --port=5432 \
#     --db=ny_taxi \
#     --table_name=yellow_tripdata \
#     --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"


# docker network create pg-network


# docker run -it \
#     -e POSTGRES_USER="root" \
#     -e POSTGRES_PASSWORD="root" \
#     -e POSTGRES_DB="ny_taxi" \
#     -v $(pwd)/postgresql/ny_taxi_data:/var/lib/postgresql/data \
#     -p 5432:5432 \
#     --network=pg-network \
#     --name pg-database \
#     postgres:16.2


# docker run -it \
#     -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
#     -e PGADMIN_DEFAULT_PASSWORD="root" \
#     -p 8080:80 \
#     --network=pg-network \
#     --name pgadmin \
#     dpage/pgadmin4:latest