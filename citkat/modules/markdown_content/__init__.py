from flask import Blueprint, Markup, render_template, abort
from markdown import Markdown
from pkg_resources import resource_stream


markdown_content_blueprint = Blueprint(name='markdown_content', import_name=__name__, url_prefix='/content')


@markdown_content_blueprint.route('/<path:fullpath>/')
def markdown_content(fullpath):
    md = Markdown(extensions=['markdown.extensions.extra',
                              'markdown.extensions.toc',
                              'markdown.extensions.meta'])
    try:
        content = Markup(md.convert(resource_stream(__name__, '../../content/' + fullpath + '.md').read()))
        title = 'Undefined'
        if 'title' in md.Meta:
            title = md.Meta['title'][0]
        return render_template('layout.html', **locals())
    except IOError:
        return abort(404)