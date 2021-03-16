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

namespace cudf {
namespace io {
namespace external {
namespace s3 {

s3_arrow_datasource::s3_arrow_datasource(std::string s3_path) : s3_path(s3_path)
{
  printf("Ok entering the logic to create the s3_arrow_datasource\n");
}

std::unique_ptr<cudf::io::datasource::buffer> s3_arrow_datasource::host_read(size_t offset,
                                                                             size_t size)
{
  if (offset > buffer.size()) { return 0; }
  size = std::min(size, buffer.size() - offset);
  return std::make_unique<non_owning_buffer>((uint8_t *)buffer.data() + offset, size);
}

size_t s3_arrow_datasource::host_read(size_t offset, size_t size, uint8_t *dst)
{
  if (offset > buffer.size()) { return 0; }
  auto const read_size = std::min(size, buffer.size() - offset);
  memcpy(dst, buffer.data() + offset, size);
  return read_size;
}

size_t s3_arrow_datasource::size() const { return buffer.size(); }

}  // namespace s3
}  // namespace external
}  // namespace io
}  // namespace cudf
