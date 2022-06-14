from algorithm.blueprints import blueprint


@blueprint.route("/index", methods=["GET"])
def index():
    return "index"
