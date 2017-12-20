from collections import OrderedDict
from glob import glob

from flask import Blueprint, request, render_template, current_app
from lxml.etree import XPath, XMLParser, parse, XMLSyntaxError
from re import escape

from os import getcwd

simple_search_blueprint = Blueprint(name='simple_search', import_name=__name__, template_folder='templates',
                                    url_prefix='/search')


@simple_search_blueprint.route('/keyword/<string:keyword>')
@simple_search_blueprint.route('/access/<string:access>')
@simple_search_blueprint.route('/license/<string:license>')
@simple_search_blueprint.route('/nature/<string:nature>')
@simple_search_blueprint.route('/lang/<string:lang>')
@simple_search_blueprint.route('/scm/<string:scm>')
@simple_search_blueprint.route('/')
def search(keyword='', access='', license='', nature='', lang='', scm=''):
    """
    Very simple search.
    :return:
    """
    # TODO: highlight search result?
    ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat',
          'r': 'http://exslt.org/regular-expressions'}
    xpath_search = ''
    term = ''

    _titles = {'project': 'Project',
               'distribution': 'System',
               'experiment': 'Experiment',
               'dataset': 'Dataset',
               'hardware': 'Hardware',
               'person': 'Person'}

    if keyword:
        xpath_search = XPath("/c:catalog/child::node()/c:keywords/c:keyword[r:test(., $searchstring, 'i')]/../..",
                             namespaces=ns)
        term = 'keyword '
    elif access:
        xpath_search = XPath("/c:catalog/child::node()[r:test(@access, $searchstring, 'i')]",
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
    elif scm:
        xpath_search = XPath(
            "/c:catalog/child::node()/c:scm/c:kind[r:test(., $searchstring, 'i')]/../..",
            namespaces=ns)
        term = 'SCM kind '
    else:
        xpath_search = XPath("/c:catalog[r:test(.//*, $searchstring, 'i')]/child::node()", namespaces=ns)
    xpath_name = XPath('@name', namespaces=ns)
    xpath_version = XPath('@version', namespaces=ns)
    xpath_filename = XPath('c:filename/text()', namespaces=ns)
    results = dict()
    search_term = ''
    title = ''

    for f in glob(getcwd() + '/*/*.xml'):
        parser = XMLParser(remove_blank_text=True)
        try:
            doc = parse(f, parser=parser)
            if keyword or access or license or nature or lang or scm or ('s' in request.args and request.args['s']):
                search_term = keyword or access or license or nature or lang or scm or request.args['s']
                title = "Search result for " + term + "'" + search_term + "':"
                # emulate full text search with regexp and escape special chars:
                search_term = '\W+(?:\w+\W+){0,6}?'.join(
                    (lambda x: '\w?' + escape(x) + '\w?')(x) for x in search_term.split(' '))
                search_results = xpath_search(doc, searchstring=search_term)
                for i in search_results:
                    name = xpath_name(i)
                    recipe_type = i.tag[2 + len(ns['c']):]
                    if _titles[recipe_type] not in results:
                        results[_titles[recipe_type]] = dict()
                    if name:
                        name = name[0]
                        version = xpath_version(i)
                        if version:
                            name += ' (' + version[0] + ')'
                    else:
                        name = xpath_filename(i)[0]
                    fs_path = f.split('/')
                    path = fs_path[-2] + '/' + fs_path[-1]
                    results[_titles[recipe_type]][path] = name
                    break
            else:
                title = "Error: Empty Search String."
        except XMLSyntaxError as e:
            current_app.logger.warning('Syntax error in catalog file "%s": \n%s', f, e)
    return render_template('searchResult.html', **locals())
