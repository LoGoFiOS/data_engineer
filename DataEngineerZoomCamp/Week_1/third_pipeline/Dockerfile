# which image we want to use
FROM python:3.10.12

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2-binary

# Work path where our files will be copied 
WORKDIR /app
# Copy file from current location to container /app path
COPY ingest_data.py ingest_data.py

ENTRYPOINT ["python", "ingest_data.py"]


# docker build -t taxi_ingest:v001 .

# docker run -it \
#     --network=third_pipeline_default\
#     taxi_ingest:v001 \
#     --user=root \
#     --password=root \
#     --host=pg-database \
#     --port=5432 \
#     --db=ny_taxi \
#     --table_name=yellow_tripdata_2021-01 \
#     --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"


# python3 ingest_data.py \
#     --user=root \
#     --password=root \
#     --host=localhost \
#     --port=5432 \
#     --db=ny_taxi \
#     --table_name=yellow_tripdata_2021-01 \
#     --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"


 