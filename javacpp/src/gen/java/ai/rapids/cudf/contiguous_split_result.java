// Targeted by JavaCPP version 1.5.4: DO NOT EDIT THIS FILE

package ai.rapids.cudf;

import java.nio.*;
import org.bytedeco.javacpp.*;
import org.bytedeco.javacpp.annotation.*;

import static org.bytedeco.javacpp.presets.javacpp.*;

import static ai.rapids.cudf.global.cudf.*;


/**
 * \brief The result(s) of a {@code contiguous_split}
 *
 * \ingroup copy_split
 *
 * Each table_view resulting from a split operation performed by contiguous_split,
 * will be returned wrapped in a {@code contiguous_split_result}.  The table_view and internal
 * column_views in this struct are not owned by a top level cudf::table or cudf::column.
 * The backing memory is instead owned by the {@code all_data} field and in one
 * contiguous block.
 *
 * The user is responsible for assuring that the {@code table} or any derived table_views do
 * not outlive the memory owned by {@code all_data}
 */
@Namespace("cudf") @Properties(inherit = ai.rapids.cudf.presets.Cudf.class)
public class contiguous_split_result extends Pointer {
    static { Loader.load(); }
    /** Default native constructor. */
    public contiguous_split_result() { super((Pointer)null); allocate(); }
    /** Native array allocator. Access with {@link Pointer#position(long)}. */
    public contiguous_split_result(long size) { super((Pointer)null); allocateArray(size); }
    /** Pointer cast constructor. Invokes {@link Pointer#Pointer(Pointer)}. */
    public contiguous_split_result(Pointer p) { super(p); }
    private native void allocate();
    private native void allocateArray(long size);
    @Override public contiguous_split_result position(long position) {
        return (contiguous_split_result)super.position(position);
    }
    @Override public contiguous_split_result getPointer(long i) {
        return new contiguous_split_result(this).position(position + i);
    }

  public native @ByRef table_view table(); public native contiguous_split_result table(table_view setter);
  public native @UniquePtr device_buffer all_data(); public native contiguous_split_result all_data(device_buffer setter);
}
