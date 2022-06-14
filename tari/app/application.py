import os
import typing

from flask import Flask, Blueprint

from veritas.builtin.const import ENVIRONMENT_KEY
from veritas.conf.settings import LazySettings
from veritas.kit.application.app import Applications
from veritas.kit.application.controller import AppController


class FlaskApplications(Applications):
    apps: typing.Dict[str, Flask] = dict()

    def construct(self):
        return Flask(self.name)

    def configure(self, conf: LazySettings) -> None:
        self.app.config.from_mapping(conf.asDict())

    def register(self, blueprint) -> None:
        self.app.register_blueprint(blueprint)

    def runserver(self, host: str, port: int):
        self.app.run(host=host, port=port)


def get_application(name: str, setup: bool = True):
    wsgi = FlaskApplications(name)
    if setup and wsgi.isSetup() is False:
        settings = os.environ.get(ENVIRONMENT_KEY)
        wsgi.setup(settings)

    return wsgi


class FlaskController(AppController):

    def get_current_app(self):
        return get_application(self.app_name, setup=False)

    def create_blueprint(self):
        namespace = self.get_namespace()
        return Blueprint(namespace, self.__class__.__name__, url_prefix="/%s" % namespace)

    def register2bp(self, blueprint) -> None:
        if isinstance(blueprint, Blueprint):
            self.blueprint.register_blueprint(blueprint)
