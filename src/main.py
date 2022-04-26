from fastapi import FastAPI
import uvicorn
from api import motd, pets, health
from views import home
from starlette.staticfiles import StaticFiles

main_app = FastAPI()


def configure():
    configure_routing()


def configure_routing():
    main_app.mount('/static', StaticFiles(directory='static'), name='static')
    main_app.include_router(motd.router)
    main_app.include_router(pets.router)
    main_app.include_router(health.router)
    main_app.include_router(home.router)


if __name__ == '__main__':
    configure()
    uvicorn.run(main_app, host='0.0.0.0', port=8000)
else:
    configure()
