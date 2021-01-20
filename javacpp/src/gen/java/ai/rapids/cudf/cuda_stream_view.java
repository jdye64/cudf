// Targeted by JavaCPP version 1.5.4: DO NOT EDIT THIS FILE

package ai.rapids.cudf;

import java.nio.*;
import org.bytedeco.javacpp.*;
import org.bytedeco.javacpp.annotation.*;

import static org.bytedeco.javacpp.presets.javacpp.*;
import org.bytedeco.cuda.cudart.*;
import static org.bytedeco.cuda.global.cudart.*;

import static ai.rapids.cudf.global.cudf.*;


/**
 * \brief Strongly-typed non-owning wrapper for CUDA streams with default constructor.
 *
 * This wrapper is simply a "view": it does not own the lifetime of the stream it wraps.
 */
@Namespace("rmm") @NoOffset @Properties(inherit = ai.rapids.cudf.presets.cudf.class)
public class cuda_stream_view extends Pointer {
    static { Loader.load(); }
    /** Pointer cast constructor. Invokes {@link Pointer#Pointer(Pointer)}. */
    public cuda_stream_view(Pointer p) { super(p); }
    /** Native array allocator. Access with {@link Pointer#position(long)}. */
    public cuda_stream_view(long size) { super((Pointer)null); allocateArray(size); }
    private native void allocateArray(long size);
    @Override public cuda_stream_view position(long position) {
        return (cuda_stream_view)super.position(position);
    }
    @Override public cuda_stream_view getPointer(long i) {
        return new cuda_stream_view(this).position(position + i);
    }

  public cuda_stream_view() { super((Pointer)null); allocate(); }
  private native void allocate();
  public cuda_stream_view(@Const @ByRef cuda_stream_view arg0) { super((Pointer)null); allocate(arg0); }
  private native void allocate(@Const @ByRef cuda_stream_view arg0);
  public native @Const @ByRef @Name("operator =") cuda_stream_view put(@Const @ByRef cuda_stream_view arg0);

  // TODO disable construction from 0 after cuDF and others adopt cuda_stream_view
  // cuda_stream_view(int)            = delete; //< Prevent cast from 0
  // cuda_stream_view(std::nullptr_t) = delete; //< Prevent cast from nullptr
  // TODO also disable implicit conversion from cudaStream_t

  /**
   * \brief Implicit conversion from cudaStream_t.
   */
  public cuda_stream_view(CUstream_st stream) { super((Pointer)null); allocate(stream); }
  @NoException private native void allocate(CUstream_st stream);

  /**
   * \brief Get the wrapped stream.
   *
   * @return cudaStream_t The wrapped stream.
   */
  public native @NoException CUstream_st value();

  /**
   * \brief Explicit conversion to cudaStream_t.
   */
  public native @Name("operator cudaStream_t") @NoException CUstream_st asCUstream_st();

  /**
   * \brief Return true if the wrapped stream is the CUDA per-thread default stream.
   */
  public native @Cast("bool") @NoException boolean is_per_thread_default();

  /**
   * \brief Return true if the wrapped stream is explicitly the CUDA legacy default stream.
   */
  public native @Cast("bool") @NoException boolean is_default();

  /**
   * \brief Synchronize the viewed CUDA stream.
   *
   * Calls {@code cudaStreamSynchronize()}.
   *
   * @throws rmm::cuda_error if stream synchronization fails
   */
  public native void synchronize();

  /**
   * \brief Synchronize the viewed CUDA stream. Does not throw if there is an error.
   *
   * Calls {@code cudaStreamSynchronize()} and asserts if there is an error.
   */
  public native @NoException void synchronize_no_throw();
}
