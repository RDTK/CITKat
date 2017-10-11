# -*- coding: utf-8 -*-
# from flask_sqlalchemy import SQLAlchemy
from os import getcwd

from flask import Flask, abort, render_template, redirect
from pkg_resources import resource_stream

from citkat.modules.browse import browse_blueprint
from citkat.modules.backlinks import backlinks_blueprint
from citkat.modules.include_xml_jinja2 import include_xml_jinja2_blueprint
from citkat.modules.simple_search import simple_search_blueprint
from citkat.modules.static_xml import static_xml_blueprint
from citkat.modules.gen_menu_items import gen_menu_items_blueprint

app = Flask(__name__)
app.register_blueprint(backlinks_blueprint)
app.register_blueprint(static_xml_blueprint)
app.register_blueprint(gen_menu_items_blueprint)
app.register_blueprint(browse_blueprint)
app.register_blueprint(include_xml_jinja2_blueprint)
app.register_blueprint(simple_search_blueprint)
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite://'  # create in-memory database
# app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
# db = SQLAlchemy()
# db.init_app(app)


@app.route('/')
def home():
    return redirect('/content/home')


@app.route('/content/<path:fullpath>')
def content(fullpath):
    try:
        f = resource_stream(__name__, 'content/' + fullpath + '.md')
        body_str = f.read()
        return render_template('layout.html', body_markdown=body_str, title='TODO')
    except IOError:
        return abort(404)


@app.after_request
def add_headers(r):
    """
    Add headers for caching and correct content types.
    :param r:
    :return:
    """
    if app.config['no-caching']:
        r.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
        r.headers['Pragma'] = 'no-cache'
        r.headers['Expires'] = '0'
        r.headers['Cache-Control'] = 'public, max-age=0'
    # manipulate content type for XSL files, so Chrome won't complain:
    try:
        if r.response.file.name.endswith('.xsl'):
            r.headers["Content-Type"] = "text/xsl; charset=utf-8"  # Chrome accepts this type for XSL files
    except AttributeError:
        pass
    return r


def develop():
    app.config['catalog-directory'] = getcwd()  # use current working dir as catalog root
    app.config['no-caching'] = True  # for developer preview of CITKat content, disable all caching
    app.run(host='localhost')  # bind to localhost
