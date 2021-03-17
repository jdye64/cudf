/*
 * Copyright (c) 2019-2020, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "cudf_s3/s3_arrow_datasource.hpp"
#include <chrono>
#include <memory>
#include "arrow/result.h"

namespace cudf {
namespace io {
namespace external {
namespace s3 {

s3_arrow_datasource::s3_arrow_datasource(std::string s3_path) : s3_path(s3_path)
{
  printf("Ok entering the logic to create the s3_arrow_datasource\n");

  buffer = "something";

  global_options            = arrow::fs::S3GlobalOptions();
  global_options.log_level  = arrow::fs::S3LogLevel::Debug;
  arrow::Status init_status = arrow::fs::InitializeS3(global_options);

  options = arrow::fs::S3Options();
  options.ConfigureAnonymousCredentials();
  options.region = "us-east-2";

  arrow::Result<std::shared_ptr<arrow::fs::S3FileSystem>> fs =
    arrow::fs::S3FileSystem::Make(options);

  if (fs.ok()) {
    s3fs = fs.ValueOrDie();

    arrow::Result<arrow::fs::FileInfo> file_info = s3fs->GetFileInfo(s3_path);

    if (file_info.ok()) {
      arrow::Result<std::shared_ptr<arrow::io::RandomAccessFile>> in_stream =
        s3fs->OpenInputFile(file_info.ValueOrDie());

      if (in_stream.ok()) {
        printf("Input stream generation is ok!\n");
        arrow_random_access_file = in_stream.ValueOrDie();
        arrow_source = std::make_shared<cudf::io::arrow_io_source>(arrow_random_access_file);
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
}

std::unique_ptr<cudf::io::datasource::buffer> s3_arrow_datasource::host_read(size_t offset,
                                                                             size_t size)
{
  printf("Calling first host read\n");
  if (offset > buffer.size()) { return 0; }
  size = std::min(size, buffer.size() - offset);
  return std::make_unique<non_owning_buffer>((uint8_t *)buffer.data() + offset, size);
}

size_t s3_arrow_datasource::host_read(size_t offset, size_t size, uint8_t *dst)
{
  printf("Calling second host read\n");
  if (offset > buffer.size()) { return 0; }
  auto const read_size = std::min(size, buffer.size() - offset);
  memcpy(dst, buffer.data() + offset, size);
  return read_size;
}

size_t s3_arrow_datasource::size() const
{
  printf("calling size function\n");
  return buffer.size();
}

}  // namespace s3
}  // namespace external
}  // namespace io
}  // namespace cudf
