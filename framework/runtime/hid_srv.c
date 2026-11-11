// See hid_srv.h.
#include <stdio.h>

#include "hid_srv.h"
#include "host.h"
#include "ipc.h"

static void hid_log_args(const IpcRequest *rq) {
    char b[160]; b[0] = 0;
    for (unsigned i = 0, n = 0; i + 8 <= rq->data_size && n < 4; i += 8, n++) {
        uint64_t w; memcpy(&w, rq->data + i, 8);
        snprintf(b + strlen(b), sizeof b - strlen(b), "%s%#llx", n ? " " : "", (unsigned long long)w);
    }
    rt_logf("hid: args [%s] (data %u bytes, x%u a%u b%u w%u, copy %u move %u)
", b,
            rq->data_size, rq->nx, rq->na, rq->nb, rq->nw, rq->ncopy, rq->nmove);
}

static void applet_resource_handler(IpcSession *s, const IpcRequest *rq, IpcResponse *rs) {
    (void)rs;
    rt_logf("hid: IAppletResource command %u
", rq->cmd);
    hid_log_args(rq);
    ipc_unimplemented(s, rq);
}

void hid_manager_handler(IpcSession *s, const IpcRequest *rq, IpcResponse *rs) {
    switch (rq->cmd) {
    case 128: {   // SetNpadHandheldActivationMode(mode)
        uint64_t mode = 0;
        if (rq->data_size >= 8) memcpy(&mode, rq->data, 8);
        rt_logf("hid: SetNpadHandheldActivationMode(%llu): ok
", (unsigned long long)mode);
        return;   // no output
    }
    case 0: {   // CreateAppletResource(userId)
        uint64_t uid0 = 0, uid1 = 0;
        if (rq->data_size >= 16) { memcpy(&uid0, rq->data, 8); memcpy(&uid1, rq->data + 8, 8); }
        rt_logf("hid: CreateAppletResource uid %#llx:%#llx
", (unsigned long long)uid0, (unsigned long long)uid1);
        rs->move[rs->nmove++] = ipc_session_new("IAppletResource", applet_resource_handler, NULL, NULL);
        return;
    }
    default:
        hid_log_args(rq);
        ipc_unimplemented(s, rq);
    }
}
