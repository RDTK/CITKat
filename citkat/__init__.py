# -*- coding: utf-8 -*-
from flask import Flask, redirect, render_template, request
from os import environ, getcwd

from citkat.modules.browse import browse_blueprint
from citkat.modules.backlinks import backlinks_blueprint
from citkat.modules.get_versions import get_versions_blueprint
from citkat.modules.include_xml_jinja2 import include_xml_jinja2_blueprint
from citkat.modules.markdown_content import markdown_content_blueprint
from citkat.modules.simple_search import simple_search_blueprint
from citkat.modules.static_xml import static_xml_blueprint
from citkat.modules.gen_menu_items import gen_menu_items_blueprint
from citkat.modules.librejs import librejs_blueprint


citkat = Flask(__name__)

if 'CONTENT_PATH' in environ:
    citkat.config['content-directory'] = environ['CONTENT_PATH']

if 'CATALOG_PATH' in environ:
    citkat.config['catalog-directory'] = environ['CATALOG_PATH']
else:
    citkat.config['catalog-directory'] = getcwd()


citkat.register_blueprint(backlinks_blueprint)
citkat.register_blueprint(static_xml_blueprint)
citkat.register_blueprint(gen_menu_items_blueprint)
citkat.register_blueprint(browse_blueprint)
citkat.register_blueprint(include_xml_jinja2_blueprint)
citkat.register_blueprint(simple_search_blueprint)
citkat.register_blueprint(markdown_content_blueprint)
citkat.register_blueprint(get_versions_blueprint)
citkat.register_blueprint(librejs_blueprint)


@citkat.route('/')
def home():
    return redirect('/content/Home')


@citkat.errorhandler(404)
def not_found(warning):
    citkat.logger.error('404 Page not found: %s', (request.path))
    title = '404 Page Not Found.'
    return render_template('layout.html', warning=warning, title=title), 404


@citkat.errorhandler(500)
def internal_error(error):
    title = '500 Internal Server Error.'
    return render_template('layout.html', error=title, title=title), 500


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
            r.headers[
                "Content-Type"] = "text/xsl; charset=utf-8"  # Chrome accepts this type for XSL files
    except AttributeError:
        pass
    return r


def develop():
    # for developer preview of CITKat content, disable all caching
    citkat.config['no-caching'] = True
    citkat.run(host='localhost')  # bind to localhost
