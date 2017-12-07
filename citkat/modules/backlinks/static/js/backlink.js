(function () {
    function loadJSON(url, callback) {
        var request = new XMLHttpRequest();
        request.overrideMimeType('application/json');
        request.open('GET', url, true);
        request.onreadystatechange = function () {
            if (request.readyState === 4 && request.status === 200) {
                callback(request.responseText)
            }
        };
        request.send(null)
    }

    function octiconHTML(which) {
        return '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" class="octicon octicon-' + which + '"><use xlink:href="#' + which + '"></use></svg>';
    }

    function setupCard(backlinksDiv) {
        var cardDiv = document.createElement('div');
        backlinksDiv.appendChild(cardDiv);
        cardDiv.setAttribute('class', 'card-header');

        var h = document.createElement('h5');
        cardDiv.appendChild(h);
        h.innerHTML = octiconHTML('link');

        var text = ''
        switch(type) {
        case 'person':
            text = 'Person involved in:';
            break;
        default:
            text = 'Recipe used by:';
        }
        h.appendChild(document.createTextNode(text));

        var cardBodyDiv = document.createElement('div');
        backlinksDiv.appendChild(cardBodyDiv);
        cardBodyDiv.setAttribute('class', 'card-body hideContent');
        return [ h, cardBodyDiv ];
    }

    function emitCountBadge(h, count) {
        var countBadge = document.createElement('small');
        h.appendChild(countBadge);

        var countSpan = document.createElement('span');
        countBadge.appendChild(countSpan);
        countSpan.setAttribute('class', 'badge badge-pill badge-info');
        countSpan.setAttribute('style', 'float: right;');
        countSpan.appendChild(document.createTextNode(count));
    }

    function emitElementWithVersions(ul, versions) {
        var prototype = versions[0]
        var type = prototype['type']
        var name = prototype['name']
        var version = prototype['version']

        var li = document.createElement('li');
        ul.appendChild(li);

        var icon = ''
        switch (type) {
        case 'distribution':
            icon = octiconHTML('bug')
            break;
        default:
            icon = octiconHTML(type)
        }
        var iconSpan = document.createElement('span');
        li.appendChild(iconSpan);
        iconSpan.innerHTML = icon;

        li.appendChild(document.createTextNode(name + ' - '));

        var first = true;
        if (versions.length == 1) {
            versionSpan = document.createElement('span');
            versionSpan.innerHTML = '<a href="../' + versions[0]['path'] + '">' + versions[0]['version'] + '</a>';
            li.appendChild(versionSpan);
        } else if (versions.length > 1) {
            var label = versions[0]['path'].substring(versions[0]['type'].length + 1, versions[0]['path'].length - versions[0]['version'].length - 5)
            var dropdownSpan = document.createElement('span');
            li.appendChild(dropdownSpan);
            dropdownSpan.setAttribute('class', 'dropdown');
            dropdownSpan.setAttribute('id', label)
            dropdownSpan.innerHTML = '<a href="javascript:void(0);" class="dropdown-toggle" title="Show versions" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">' + versions.length + ' versions</a>';
            var dropdownDiv =  document.createElement('div');
            dropdownSpan.appendChild(dropdownDiv);
            dropdownDiv.setAttribute('class', 'dropdown-menu dropdown-menu-right');
            dropdownDiv.setAttribute('aria-labelledby', label);
            versions.forEach(function (version) {
                var anchor = document.createElement('a');
                dropdownDiv.appendChild(anchor);
                anchor.setAttribute('class', 'dropdown-item');
                anchor.setAttribute('href', '../' + version['path']);
                anchor.appendChild(document.createTextNode(version['version']));
            });
        }
    }

    function emitListWithVersions(cardBodyDiv, elements) {
        var ul = document.createElement('ul');
        cardBodyDiv.appendChild(ul);

        for (var name in elements) {
            emitElementWithVersions(ul, elements[name]);
        };
    }

    var backlinksDiv = document.querySelector('#backlinks');

    var type = backlinksDiv.getAttribute('type');
    var parameter = backlinksDiv.getAttribute('data-backlinks');

    loadJSON('/api/backlinks/' + type + '/' + parameter, function (response) {
        var elements = JSON.parse(response);
        if (elements.length > 0) {
            var temp = setupCard(backlinksDiv);
            var h = temp[0], cardBodyDiv = temp[1];

            var groups = {};
            var count = 0;
            elements.forEach(function (element) {
                var list = groups[element.name];
                if (list === undefined) {
                    list = [];
                    groups[element.name] = list;
                    count++;
                }
                list.push(element);
            })

            emitListWithVersions(cardBodyDiv, groups);

            emitCountBadge(h, count);

            backlinksDiv.removeAttribute('hidden');
            if (typeof hideLongContent === 'function'){
                hideLongContent();
            }
        }
    });
})();
