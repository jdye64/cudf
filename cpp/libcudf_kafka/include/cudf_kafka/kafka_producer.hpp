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

#include <librdkafka/rdkafkacpp.h>
#include <algorithm>
#include <chrono>
#include <cudf/io/data_sink.hpp>
#include <map>
#include <memory>
#include <string>

namespace cudf {
namespace io {
namespace external {
namespace kafka {

/**
 * @brief libcudf datasink for Apache Kafka
 *
 * @ingroup io_datasinks
 **/
class kafka_producer : public cudf::io::data_sink {
 public:
  /**
   * @brief Creates an instance of the Kafka producer object
   *
   * Documentation for librdkafka configurations can be found at
   * https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md
   *
   * @param configs key/value pairs of librdkafka configurations that will be
   *                passed to the librdkafka client
   **/
  kafka_producer(std::map<std::string, std::string> const &configs);

  /**
   * @brief Writes data to Kafka from the buffer with messages delimited based object level
   * delimiter
   *
   * @param[in] offset Bytes from the start
   * @param[in] size Bytes to read
   *
   * @return The data buffer
   */
  void host_write(void const *data, size_t size) override;

  /**
   * Ensure that all pending Kafka messages are flushed to the underlying socket connection.
   */
  void flush() override;

  /**
   * @brief Number of bytes that have been written to Kafka
   *
   * @return bytes written to Kafka
   */
  size_t bytes_written() override;

  virtual ~kafka_producer(){};

 private:
  std::unique_ptr<RdKafka::Conf> kafka_conf;  // RDKafka configuration object
  std::unique_ptr<RdKafka::Producer> producer;

  std::string buffer;
  std::string delimiter = ",";
};

}  // namespace kafka
}  // namespace external
}  // namespace io
}  // namespace cudf
