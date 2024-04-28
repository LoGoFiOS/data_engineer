# which image we want to use
FROM python:3.10.12

RUN pip install pandas

# Work path where our files will be copied 
WORKDIR /app
# Copy file from current location to container /app path
COPY pipeline.py pipeline.py

ENTRYPOINT ["python", "pipeline.py"]
