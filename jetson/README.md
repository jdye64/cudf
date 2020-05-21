# Rapids on Jetson Devices

## Supported Jetson Devices
| Device            | Jetpack Version | Supported?  |
|:----------------- |:------:|:-------:|
| Nano              | *      | NO      |
| Xavier NX         | 4.2.+> | NO      |
| AGX Xavier        | 4.0.+> | YES     |


## Building
RapidsAI components can be built on top of Jetson devices based on the support matrix above. If your device falls into the "NO" category in
the support matrix above you have about a 50/50 shot on the build working but most likely its a NO.

The RapidsAI team offers a convenience script for building cuDF on your Jetson target device. This script can be located at ```${CUDF_HOME}/jetson/jetson_build.sh```

The `jetson_build.sh` script operations can be broken down into the follow steps.

1. `clean` - If enabled the first thing the script will do is clean any artifacts from previous runs
2. `query_device` - Query the local device for information about CUDA version(s), hardware, and software versions. Useful for sharing problems with community.
3. `prepare_device` - Adjust certain Jetson board power consumption settings to ensure performant builds
4. `install_dependencies` - Install system dependencies, libraies, and runtime components needed to build the specified targets
5. `prepare_build_env` - Set environments varibles and checkout all required code that will be needed to perform the RapidsAI target builds
6. `build` - Build the libraries/binaries for the user specified RapidsAI libraries
7. `install` - Install the build libraries/binaries to the user specified location
9. `test` - Test to ensure that the specified libraries/binaries are behaving as expected

### Jetson Build Script Arguments

The ```$CUDF_HOME/jetson/jetson_build.sh``` script must always be ran as a root user. It can either be invoked as the true root user or called via ```sudo```.

| Command                          | Action                                                                                                                   |
|:-------------------------------- |-------------------------------------------------------------------------------------------------------------------------:|
| ./jetson_build.sh                | Performs the default Jetson build. Install dependencies, prepares environment, and build cuDF                            |
| ./jetson_build.sh clean          | Remove any components from previous runs and then exits the script. Nothing more is done                                 |
| ./jetson_build.sh clean cudf     | Remove any components from previous runs and then exits the script. Anytime `clean` is specified nothing further is done |
| ./jetson_build.sh cudf           | Install the `default` system and library components and then build cuDF C++ and Python libraries                         |
| ./jetson_build.sh -skip_deps     | Regardless of target library skip the step of installing system dependencies and libraries                               |
| ./jetson_build.sh -skip_prep_env | Regardless of target library skip environment preparation steps. This ensures user defined env variables persist                               |
| ./jetson_build.sh -silent_times  | Do not output step runtimes when executing the script                                                                    |

### Building on Jetson
```sudo $CUDF_HOME/jetson/jetson_build.sh``` will 

### Building on Device
RapidsAI supplies a convenience script for building code locally on your Jetson device. Building locally can take several hours (up to a ful day) 
but provides the most flexibility for experimentation and testing out new features you might want to develop.

## Cross Compiling
Cross compiling is not yet a supported feature but is next on the list of items to tackle for RapidsAI on Jetson devices

## Installing Pre-Built Binaries
RapidsAI currently does not offer a repo for installing pre-built binaries. Instead you will need to perform a source build on your target device as described above.

## FAQ