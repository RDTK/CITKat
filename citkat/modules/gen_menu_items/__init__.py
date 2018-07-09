from os import listdir
from flask import Blueprint, current_app, render_template, safe_join
from os.path import isfile, isdir

gen_menu_items_blueprint = Blueprint(name='gen_menu_items', import_name=__name__, url_prefix='/menu',
                                     template_folder='templates')


@gen_menu_items_blueprint.route('/additionalMenuItems.xml')
def gen_menu_items():
    """
    generate menu items, including dropdowns from file listing.
    :return: XML file with additional menu items.
    """
    if 'content-directory' not in current_app.config:
        return render_template('menu.xml')
    menu_items = []
    content_root = current_app.config['content-directory']
    for itm in listdir(content_root):
        path = safe_join(content_root, itm)
        if isfile(path) and not itm == 'Home.md':  # and not itm == 'About.md':
            menu_items.append(itm[:-3])
        elif isdir(path):
            directory = {itm: []}
            for subitm in listdir(path):
                if isfile(safe_join(path, subitm)):
                    directory[itm].append(subitm[:-3])
            directory[itm] = sorted(directory[itm])
            menu_items.append(directory)
    return render_template('menu.xml', **locals())
