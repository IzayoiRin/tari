import os.path

DEBUG = True
SECRET_KEY = "d48ab99190afb1277ff73ab71206d571"
JSON_AS_ASCII = False

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
REGISTERED_CONTROLLERS = [
    "algorithm",
]
