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

#include <sitetosite/SiteToSiteClient.h>
#include <algorithm>
#include <chrono>
#include <cudf/io/datasource.hpp>
#include <map>
#include <memory>
#include <string>

namespace cudf {
namespace io {
namespace external {
namespace nifi {

/**
 * @brief libcudf datasource for Apache NiFi
 *
 * @ingroup io_datasources
 **/
class nifi_s2s_client : public cudf::io::datasource {
 public:
  /**
   * @brief Create an instance of a NiFi SiteToSite client. This client is capable of interacting
   *with any variation of an Apache NiFi instance that supports the "SiteToSite" protocol. This
   *client is also capable of both sending and receiving "FlowFiles" from Apache NiFi in a
   *transactional manner.
   *
   * @param host IP address or hostname of the target NiFi instance this client is to connect to
   * @param port Port which the NiFi instance is running on.
   **/
  nifi_s2s_client(std::string host, int32_t port);

  /**
   * @brief Returns a buffer with a subset of data from Kafka Topic
   *
   * @param[in] offset Bytes from the start
   * @param[in] size Bytes to read
   *
   * @return The data buffer
   */
  std::unique_ptr<cudf::io::datasource::buffer> host_read(size_t offset, size_t size) override;

  /**
   * @brief Returns the size of the data in Kafka buffer
   *
   * @return size_t The size of the source data in bytes
   */
  size_t size() const override;

  /**
   * @brief Reads a selected range into a preallocated buffer.
   *
   * @param[in] offset Bytes from the start
   * @param[in] size Bytes to read
   * @param[in] dst Address of the existing host memory
   *
   * @return The number of bytes read (can be smaller than size)
   */
  size_t host_read(size_t offset, size_t size, uint8_t *dst) override;

  virtual ~nifi_s2s_client(){};

 private:
  std::string host;
  int32_t port;
};

}  // namespace nifi
}  // namespace external
}  // namespace io
}  // namespace cudf
