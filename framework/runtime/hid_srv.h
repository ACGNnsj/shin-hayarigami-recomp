// hid service (IHidServer under "hid"): setup IPC for nn::hid.
// The nn::hid API itself is served by host overrides in ov_input.c (host
// input read directly, no shared memory); this file only answers the setup
// IPC the game sends at boot. Unknown commands log their raw arguments and
// stop so the next one can be implemented (empirical loop).
#pragma once
#include "ipc.h"

// IHidServer, served under "hid" (ipc.c's service table).
void hid_manager_handler(IpcSession *s, const IpcRequest *rq, IpcResponse *rs);
