from collections import OrderedDict
from glob import glob

from flask import Blueprint, request, current_app, render_template
from lxml.etree import XPath, XMLParser, parse

simple_search_blueprint = Blueprint(name='simple_search', import_name=__name__, template_folder='templates',
                                    url_prefix='/search')


@simple_search_blueprint.route('/keyword/<string:keyword>')
@simple_search_blueprint.route('/access/<string:access>')
@simple_search_blueprint.route('/license/<string:license>')
@simple_search_blueprint.route('/nature/<string:nature>')
@simple_search_blueprint.route('/lang/<string:lang>')
@simple_search_blueprint.route('/')
def search(keyword='', access='', license='', nature='', lang=''):
    """
    Very simple search.
    :return:
    """
    ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat',
          'r': 'http://exslt.org/regular-expressions'}
    xpath_search = ''
    term = ''
    if keyword:
        xpath_search = XPath("/c:catalog/child::node()/c:keywords/c:keyword[r:test(., $searchstring, 'i')]/../..",
                             namespaces=ns)
        term = 'keyword '
    elif access:
        xpath_search = XPath("/c:catalog/child::node()/c:access[r:test(., $searchstring, 'i')]/..",
                             namespaces=ns)
        term = 'access '
    elif license:
        xpath_search = XPath("/c:catalog/child::node()/c:license[r:test(., $searchstring, 'i')]/..",
                             namespaces=ns)
        term = 'license '
    elif nature:
        xpath_search = XPath("/c:catalog/child::node()/c:natures/c:nature[r:test(., $searchstring, 'i')]/../..",
                             namespaces=ns)
        term = 'nature '
    elif lang:
        xpath_search = XPath(
            "/c:catalog/child::node()/c:programmingLanguages/c:language[r:test(., $searchstring, 'i')]/../..",
            namespaces=ns)
        term = 'programming language '
    else:
        xpath_search = XPath("/c:catalog[r:test(.//*, $searchstring, 'i')]/child::node()", namespaces=ns)
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
            if keyword or access or license or nature or lang or ('s' in request.args and request.args['s']):
                search_term = keyword or access or license or nature or lang or request.args['s']
                title = "Search result for " + term + "'" + search_term + "':"
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
