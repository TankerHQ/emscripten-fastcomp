# RUN: llvm-mc -filetype=obj -triple x86_64-pc-linux-gnu %s -o - \
# RUN:   | llvm-objdump -disassemble -no-show-raw-insn - | FileCheck %s

# Will be bundle-aligning to 16 byte boundaries
  .bundle_align_mode 4
  .text
# CHECK-LABEL: foo
foo:
# Test that bundle alignment mode can be set more than once.
  .bundle_align_mode 4
# Each of these callq instructions is 5 bytes long
  callq bar
  callq bar
  .bundle_lock
  .bundle_lock
  callq bar
  callq bar     
  .bundle_unlock
  .bundle_unlock
# CHECK:      10: callq
# CHECK-NEXT: 15: callq

  .p2align 4
# CHECK-LABEL: bar
bar:
  callq foo
  callq foo
# Check that the callqs get bundled together, and that the whole group is
# align_to_end
  .bundle_lock 
  callq bar
  .bundle_lock align_to_end
  callq bar
  .bundle_unlock
  .bundle_unlock
# CHECK:      36: callq
# CHECK-NEXT: 3b: callq

# CHECK-LABEL: baz
baz:
  callq foo
  callq foo
# Check that the callqs get bundled together, and that the whole group is
# align_to_end (with the outer directive marked align_to_end)
  .bundle_lock align_to_end
  callq bar
  .bundle_lock
  callq bar
  .bundle_unlock
  .bundle_unlock
# CHECK:      56: callq
# CHECK-NEXT: 5b: callq

# CHECK-LABEL: quux
quux:
  callq bar
  callq bar
  .bundle_lock
  .bundle_lock
  callq bar
  .bundle_unlock
  callq bar     
  .bundle_unlock
# Check that the calls are bundled together when the second one is after the
# inner nest is closed.
# CHECK:      70: callq
# CHECK-NEXT: 75: callq
