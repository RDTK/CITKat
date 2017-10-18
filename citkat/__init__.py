# -*- coding: utf-8 -*-
# from flask_sqlalchemy import SQLAlchemy
from flask import Flask, redirect, render_template

from citkat.modules.browse import browse_blueprint
from citkat.modules.backlinks import backlinks_blueprint
from citkat.modules.include_xml_jinja2 import include_xml_jinja2_blueprint
from citkat.modules.markdown_content import markdown_content_blueprint
from citkat.modules.simple_search import simple_search_blueprint
from citkat.modules.static_xml import static_xml_blueprint
from citkat.modules.gen_menu_items import gen_menu_items_blueprint

citkat = Flask(__name__)
citkat.register_blueprint(backlinks_blueprint)
citkat.register_blueprint(static_xml_blueprint)
citkat.register_blueprint(gen_menu_items_blueprint)
citkat.register_blueprint(browse_blueprint)
citkat.register_blueprint(include_xml_jinja2_blueprint)
citkat.register_blueprint(simple_search_blueprint)
citkat.register_blueprint(markdown_content_blueprint)
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite://'  # create in-memory database
# app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
# db = SQLAlchemy()
# db.init_app(app)


@citkat.route('/')
def home():
    return redirect('/content/Home')


@citkat.errorhandler(404)
def not_found(warning):
    title = '404 Not Found'
    return render_template('layout.html', **locals()), 404


@citkat.errorhandler(500)
def not_found(error):
    title = '500 Internal Server Error'
    return render_template('layout.html', **locals()), 500


@citkat.after_request
def add_headers(r):
    """
    Add headers for caching and correct content types.
    :param r:
    :return:
    """
    if 'no-caching' in citkat.config and citkat.config['no-caching']:
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
    from os import getcwd
    # citkat.config['content-directory'] = getcwd() + '/../content'  # TODO: remove this line for production release
    citkat.config['catalog-directory'] = getcwd()  # use current working dir as catalog root
    citkat.config['no-caching'] = True  # for developer preview of CITKat content, disable all caching
    citkat.run(host='localhost')  # bind to localhost
