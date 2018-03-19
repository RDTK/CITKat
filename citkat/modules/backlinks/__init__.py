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
    err_count = 0

    _parser = XMLParser(remove_blank_text=True)

    for file_path in glob('*/*.xml'):
        try:
            _doc = parse(file_path, parser=_parser)
            if _xpath_relation_contains(_doc, filename_wo_suffix=filename_wo_suffix) \
                    or _xpath_directDependency_contains(_doc, filename_wo_suffix=filename_wo_suffix) \
                    or _xpath_extends_contains(_doc, filename_wo_suffix=filename_wo_suffix):
                _catalog_first_child = _xpath_catalog_children(_doc)[0]
                _catalog_first_child_type = _catalog_first_child.tag[2 + len(_ns['c']):]
                _catalog_first_child_version = ''
                _catalog_first_child_version_len = 0
                if 'version' in _catalog_first_child.attrib:
                    _catalog_first_child_version = _catalog_first_child.attrib['version']
                    _catalog_first_child_version_len = -1 - len(_catalog_first_child_version)
                _catalog_first_child_filename = _xpath_catalog_fist_child_filenames(_doc)[0].text
                _catalog_first_child_filename_wo_version = _catalog_first_child_filename[:_catalog_first_child_version_len]

                if not (_catalog_first_child_type == recipe_type and _catalog_first_child_filename == filename_wo_suffix):
                    _url = '../' + _catalog_first_child_type + '/' + _catalog_first_child_filename + '.xml'
                    _title = _titles[_catalog_first_child_type]
                    _name = ''
                    if 'name' in _catalog_first_child.attrib:
                        _name = _catalog_first_child.attrib['name']
                    else:
                        _name = _catalog_first_child_filename_wo_version
                    if _title not in backlinks_items:
                        backlinks_items[_title] = dict()
                    if _name not in backlinks_items[_title]:
                        backlinks_items[_title][_name] = dict()
                    if _catalog_first_child_version and _catalog_first_child_version in backlinks_items[_title][_name]:
                        err_count += 1
                        count -= 1
                        current_app.logger.warning('Doublette entry (name and version): \n    %s\n    %s',
                                                   backlinks_items[_title][_name][_catalog_first_child_version], _url)
                    # if _catalog_first_child_version:
                    backlinks_items[_title][_name][_catalog_first_child_version] = _url
                    backlinks_items[_title][_name]['filename_wo_version'] = _catalog_first_child_filename_wo_version
                    count += 1
        except XMLSyntaxError as e:
            current_app.logger.warning('Syntax error in catalog file "%s": \n%s', file_path, e)

    if not backlinks_items:
        return ''
    return render_template('backlinks.html', **locals())
