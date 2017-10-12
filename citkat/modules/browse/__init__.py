from glob import glob

from flask import Blueprint, render_template, current_app, safe_join, abort
from lxml.etree import XPath, XMLParser, parse

browse_blueprint = Blueprint(name='browse', import_name=__name__, url_prefix='/browse', template_folder='templates')


class Browse(object):
    def __init__(self):
        ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat'}
        self.xpath_entity_name = XPath('/c:catalog/child::node()/@name', namespaces=ns)
        self.xpath_entity_version = XPath('/c:catalog/child::node()/@version', namespaces=ns)

    def get_name(self, entity, file):
        parser = XMLParser(remove_blank_text=True)
        doc = parse(entity + file, parser=parser)
        name = self.xpath_entity_name(doc)
        if not name:
            name = file[:-4]
        else:
            name = name[0]
        versions = self.xpath_entity_version(doc)
        if versions:
            name += ' (' + versions[0] + ')'
        return name


titles = {'project': 'Project Versions',
          'distribution': 'System Versions',
          'experiment': 'Experiments',
          'dataset': 'Datasets',
          'hardware': 'Hardware Versions'}


# TODO: pagenation, sort, images?
@browse_blueprint.route('/<path:entity>')
def browse(entity):
    if 'catalog-directory' not in current_app.config:
        return abort(500, "app.config['catalog-directory'] is not set!")
    title = 'Browse ' + titles[entity[:-1]]
    listing = dict()
    b = Browse()
    for itm in glob(safe_join(current_app.config['catalog-directory'], entity, '*.xml')):
        listing[itm.split('/')[-1]] = b.get_name(entity, itm.split('/')[-1])
    return render_template('browse.html', **locals())
