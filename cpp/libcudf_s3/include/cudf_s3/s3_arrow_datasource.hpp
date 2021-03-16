/*
 * Copyright (c) 2020, NVIDIA CORPORATION.
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
#pragma once

#include <algorithm>
#include <chrono>
#include <cudf/io/datasource.hpp>
#include <map>
#include <memory>
#include <string>

namespace cudf {
namespace io {
namespace external {
namespace s3 {

class s3_arrow_datasource : public cudf::io::datasource {
 public:
  s3_arrow_datasource(std::string s3_path);

  std::unique_ptr<cudf::io::datasource::buffer> host_read(size_t offset, size_t size) override;

  size_t size() const override;

  size_t host_read(size_t offset, size_t size, uint8_t *dst) override;

  virtual ~s3_arrow_datasource(){};

 private:
  std::string s3_path;
  std::string buffer;
};

}  // namespace s3
}  // namespace external
}  // namespace io
}  // namespace cudf
