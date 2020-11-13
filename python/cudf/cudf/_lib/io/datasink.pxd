# Copyright (c) 2020, NVIDIA CORPORATION.

from libcpp.memory cimport unique_ptr
from cudf._lib.cpp.io.types cimport data_sink

cdef class Datasink:

    cdef data_sink* get_datasink(self) nogil except *
