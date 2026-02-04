from flask import Flask

from app.core.config import Config
from app.blueprints.health import health_bp


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    app.register_blueprint(health_bp)

    return app
