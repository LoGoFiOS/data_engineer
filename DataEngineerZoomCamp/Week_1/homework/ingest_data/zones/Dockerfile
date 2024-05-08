# which image we want to use
FROM python:3.10.12

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2-binary

# Work path where our files will be copied 
WORKDIR /app
# Copy file from current location to container /app path
COPY ingest_zones.py ingest_zones.py


ENTRYPOINT ["python", "ingest_zones.py"]

#docker build -t taxi_ingest_zones:v001 .

# docker run -it \
#     --network=homework_default \
#     taxi_ingest_zones:v001 \
#     --user=root \
#     --password=root \
#     --host=pgdatabase \
#     --port=5432 \
#     --db=ny_taxi \
#     --table_name=zones \
#     --url="https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv"


