from collections import OrderedDict
from glob import glob

from flask import Blueprint, request, current_app, render_template
from lxml.etree import XPath, XMLParser, parse

simple_search_blueprint = Blueprint(name='simple_search', import_name=__name__, template_folder='templates', url_prefix='/search')


@simple_search_blueprint.route('/')
def search():
    """
    Very simple search.
    :return:
    """
    ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat'}
    xpath_search = XPath('/c:catalog[contains(.//*, $searchstring)]/child::node()', namespaces=ns)
    xpath_name = XPath('@name', namespaces=ns)
    xpath_version = XPath('@version', namespaces=ns)
    xpath_filename = XPath('c:filename/text()', namespaces=ns)
    results = dict()
    search_term = ''
    title = ''

    if 'catalog-directory' in current_app.config:
        for f in glob(current_app.config['catalog-directory'] + '/*/*.xml'):
            parser = XMLParser(remove_blank_text=True)
            doc = parse(f, parser=parser)
            if 's' in request.args and request.args['s']:
                search_term = request.args['s']
                title = "Search result for '" + search_term + "':"
                search_results = xpath_search(doc, searchstring=search_term)
                for i in search_results:
                    name = xpath_name(i)
                    if name:
                        name = name[0]
                        version = xpath_version(i)
                        if version:
                            name += ' (' + version[0] + ')'
                    else:
                        name = xpath_filename(i)[0]
                    fs_path = f.split('/')
                    path = fs_path[-2] + '/' + fs_path[-1]
                    results[path] = name
                    break
            else:
                title = "Error: Empty Search String."
    results = OrderedDict(sorted(results.iteritems()))

    return render_template('search.html', **locals())
