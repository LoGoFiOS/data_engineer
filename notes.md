# Week 1

## Docker

Run the ubuntu image in interactive (-it) mode:

```bash
docker run -it ubuntu bash
```

There is one bash parameter. Everything that comes after the image name are parameters.  
If you exit the container and then run it again, all changes will be lost. It will be a new container. It's an **isolation**.

Run a python and interact with it:

```bash
docker run -it python:3.10.12
```

Run a python with entrypoint (what is executed when a container is run):

```bash
docker run -it entrypoint=bash python:3.10.12
```

And install the libs in the container:

```bash
pip install pandas
```

After running a container, we need to install libs inside it. To automate this we can use dockerfile:

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

There is an example with more usefull container:

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

docker run -it \
    -e POSTGRES_USER="root"\
    -e POSTGRES_PASSWORD="root"\
    -e POSTGRES_DB="ny_taxi"\
    -v /home/logofios/education/DataEngineerZoomCamp/ny_taxi_data
:var/lib/postgressql/data\
    -p 5432:5432

    
