# This example shows how to use CuStreamz in conjunction in a "Publish Once Compute Many"
# architecture

# 3) Read messages from Kafka on each process/thread in Dask
# 4) Accumulate Kafka messages into existing dataframes dask-cudf concat?? How fast/slow will this be?
# 5) Dask publish datasets after accumulation
# 6) Notifiy downstream "Jobs" that a new Dataframe is available for processing if desired

from distributed import Client
from custreamz import kafka
import cudf
import time

# 1) Setup a Dask cluster and Dask workers
# Ensure dask-scheduler is running and N desired dask-cuda-workers are running
# $ dask-scheduler
# $ dask-cuda-worker localhost:8786 (N number of workers desired)
# $ localhost:8787/status for Dask status

if __name__ == '__main__':
    # 2) Connect to Dask
    client = Client('localhost:8786')
    print(client)

    # Create a simple dataframe
    gdf = cudf.read_csv('names.csv')
    print(gdf.head())
    client.publish_dataset(names=gdf)

    while(1):
        time.sleep(10)
        print("tick")