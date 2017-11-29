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

    function emitElement(ul, element) {
        var type = element['type']
        var name = element['name']
        var version = element['version']

        var li = document.createElement('li');
        ul.appendChild(li);

        var anker = document.createElement('a');
        li.appendChild(anker);
        anker.setAttribute('href', '../' + element['path']);

        var icon = ''
        switch (type) {
        case 'distribution':
            icon = octiconHTML('bug')
            break;
        default:
            icon = octiconHTML(type)
        }
        var iconSpan = document.createElement('span');
        anker.appendChild(iconSpan);
        iconSpan.innerHTML = icon;

        anker.appendChild(document.createTextNode(name + ' - ' + version));
    }

    function emitList(cardBodyDiv, elements) {
        var ul = document.createElement('ul');
        cardBodyDiv.appendChild(ul);

        elements.forEach(function (element) {
            emitElement(ul, element);
        });
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

        li.appendChild(document.createTextNode(name + ' — '));

        var first = true;
        versions.forEach(function (version) {
            if (first) {
                first = false;
            } else {
                li.appendChild(document.createTextNode(' • '));
            }

            var anchor = document.createElement('a');
            li.appendChild(anchor);
            anchor.appendChild(document.createTextNode(version['version']));
            anchor.setAttribute('href', '../' + version['path']);
        });
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
            if (count == elements.length) {
                emitList(cardBodyDiv, elements);
            } else {
                emitListWithVersions(cardBodyDiv, groups);
            }

            emitCountBadge(h, count);

            backlinksDiv.removeAttribute('hidden');
            if (typeof hideLongContent === 'function'){
                hideLongContent();
            }
        }
    });
})();
