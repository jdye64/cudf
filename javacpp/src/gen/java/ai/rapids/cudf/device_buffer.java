// Targeted by JavaCPP version 1.5.4: DO NOT EDIT THIS FILE

package ai.rapids.cudf;

import java.nio.*;
import org.bytedeco.javacpp.*;
import org.bytedeco.javacpp.annotation.*;

import static org.bytedeco.javacpp.presets.javacpp.*;
import org.bytedeco.cuda.cudart.*;
import static org.bytedeco.cuda.global.cudart.*;
import ai.rapids.thrust.*;
import static ai.rapids.cudf.global.thrust.*;
import ai.rapids.rmm.*;
import static ai.rapids.cudf.global.rmm.*;

import static ai.rapids.cudf.global.cudf.*;


// Forward declarations
@Namespace("rmm") @Opaque @Properties(inherit = ai.rapids.cudf.presets.cudf.class)
public class device_buffer extends Pointer {
    /** Empty constructor. Calls {@code super((Pointer)null)}. */
    public device_buffer() { super((Pointer)null); }
    /** Pointer cast constructor. Invokes {@link Pointer#Pointer(Pointer)}. */
    public device_buffer(Pointer p) { super(p); }
}
