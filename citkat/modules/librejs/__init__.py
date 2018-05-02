from flask import Blueprint, render_template, abort
from json import load
from pkg_resources import resource_stream

librejs_blueprint = Blueprint(
    name='librejs',
    import_name=__name__,
    url_prefix='/vendor',
    template_folder='templates')


@librejs_blueprint.route('/librejs.html')
def librejs_page():
    title = 'JavaScript Licenses'
    try:
        data = load(resource_stream(__name__, 'licenses.json'))
    except FileNotFoundError as e:
        warning = "<code>licenses.json</code> not in the servers file system."
        return abort(404, warning)
    return render_template('librejs.html', **locals())
