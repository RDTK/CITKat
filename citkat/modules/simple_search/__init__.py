from glob import glob

from flask import Blueprint, request
from lxml.etree import XPath, XMLParser, parse

simple_search_blueprint = Blueprint(name='simple_search', import_name=__name__)


@simple_search_blueprint.route('/search')
def search():
    """
    Very simple search.
    TODO: templating
    :return:
    """
    ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat'}
    xpath_search = XPath('/c:catalog[contains(.//*, $searchstring)]', namespaces=ns)
    results = []
    for f in glob('*/*.xml'):
        parser = XMLParser(remove_blank_text=True)
        doc = parse(f, parser=parser)
        if 's' in request.args \
                and request.args['s'] \
                and xpath_search(doc, searchstring=request.args['s']):
            results.append(f)
    if results:
        return '<br>'.join(results)
    else:
        return 'nothing found'