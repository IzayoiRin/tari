import os


def main():
    from veritas.builtin.const import ENVIRONMENT_KEY
    if os.environ.get(ENVIRONMENT_KEY) is None:
        os.environ.setdefault(ENVIRONMENT_KEY, "conf.settings")

    from app.application import get_application
    app = get_application("tari")
    print(app.app.url_map)
    app.runserver("0.0.0.0", 8000)


if __name__ == '__main__':
    main()
