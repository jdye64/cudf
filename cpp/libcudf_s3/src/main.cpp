#include <fstream>
#include <iostream>
#include <memory>
#include "arrow/filesystem/filesystem.h"
#include "arrow/filesystem/s3fs.h"
#include "arrow/status.h"
#include "cudf/io/datasource.hpp"
#include "cudf_s3/s3_arrow_datasource.hpp"

int main()
{
  std::string s3_path = "ursa-labs-taxi-data/2010/06/data.parquet";

  arrow::fs::S3GlobalOptions global_options = arrow::fs::S3GlobalOptions();
  global_options.log_level                  = arrow::fs::S3LogLevel::Info;
  arrow::Status init_status                 = arrow::fs::InitializeS3(global_options);

  printf("Init Status Code: %s\n", init_status.CodeAsString().c_str());
  printf("Init Status: %s\n", init_status.message().c_str());

  printf("Running tests with Arrow S3 implementation\n");
  arrow::fs::S3Options options = arrow::fs::S3Options();
  options.ConfigureAnonymousCredentials();
  options.region = "us-east-2";

  arrow::Result<std::shared_ptr<arrow::fs::S3FileSystem>> fs =
    arrow::fs::S3FileSystem::Make(options);

  if (fs.ok()) {
    std::shared_ptr<arrow::fs::S3FileSystem> s3fs = fs.ValueOrDie();
    printf("Everything seems ok and we have an S3 Filesystem instance\n");

    arrow::Result<arrow::fs::FileInfo> file_info = s3fs->GetFileInfo(s3_path);

    if (file_info.ok()) {
      printf("FileInfo is OK!\n");
      arrow::Result<std::shared_ptr<arrow::io::RandomAccessFile>> in_stream =
        s3fs->OpenInputFile(file_info.ValueOrDie());

      if (in_stream.ok()) {
        printf("Input stream generation is ok!\n");
        cudf::io::arrow_io_source arrow_source = cudf::io::arrow_io_source(in_stream.ValueOrDie());
      } else {
        printf("DANG! Seems like we had some trouble! %s\n", in_stream.status().message().c_str());
      }
    } else {
      printf("Something bad wrong ... %s\n", file_info.status().message().c_str());
    }

  } else {
    std::string err = fs.status().message();
    printf("Error: %s\n", err.c_str());
  }

  return 0;
}