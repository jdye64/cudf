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
  auto all_cols_runtime = duration.count();

  // Read only a single column to compare sppeds
  printf("Begin downloading the file from S3 with only a single column\n");

  std::unique_ptr<cudf::io::external::s3::s3_arrow_datasource> single_datasource =
    std::make_unique<cudf::io::external::s3::s3_arrow_datasource>(s3_path);
  cudf::io::source_info single_src(single_datasource.get());

  std::vector<std::string> single_column;
  single_column.insert(single_column.begin(), "dropoff_at");

  cudf::io::parquet_reader_options_builder single_builder(single_src);
  cudf::io::parquet_reader_options single_options = single_builder.columns(single_column).build();

  start                                    = std::chrono::high_resolution_clock::now();
  cudf::io::table_with_metadata single_tbl = cudf::io::read_parquet(single_options);
  stop                                     = std::chrono::high_resolution_clock::now();

  printf("Cols: %ld, Rows: %ld receiving from S3\n",
         single_tbl.tbl->num_columns(),
         single_tbl.tbl->num_rows());
  duration = std::chrono::duration_cast<std::chrono::microseconds>(stop - start);
  printf("Duration: %ld\n", duration.count());
  auto one_col_runtime = duration.count();

  printf("All Columns Runtime: %ld; One Column Runtime: %ld", all_cols_runtime, one_col_runtime);

  return 0;
}