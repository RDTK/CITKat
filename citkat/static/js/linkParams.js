(function () {
    var catalog = document.querySelector('#catalog');
    var type = catalog.getAttribute('type');
    var paramString = '';
    if (type === 'distribution') {
        paramString = '?dist=' + catalog.getAttribute('data-filename') +
            '&tpl=' + catalog.getAttribute('build-generator-template') +
            '&jenkins=' + catalog.getAttribute('buildserverbaseurl');
    } else if (type === 'project' || type === 'experiment') {
        paramString = document.location.search;
    }
    if (paramString !== '') {
        Array.prototype.slice.call(catalog.querySelectorAll('.ref'), 0).forEach(function (elem) {
            elem.setAttribute('href', elem.getAttribute('href') + paramString)
        });
    }
})();