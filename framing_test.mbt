///|
test "framing and overlap add preserve deterministic samples" {
  let frames = frame_signal(
    [1.0, 2.0, 3.0, 4.0, 5.0],
    frame_length=3,
    hop_size=2,
  )
  inspect(frames.length(), content="2")
  debug_inspect(frames[0], content="[1, 2, 3]")
  debug_inspect(frames[1], content="[3, 4, 5]")
  let rebuilt = overlap_add(frames, hop_size=2)
  debug_inspect(rebuilt, content="[1, 2, 6, 4, 5]")
}

///|
test "framing rejects invalid geometry" {
  try frame_signal([1.0, 2.0], frame_length=3, hop_size=1) catch {
    InvalidArgument(message=_) => inspect("short", content="short")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected short signal error")
  }
  try overlap_add([], hop_size=1) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("expected empty frame error")
  } noraise {
    _ => fail("expected empty frame error")
  }
}
