package ai.rapids.cudf.presets;

import org.bytedeco.javacpp.Loader;
import org.bytedeco.javacpp.annotation.Platform;
import org.bytedeco.javacpp.annotation.Properties;
import org.bytedeco.javacpp.presets.javacpp;
import org.bytedeco.javacpp.tools.Info;
import org.bytedeco.javacpp.tools.InfoMap;
import org.bytedeco.javacpp.tools.InfoMapper;


@Properties(
        inherit = javacpp.class,
        names = {"linux"},
        value = {
                @Platform(
                        compiler = "cpp14",
                        define = {"NO_WINDOWS_H", "UNIQUE_PTR_NAMESPACE std", "SHARED_PTR_NAMESPACE std"},
                        include = {
                                "cudf/aggregation.hpp",
                                "cudf/binaryop.hpp",
                                "cudf/concatenate.hpp",
                                "cudf/copying.hpp",
                                "cudf/datetime.hpp",
                                "cudf/filling.hpp",
                                "cudf/groupby.hpp",
                                "cudf/hashing.hpp",
                                "cudf/interop.hpp",
                                "cudf/ipc.hpp",
                                "cudf/join.hpp",
                                "cudf/merge.hpp",
                                "cudf/null_mask.hpp",
                                "cudf/partitioning.hpp",
                                "cudf/quantiles.hpp",
                                "cudf/reduction.hpp",
                                "cudf/replace.hpp",
                                "cudf/reshape.hpp",
                                "cudf/rolling.hpp",
                                "cudf/round.hpp",
                                "cudf/search.hpp",
                                "cudf/sorting.hpp",
                                "cudf/stream_compaction.hpp",
                                "cudf/transform.hpp",
                                "cudf/transpose.hpp",
                                "cudf/types.hpp",
                                "cudf/unary.hpp"
                        },
                        link = "cudf@.018"
                ),
        },
        target = "ai.rapids.cudf",
        global = "ai.rapids.cudf.global.cudf"
)
public class Cudf implements InfoMapper {
    static { Loader.checkVersion("ai.rapids", "cudf"); }

    public void map(InfoMap infoMap) {
        infoMap.put(new Info().enumerate())
        .put(new Info("defined(__cplusplus)").define())
        .put(new Info("std::size_t").cast().pointerTypes("SizeTPointer").define())
        .put(new Info("CUDA_HOST_DEVICE_CALLABLE", "CUDA_DEVICE_CALLABLE").cppTypes().annotations())
        .put(new Info("std::vector<cudf::column>").pointerTypes("ColumnVector").define())
        .put(new Info("std::unique_ptr<cudf::column>").pointerTypes("UniqueColumnPointer").define())
        .put(new Info("rmm::cuda_stream_view").pointerTypes("CudaStreamView").define());
    }
}