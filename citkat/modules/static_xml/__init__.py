from flask import Blueprint, safe_join, request, send_from_directory
from os import getcwd

static_xml_blueprint = Blueprint(name='static_xml', import_name=__name__)


@static_xml_blueprint.route('/project/<path:filename>')
@static_xml_blueprint.route('/experiment/<path:filename>')
@static_xml_blueprint.route('/person/<path:filename>')
@static_xml_blueprint.route('/dataset/<path:filename>')
@static_xml_blueprint.route('/distribution/<path:filename>')
@static_xml_blueprint.route('/publication/<path:filename>')
@static_xml_blueprint.route('/hardware/<path:filename>')
def static_page(filename):
    catalog_directory = safe_join(getcwd(), request.path.split('/')[1])
    return send_from_directory(catalog_directory, filename)
