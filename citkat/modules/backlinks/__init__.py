from glob import glob
from flask import Blueprint, current_app, render_template
from lxml.etree import XPath, XMLParser, parse, XMLSyntaxError

backlinks_blueprint = Blueprint(name='backlinks', import_name=__name__, url_prefix='/api/backlinks',
                                static_folder='static', template_folder='templates')


@backlinks_blueprint.route('/<string:recipe_type>/<string:filename_wo_suffix>.xml')
def gen_backlinks_page(recipe_type, filename_wo_suffix):

    _ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat'}
    _xpath_relation_contains = XPath('//c:relation/text() = $filename_wo_suffix', namespaces=_ns)
    _xpath_directDependency_contains = XPath('//c:directDependency/text() = $filename_wo_suffix', namespaces=_ns)
    _xpath_extends_contains = XPath('//c:extends/text() = $filename_wo_suffix', namespaces=_ns)
    _xpath_catalog_children = XPath('/c:catalog/child::node()', namespaces=_ns)
    _xpath_catalog_fist_child_filenames = XPath('/c:catalog/child::node()/c:filename', namespaces=_ns)

    _titles = {'project': 'Project',
              'distribution': 'System',
              'experiment': 'Experiment',
              'dataset': 'Dataset',
              'hardware': 'Hardware',
              'person': 'Person'}

    count = 0
    backlinks_items = dict()

    _parser = XMLParser(remove_blank_text=True)

    for file_path in glob('*/*.xml'):
        try:
            _doc = parse(file_path, parser=_parser)
            if _xpath_relation_contains(_doc, filename_wo_suffix=filename_wo_suffix) \
                    or _xpath_directDependency_contains(_doc, filename_wo_suffix=filename_wo_suffix) \
                    or _xpath_extends_contains(_doc, filename_wo_suffix=filename_wo_suffix):
                _catalog_first_child = _xpath_catalog_children(_doc)[0]
                _catalog_first_child_type = _catalog_first_child.tag[2 + len(_ns['c']):]
                _catalog_first_child_version = _catalog_first_child.attrib['version']
                _catalog_first_child_filename = _xpath_catalog_fist_child_filenames(_doc)[0].text
                _catalog_first_child_filename_wo_version = _catalog_first_child_filename[
                                                          :-1 - len(_catalog_first_child_version)]
                _url = '../' + _catalog_first_child_type + '/' + _catalog_first_child_filename + '.xml'
                _name = ''
                title = _titles[_catalog_first_child_type]
                if 'name' in _catalog_first_child.attrib:
                    _name = _catalog_first_child.attrib['name']
                else:
                    _name = _catalog_first_child_filename_wo_version
                if title not in backlinks_items:
                    backlinks_items[title] = dict()
                if _name not in backlinks_items[title]:
                    backlinks_items[title][_name] = dict()
                backlinks_items[title][_name][_catalog_first_child_version] = _url
                backlinks_items[title][_name]['filename_wo_version'] = _catalog_first_child_filename_wo_version
                count += 1
        except XMLSyntaxError as e:
            current_app.logger.warning('Syntax error in catalog file "%s": \n%s', file_path, e)

    if not backlinks_items:
        return ''
    return render_template('backlinks.html', **locals())
