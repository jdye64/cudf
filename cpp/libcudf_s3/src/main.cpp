#include <fstream>
#include <iostream>
#include <memory>
#include "cudf_s3/s3_arrow_datasource.hpp"

int main()
{
  std::string s3_path = "ursa-labs-taxi-data/2010/06/data.parquet";

  std::unique_ptr<cudf::io::external::s3::s3_arrow_datasource> datasource =
    std::make_unique<cudf::io::external::s3::s3_arrow_datasource>(s3_path);

  cudf::io::parquet_reader_options options;
  cudf::io::source_info src(datasource.get());

  printf("After here\n");

  cudf::io::read_parquet(options);

  return 0;
}