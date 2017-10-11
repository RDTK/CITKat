from glob import glob

from flask import Blueprint, abort

browse_blueprint = Blueprint(name='browse', import_name=__name__, url_prefix='/browse')


# TODO: implement browse + template
@browse_blueprint.route('/<path:entity>')
def browse(entity):
    for f in glob(entity + '/*.xml'):  # TODO: restrict this!
        pass  # TODO
    abort(500)  # TODO
