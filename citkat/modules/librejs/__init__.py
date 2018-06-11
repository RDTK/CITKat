from flask import Blueprint, render_template, abort
from json import loads
from pkg_resources import resource_string

librejs_blueprint = Blueprint(
    name='librejs',
    import_name=__name__,
    url_prefix='/vendor',
    template_folder='templates')


@librejs_blueprint.route('/librejs.html')
def librejs_page():
    title = 'JavaScript Licenses'
    try:
        data = loads(resource_string(__name__, 'licenses.json').decode('utf8'))
    except FileNotFoundError:
        warning = "<code>licenses.json</code> not in the servers file system."
        return abort(404, warning)
    return render_template('librejs.html', **locals())
