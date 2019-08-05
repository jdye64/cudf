# Copyright (c) 2019, NVIDIA CORPORATION.

# cython: profile=False
# distutils: language = c++
# cython: embedsignature = True
# cython: language_level = 3

from libcpp.utility cimport pair

from cudf.bindings.cudf_cpp cimport *


cdef extern from "cudf/quantiles.hpp" namespace "cudf" nogil:

    cdef pair[cudf_table, gdf_column] group_quantiles(
        const cudf_table& key_table,
        const gdf_column& value_column,
        double q,
        gdf_quantile_method interpolation,
        const gdf_context& context
    ) except +
