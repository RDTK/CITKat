from flask import Blueprint
from lxml.etree import XMLParser, parse, tostring as xml_to_string, fromstring as xml_from_string
from pkg_resources import resource_stream
from lxml.html import fragment_fromstring as html_fragment_from_string, tostring as html_to_string
from citkat.modules.gen_menu_items import gen_menu_items

include_xml_jinja2_blueprint = Blueprint(name='include_xml_jinja2', import_name=__name__)


@include_xml_jinja2_blueprint.app_template_global()
def include_xml_template(template_name):
    parser = XMLParser(remove_blank_text=True)
    # resource path is relative to the modules path, therefor '../../static/templates/'
    doc = parse(resource_stream(__name__, '../../static/templates/' + template_name), parser=parser)
    html_fragments_str = ''
    for elem in doc.xpath('/child::node()/*'):
        # because Jinja2 produces HTML5 instead of XHTML, we need to re-parse the fragments:
        html_fragments_str += html_to_string(html_fragment_from_string(xml_to_string(elem)))
    return html_fragments_str


@include_xml_jinja2_blueprint.app_template_global()
def include_additional_menu_items():
    parser = XMLParser(remove_blank_text=True)
    doc = xml_from_string(gen_menu_items(), parser=parser)
    html_fragments_str = ''
    for elem in doc.xpath('/child::node()/*'):
        # because Jinja2 produces HTML5 instead of XHTML, we need to re-parse the fragments:
        html_fragments_str += html_to_string(html_fragment_from_string(xml_to_string(elem)))
    return html_fragments_str