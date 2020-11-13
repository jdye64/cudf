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

#include "cudf_kafka/kafka_producer.hpp"
#include <librdkafka/rdkafkacpp.h>
#include <chrono>
#include <memory>

namespace cudf {
namespace io {
namespace external {
namespace kafka {

kafka_producer::kafka_producer(std::map<std::string, std::string> const &configs)
  : kafka_conf(RdKafka::Conf::create(RdKafka::Conf::CONF_GLOBAL))
{
  for (auto const &key_value : configs) {
    std::string error_string;
    CUDF_EXPECTS(RdKafka::Conf::ConfResult::CONF_OK ==
                   kafka_conf->set(key_value.first, key_value.second, error_string),
                 "Invalid Kafka configuration");
  }

  // Kafka 0.9 > requires group.id in the configuration
  std::string conf_val;
  CUDF_EXPECTS(RdKafka::Conf::ConfResult::CONF_OK == kafka_conf->get("group.id", conf_val),
               "Kafka group.id must be configured");

  std::string errstr;
  producer =
    std::unique_ptr<RdKafka::Producer>(RdKafka::Producer::create(kafka_conf.get(), errstr));
}

void kafka_producer::host_write(void const *data, size_t size) { return; }

void kafka_producer::flush() { return; }

size_t kafka_producer::bytes_written() { return 0; }

}  // namespace kafka
}  // namespace external
}  // namespace io
}  // namespace cudf
