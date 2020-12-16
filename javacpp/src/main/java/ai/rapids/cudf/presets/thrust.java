package ai.rapids.cudf.presets;

import org.bytedeco.cuda.presets.cudart;
import org.bytedeco.javacpp.Loader;
import org.bytedeco.javacpp.annotation.Platform;
import org.bytedeco.javacpp.annotation.Properties;
import org.bytedeco.javacpp.tools.Info;
import org.bytedeco.javacpp.tools.InfoMap;
import org.bytedeco.javacpp.tools.InfoMapper;

@Properties(
        inherit = cudart.class,
        names = {"linux"},
        value = {
                @Platform(
                        compiler = "cpp14",
                        define = {"NO_WINDOWS_H", "UNIQUE_PTR_NAMESPACE std", "SHARED_PTR_NAMESPACE std"},
                        include = {
                                "thrust/version.h"
                        }
                ),
        },
        target = "ai.rapids.thrust",
        global = "ai.rapids.cudf.global.thrust")
public class thrust implements InfoMapper {
    static {
        Loader.checkVersion("ai.rapids", "thrust");
    }

    public void map(InfoMap infoMap) {
        infoMap.put(new Info().enumerate())
                .put(new Info("std::size_t").cast().pointerTypes("SizeTPointer").define())
                .put(new Info("CUDA_HOST_DEVICE_CALLABLE", "CUDA_DEVICE_CALLABLE").cppTypes().annotations());

    }
}


