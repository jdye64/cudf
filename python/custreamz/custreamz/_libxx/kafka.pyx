# Copyright (c) 2019-2020, NVIDIA CORPORATION.

# cython: profile=False
# distutils: language = c++
# cython: embedsignature = True
# cython: language_level = 3

from custreamz._libxx.includes.kafka cimport (
    kafka_datasource,
)
from cudf._lib.table cimport Table
from cudf._lib.cpp.table.table cimport table
from cudf._lib.move cimport move
from cudf._lib.io.utils cimport make_source_info

from libcpp.string cimport string
from libcpp.memory cimport unique_ptr, make_unique
from libcpp.vector cimport vector
from libcpp.map cimport map
from cython.operator cimport dereference, postincrement
from libc.stdint cimport uint32_t, int64_t
from cudf._lib.cpp.io.functions cimport (
    read_json as libcudf_read_json,
    read_json_args
)
cimport cudf._lib.cpp.io.functions as libcudf
cimport cudf._lib.cpp.io.types as cudf_io_types


cdef class librdkafka:

    cpdef unique_ptr[kafka_datasource] kds

    def __cinit__(self, kafka_conf):        
        cdef map[string, string] kafka_confs
        for key, value in kafka_conf.items():
            kafka_confs[str.encode(key)] = str.encode(value)

        self.kds = make_unique[kafka_datasource](kafka_confs)

    cpdef read_gdf(self,
                lines=True,
                dtype=True,
                compression="infer",
                dayfirst=True,
                byte_range=None,
                topic=None,
                partition=0,
                start=0,
                end=0,
                timeout=10000,
                delimiter="\n"):

        cdef json_str = self.kds.get().consume_range(str.encode(topic),
                                        partition,
                                        start,
                                        end,
                                        timeout,
                                        str.encode(delimiter))

        cdef cudf_io_types.table_with_metadata c_out_table
        cdef read_json_args json_args = read_json_args(make_source_info([json_str]))

        if len(json_str) > 0:
            json_args.lines = lines
            #json_args.source = cudf_io_types.source_info(
            #     json_str, len(json_str))
            json_args.compression = cudf_io_types.compression_type.NONE
            json_args.dayfirst = dayfirst

            with nogil:
                c_out_table = move(libcudf.read_json(json_args))

            column_names = [x.decode() for x in c_out_table.metadata.column_names]
            return Table.from_unique_ptr(move(c_out_table.tbl),
                                        column_names=column_names)
        else:
            return None

    cpdef get_committed_offset(self, topic=None, partition=None):
        return self.kds.get().get_committed_offset(str.encode(topic), partition)

    cpdef current_configs(self):
        self.kds.get().current_configs()

    cpdef print_consumer_metadata(self):
        self.kds.get().print_consumer_metadata()

    cpdef get_watermark_offsets(self,
                                topic=None,
                                partition=0,
                                timeout=10000,
                                cached=False):

        cdef map[string, int64_t] offsets = \
            self.kds.get().get_watermark_offset(str.encode(topic), partition, timeout, cached)
        return offsets

    cpdef commit_topic_offset(self,
                            topic=None,
                            partition=0,
                            offset=0,
                            asynchronous=True):
        return self.kds.get().commit_offset(str.encode(topic), partition, offset)

    cpdef produce_message(self, topic="", message_val="", message_key=""):
        return self.kds.get().produce_message(str.encode(topic),
                                str.encode(message_val),
                                str.encode(message_key))

    cpdef flush(self, timeout=10000):
        return self.kds.get().flush(timeout)

    cpdef unsubscribe(self):
        return self.kds.get().unsubscribe()

    cpdef close(self, timeout=10000):
        return self.kds.get().close(timeout)

    def __dealloc__(self):
        self.flush()
        self.close()
        self.kds.reset()
