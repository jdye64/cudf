// Targeted by JavaCPP version 1.5.4: DO NOT EDIT THIS FILE

package ai.rapids.cudf;

import java.nio.*;
import org.bytedeco.javacpp.*;
import org.bytedeco.javacpp.annotation.*;

import static org.bytedeco.javacpp.presets.javacpp.*;

import static ai.rapids.cudf.global.cudf.*;

@Namespace("cudf") @Opaque @Properties(inherit = ai.rapids.cudf.presets.Cudf.class)
public class table_view extends Pointer {
    /** Empty constructor. Calls {@code super((Pointer)null)}. */
    public table_view() { super((Pointer)null); }
    /** Pointer cast constructor. Invokes {@link Pointer#Pointer(Pointer)}. */
    public table_view(Pointer p) { super(p); }
}
