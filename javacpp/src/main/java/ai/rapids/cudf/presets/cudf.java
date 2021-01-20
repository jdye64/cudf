package ai.rapids.cudf.presets;

import org.bytedeco.javacpp.Loader;
import org.bytedeco.javacpp.annotation.Platform;
import org.bytedeco.javacpp.annotation.Properties;
import org.bytedeco.javacpp.tools.Info;
import org.bytedeco.javacpp.tools.InfoMap;
import org.bytedeco.javacpp.tools.InfoMapper;

import org.bytedeco.cuda.presets.*;


@Properties(
        inherit = cudart.class,
        names = {"linux"},
        value = {
                @Platform(
                        compiler = "cpp14",
                        define = {"NO_WINDOWS_H", "UNIQUE_PTR_NAMESPACE std", "SHARED_PTR_NAMESPACE std"},
                        include = {
                                "rmm/cuda_stream_view.hpp",
                                "rmm/device_vector.hpp",
                                "thrust/pair.h",
                                "cudf/aggregation.hpp",
//                                "cudf/binaryop.hpp", // TODO: Missing simt/chrono, need to add that just don't want to at the moment
                                "cudf/concatenate.hpp",
//                                "cudf/copying.hpp",
                                "cudf/datetime.hpp",
                                "cudf/filling.hpp",
//                                "cudf/groupby.hpp",
                                "cudf/hashing.hpp",
//                                "cudf/interop.hpp",
//                                "cudf/ipc.hpp",
//                                "cudf/join.hpp",
//                                "cudf/merge.hpp",
                                "cudf/null_mask.hpp",
//                                "cudf/partitioning.hpp",
//                                "cudf/quantiles.hpp",
//                                "cudf/reduction.hpp",
//                                "cudf/replace.hpp",
//                                "cudf/reshape.hpp",
//                                "cudf/rolling.hpp",
//                                "cudf/round.hpp",
//                                "cudf/search.hpp",
//                                "cudf/sorting.hpp",
//                                "cudf/stream_compaction.hpp",
//                                "cudf/transform.hpp",
                                "cudf/transpose.hpp",
                                "cudf/column/column.hpp",
//                                "cudf/column/column_device_view.cuh",
                                "cudf/column/column_factories.hpp",
                                "cudf/column/column_view.hpp",
//                                "cudf/table/table.hpp",
//                                "cudf/table/table_view.hpp",
                                "cudf/types.hpp",
                                "cudf/unary.hpp"
                        },
                        link = "cudf@.018"
                ),
        },
        target = "ai.rapids.cudf",
        global = "ai.rapids.cudf.global.cudf"
)
public class cudf implements InfoMapper {
    static {
        Loader.checkVersion("ai.rapids", "cudf");
    }

    public void map(InfoMap infoMap) {
        infoMap.put(new Info().enumerate())
                .put(new Info("std::size_t").cast().pointerTypes("SizeTPointer").define())
                .put(new Info("CUDA_HOST_DEVICE_CALLABLE", "CUDA_DEVICE_CALLABLE").cppTypes().annotations())
                .put(new Info("std::unique_ptr<cudf::column>").annotations("@UniquePtr").valueTypes("@Cast({\"\", \"std::unique_ptr<cudf::column>\"}) column")
                        .pointerTypes("@Cast({\"\", \"std::unique_ptr<cudf::column>*\"}) column"))
                .put(new Info("std::unique_ptr<column>").annotations("@UniquePtr").valueTypes("@Cast({\"\", \"std::unique_ptr<column>\"}) column")
                        .pointerTypes("@Cast({\"\", \"std::unique_ptr<column>*\"}) column"))

                .put(new Info("std::vector<std::unique_ptr<cudf::column> >").pointerTypes("VectorUniqueColumnPointer").define())
                .put(new Info("std::pair<std::unique_ptr<column>,table_view>").pointerTypes("PairColumnTableView").define())
                .put(new Info("std::unique_ptr<cudf::column>").pointerTypes("column"))

                //.put(new Info("rmm::device_vector<thrust::pair<const char*,cudf::size_type> >").pointerTypes("DeviceVectorPair").define())
                .put(new Info("rmm::cuda_stream_view").pointerTypes("cuda_stream_view"))
                .put(new Info("rmm::device_vector<cudf::size_type>").valueTypes("@Cast({\"\", \"rmm::device_vector<cudf::size_type>\"}) offsets")
                        .pointerTypes("@Cast({\"\", \"rmm::device_vector<cudf::size_type>*\"}) offsets"))

                //.put(new Info("rmm::device_vector<thrust::pair<const char*,cudf::size_type> >").pointerTypes("StringPairDeviceVector").define())

//                .put(new Info("rmm::device_vector<thrust::pair<const char*,cudf::size_type> >").valueTypes("@Cast({\"\", \"rmm::device_vector<thrust::pair<const char*,cudf::size_type> >\"}) sizes")
//                        .pointerTypes("@Cast({\"\", \"rmm::device_vector<thrust::pair<const char*,cudf::size_type> >\"})"))
                .put(new Info("rmm::device_vector<char>").valueTypes("@Cast({\"\", \"rmm::device_vector<char>\"}) strings")
                        .pointerTypes("@Cast({\"\", \"rmm::device_vector<char>\"}) strings"))
                .put(new Info("rmm::device_vector<string_view>").pointerTypes("string_view")) //TODO: Is this actually correct? Should this maybe contain a rmm::device_vector?
                .put(new Info("rmm::device_vector<bitmask_type>").valueTypes("@Cast({\"\", \"rmm::device_vector<bitmask_type>\"}) bitmask_type")
                        .pointerTypes("@Cast({\"\", \"rmm::device_vector<bitmask_type>\"}) bitmask_type"))

                //.put(new Info("cudf::bitmask_type", "bitmask_type").pointerTypes("IntPointer").define())
                .put(new Info("bitmask_type").pointerTypes("IntPointer"))
                .put(new Info("cudf::size_type", "size_type").pointerTypes("IntPointer").define());    //TODO: Make sure IntPointer is the correct type here. Looking for int32_t from libcudf

    }
}