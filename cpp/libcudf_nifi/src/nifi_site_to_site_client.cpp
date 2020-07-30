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

#include "cudf_nifi/nifi_site_to_site_client.hpp"
#include <chrono>
#include <memory>

namespace cudf {
namespace io {
namespace external {
namespace nifi {

nifi_s2s_client::nifi_s2s_client(std::string host, int32_t port) : host(host), port(port)
{
  printf("Creating NiFi SiteToSite Client ... \n");
}

std::unique_ptr<cudf::io::datasource::buffer> nifi_s2s_client::host_read(size_t offset, size_t size)
{
  if (offset > buffer.size()) { return 0; }
  size = std::min(size, buffer.size() - offset);
  return std::make_unique<non_owning_buffer>((uint8_t *)buffer.data() + offset, size);
}

size_t nifi_s2s_client::host_read(size_t offset, size_t size, uint8_t *dst)
{
  if (offset > buffer.size()) { return 0; }
  auto const read_size = std::min(size, buffer.size() - offset);
  memcpy(dst, buffer.data() + offset, size);
  return read_size;
}

size_t nifi_s2s_client::size() const { return buffer.size(); }

}  // namespace nifi
}  // namespace external
}  // namespace io
}  // namespace cudf
