import os


def main():
    """
    runserver entrance
    env configure key:
        VERITAS_APPLICATION_SETTINGS

    support config protocol:
        - module: "module:conf.settings"
        - url: "url:http://conf/settings"
        - json: "json:./conf/settings.json"
    """
    from veritas.builtin.const import ENVIRONMENT_KEY
    if os.environ.get(ENVIRONMENT_KEY) is None:
        os.environ.setdefault(ENVIRONMENT_KEY, "module:conf.settings")

    from app.application import get_application
    app = get_application("tari")
    print(app.app.url_map)
    app.runserver("0.0.0.0", 8000)


if __name__ == '__main__':
    main()
