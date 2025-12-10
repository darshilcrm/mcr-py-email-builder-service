import email_routes
from functools import partial
from fastapi import FastAPI, APIRouter
from mcr_py_common.common_server_config.mcr_service_meta import PyMcrServiceMeta
from mcr_py_common.common_server_config.event_bus import eventbus
from mcr_py_common.common_server_config.mcr_common_service_list import (
    get_mcr_service_name_by_devops_name,
    MCR_PY_SERVICES,
)

def initialize(app: FastAPI | APIRouter, meta: PyMcrServiceMeta):
    print("inside init")
    if meta:
        eventbus.emit(
            get_mcr_service_name_by_devops_name(
                MCR_PY_SERVICES.MCR_PY_EMAIL_BUILDER_SERVICE.value 
            )
            + "_emit",
            meta,
        )
    path = "py-email-builder"
    base_path = "/" + (MCR_PY_SERVICES.MCR_PY_EMAIL_BUILDER_SERVICE.value if meta else path)
    print(base_path)
    router = APIRouter(prefix=base_path)
    router.add_api_route(
        path="/generate",
        endpoint=partial(email_routes.generate),
        methods=["POST"],
    )

    app.include_router(router)
    return app