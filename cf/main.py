import base64
from google.cloud import storage
from google.cloud import bigquery
from typing import cast
import csv
import json
import io
from os import getenv

def bq_write(data, context):

    print(f"data: {data}")
    project_id = getenv("project_id")
    dataset_name = getenv("dataset_name")
    table_name = getenv("table_name")
    table_id = f'{project_id}.{dataset_name}.{table_name}'

    # a. receive csv filename
    bucket_name = data['bucket']
    filename = data['name']
    print(f"bucket:{bucket_name}, filename:{filename}")

    # b. read csv file content using filename from trigger
    bucket = storage.Client().get_bucket(bucket_name)
    blob = bucket.get_blob(filename)
    encoding = 'utf-8'
    blobstr = str(blob.download_as_string(),encoding)
    print('file content is:\n')
    print(blobstr.splitlines())
    print("--------")
    # c. iterate the rows and create a array
    reader = csv.DictReader(io.StringIO(blobstr))
    rows_to_insert = json.loads(json.dumps(list(reader)))
    print(f"rows_to_insert:{rows_to_insert}")
    # rows_to_insert = [{"name": "David", "age": "40", "postcode": "IG14TY"}, {"name": "Tom", "age": "26", "postcode": "CB236UH"}]

    # d. use bq client and write the rows in the table
    client = bigquery.Client()
    errors = client.insert_rows_json(table_id, rows_to_insert)  # Make an API request.
    if errors == []:
        print("New rows have been added.")
    else:
        print("Encountered errors while inserting rows: {}".format(errors))
