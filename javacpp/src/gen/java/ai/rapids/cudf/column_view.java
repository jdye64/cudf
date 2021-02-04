// Targeted by JavaCPP version 1.5.4: DO NOT EDIT THIS FILE

package ai.rapids.cudf;

import java.nio.*;
import org.bytedeco.javacpp.*;
import org.bytedeco.javacpp.annotation.*;

import static org.bytedeco.javacpp.presets.javacpp.*;
import org.bytedeco.cuda.cudart.*;
import static org.bytedeco.cuda.global.cudart.*;

import static ai.rapids.cudf.global.cudf.*;
  // namespace detail

/**
 * \brief A non-owning, immutable view of device data as a column of elements,
 * some of which may be null as indicated by a bitmask.
 *
 * \ingroup column_classes
 *
 * A {@code column_view} can be constructed implicitly from a {@code cudf::column}, or may
 * be constructed explicitly from a pointer to pre-existing device memory.
 *
 * Unless otherwise noted, the memory layout of the {@code column_view}'s data and
 * bitmask is expected to adhere to the Arrow Physical Memory Layout
 * Specification: https://arrow.apache.org/docs/memory_layout.html
 *
 * Because {@code column_view} is non-owning, no device memory is allocated nor freed
 * when {@code column_view} objects are created or destroyed.
 *
 * To enable zero-copy slicing, a {@code column_view} has an {@code offset} that indicates
 * the index of the first element in the column relative to the base device
 * memory allocation. By default, {@code offset()} is zero.
 *
 **/
@Namespace("cudf") @NoOffset @Properties(inherit = ai.rapids.cudf.presets.cudf.class)
public class column_view extends column_view_base {
    static { Loader.load(); }
    /** Pointer cast constructor. Invokes {@link Pointer#Pointer(Pointer)}. */
    public column_view(Pointer p) { super(p); }
    /** Native array allocator. Access with {@link Pointer#position(long)}. */
    public column_view(long size) { super((Pointer)null); allocateArray(size); }
    private native void allocateArray(long size);
    @Override public column_view position(long position) {
        return (column_view)super.position(position);
    }
    @Override public column_view getPointer(long i) {
        return new column_view(this).position(position + i);
    }

  public column_view() { super((Pointer)null); allocate(); }
  private native void allocate();

  // these pragmas work around the nvcc issue where if a column_view is used
  // inside of a __device__ code path, these functions will end up being created
  // as __host__ __device__ because they are explicitly defaulted.  However, if
  // they then end up being called by a simple __host__ function
  // (eg std::vector destructor) you get a compile error because you're trying to
  // call a __host__ __device__ function from a __host__ function.
// #pragma nv_exec_check_disable
// #pragma nv_exec_check_disable
  public column_view(@Const @ByRef column_view c) { super((Pointer)null); allocate(c); }
  private native void allocate(@Const @ByRef column_view c);
  public native @ByRef @Name("operator =") column_view put(@Const @ByRef column_view arg0);

  /**
   * \brief Construct a {@code column_view} from pointers to device memory for the
   * elements and bitmask of the column.
   *
   * If {@code null_count()} is zero, {@code null_mask} is optional.
   *
   * If the null count of the {@code null_mask} is not specified, it defaults to
   * {@code UNKNOWN_NULL_COUNT}. The first invocation of {@code null_count()} will then
   * compute the null count if {@code null_mask} exists.
   *
   * If {@code type} is {@code EMPTY}, the specified {@code null_count} will be ignored and
   * {@code null_count()} will always return the same value as {@code size()}
   *
   * @throws cudf::logic_error if {@code size < 0}
   * @throws cudf::logic_error if {@code size > 0} but {@code data == nullptr}
   * @throws cudf::logic_error if {@code type.id() == EMPTY} but {@code data != nullptr}
   *or {@code null_mask != nullptr}
   * @throws cudf::logic_error if {@code null_count > 0}, but {@code null_mask == nullptr}
   * @throws cudf::logic_error if {@code offset < 0}
   *
   * @param type The element type
   * @param size The number of elements
   * @param data Pointer to device memory containing the column elements
   * @param null_mask Optional, pointer to device memory containing the null
   * indicator bitmask
   * @param null_count Optional, the number of null elements.
   * @param offset optional, index of the first element
   * @param children optional, depending on the element type, child columns may
   * contain additional data
   */
  public column_view(@ByVal data_type type,
                @ByVal IntPointer size,
                @Const Pointer data,
                @Const IntPointer null_mask/*=nullptr*/,
                @ByVal(nullValue = "cudf::size_type(UNKNOWN_NULL_COUNT)") IntPointer null_count,
                @ByVal(nullValue = "cudf::size_type(0)") IntPointer offset,
                @StdVector column_view children/*={}*/) { super((Pointer)null); allocate(type, size, data, null_mask, null_count, offset, children); }
  private native void allocate(@ByVal data_type type,
                @ByVal IntPointer size,
                @Const Pointer data,
                @Const IntPointer null_mask/*=nullptr*/,
                @ByVal(nullValue = "cudf::size_type(UNKNOWN_NULL_COUNT)") IntPointer null_count,
                @ByVal(nullValue = "cudf::size_type(0)") IntPointer offset,
                @StdVector column_view children/*={}*/);
  public column_view(@ByVal data_type type,
                @ByVal IntPointer size,
                @Const Pointer data) { super((Pointer)null); allocate(type, size, data); }
  private native void allocate(@ByVal data_type type,
                @ByVal IntPointer size,
                @Const Pointer data);

  /**
   * \brief Returns the specified child
   *
   * @param child_index The index of the desired child
   * @return column_view The requested child {@code column_view}
   */
  public native @ByVal @NoException column_view child(@ByVal IntPointer child_index);

  /**
   * \brief Returns the number of child columns.
   **/
  public native @ByVal @NoException IntPointer num_children();

  /**
   * \brief Returns iterator to the beginning of the ordered sequence of child column-views.
   */
  public native @ByVal @NoException auto child_begin();

  /**
   * \brief Returns iterator to the end of the ordered sequence of child column-views.
   */
  public native @ByVal @NoException auto child_end();
}
