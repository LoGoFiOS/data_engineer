# which image we want to use
FROM python:3.10.12

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2-binary

# Work path where our files will be copied 
WORKDIR /app
# Copy file from current location to container /app path
COPY ingest_data_green.py ingest_data_green.py


ENTRYPOINT ["python", "ingest_data_green.py"]

#docker build -t taxi_ingest_green:v001 .

# docker run -it \
#     --network=homework_default \
#     taxi_ingest_green:v001 \
#     --user=root \
#     --password=root \
#     --host=pgdatabase \
#     --port=5432 \
#     --db=ny_taxi \
#     --table_name=green_tripdata_2019_09 \
#     --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz"


