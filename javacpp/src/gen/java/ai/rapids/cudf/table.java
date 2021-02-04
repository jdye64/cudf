// Targeted by JavaCPP version 1.5.4: DO NOT EDIT THIS FILE

package ai.rapids.cudf;

import java.nio.*;
import org.bytedeco.javacpp.*;
import org.bytedeco.javacpp.annotation.*;

import static org.bytedeco.javacpp.presets.javacpp.*;
import org.bytedeco.cuda.cudart.*;
import static org.bytedeco.cuda.global.cudart.*;

import static ai.rapids.cudf.global.cudf.*;


@Namespace("cudf") @Opaque @Properties(inherit = ai.rapids.cudf.presets.cudf.class)
public class table extends Pointer {
    /** Empty constructor. Calls {@code super((Pointer)null)}. */
    public table() { super((Pointer)null); }
    /** Pointer cast constructor. Invokes {@link Pointer#Pointer(Pointer)}. */
    public table(Pointer p) { super(p); }
}
