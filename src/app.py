from routes import initialize
from mcr_py_common.server_config.server import app, start_server


app = initialize(app , None)

if __name__ == "__main__":
    # import uvicorn
    # uvicorn.run(app, port=8080)
    start_server()