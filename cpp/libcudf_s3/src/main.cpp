#include <chrono>
#include <fstream>
#include <iostream>
#include <memory>
#include "cudf/io/parquet.hpp"
#include "cudf/io/types.hpp"
#include "cudf_s3/s3_arrow_datasource.hpp"

#include <cudf/table/table_view.hpp>
#include <cudf/types.hpp>

int main()
{
  std::string s3_path = "ursa-labs-taxi-data/2010/06/data.parquet";

  // Create the Arrow S3 User defined Datasource instance
  std::unique_ptr<cudf::io::external::s3::s3_arrow_datasource> datasource =
    std::make_unique<cudf::io::external::s3::s3_arrow_datasource>(s3_path);

  // Populate the Parquet Reader Options
  cudf::io::source_info src(datasource.get());
  // cudf::io::source_info src(datasource.get()->arrow_source.get());
  cudf::io::parquet_reader_options_builder builder(src);
  cudf::io::parquet_reader_options options = builder.build();

  // Read the Parquet file from S3
  printf("Begin downloading the file from S3 with ALL columns\n");
  auto start                        = std::chrono::high_resolution_clock::now();
  cudf::io::table_with_metadata tbl = cudf::io::read_parquet(options);
  auto stop                         = std::chrono::high_resolution_clock::now();
  printf("Cols: %ld, Rows: %ld receiving from S3\n", tbl.tbl->num_columns(), tbl.tbl->num_rows());
  auto duration = std::chrono::duration_cast<std::chrono::microseconds>(stop - start);
  printf("Duration: %ld\n", duration.count());

  return 0;
}