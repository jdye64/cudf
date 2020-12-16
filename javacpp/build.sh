#!/bin/bash

mvn clean install
cp javacpp-1.5.4.jar src/gen/java/.
cd src/gen/java
java -jar javacpp-1.5.4.jar -classpath .:../../../cuda-11.0-8.0-1.5.4.jar:../../../target/classes:target/native -d -copylibs -copyresources -jarprefix cudfjavacpp -Dplatform.linkpath="/home/jdyer/anaconda3/envs/cudf_dev/lib" -Dplatform.includepath="/home/jdyer/anaconda3/envs/cudf_dev/include:/home/jdyer/Development/thrust:/home/jdyer/Development/cub:/home/jdyer/Development/rmm/include:/usr/local/cuda/include" ai/rapids/cudf/global/cudf.java
cd ../../../