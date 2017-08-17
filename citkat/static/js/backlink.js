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

    var backlinksDiv = document.querySelector('#backlinks');

    var type = backlinksDiv.getAttribute('type');
    var parameter = backlinksDiv.getAttribute('name') + '/' + backlinksDiv.getAttribute('version');

    loadJSON('/api/backlinks/' + type + '/' + parameter, function (response) {
        var types = {};
        var jsonAnswer = JSON.parse(response);
        jsonAnswer.forEach(function (elem) {
            if (!(elem['type'] in types)) {
                types[elem['type']] = [elem['path']];
            }
            else {
                types[elem['type']].append(elem['path']);
            }
        });
        Object.keys(types).forEach(function (key) {
            var divGroup = document.createElement('div');
            divGroup.setAttribute('class', key);
            var h = document.createElement('h5');
            h.appendChild(document.createTextNode('Recipe used by:'));
            divGroup.appendChild(h);
            types[key].forEach(function (value) {
                var anker = document.createElement('a');
                anker.setAttribute('href', '../' + value);
                anker.appendChild(document.createTextNode(value.split('/').pop().split('.xml')[0]));
                divGroup.appendChild(anker);
            });
            backlinksDiv.appendChild(divGroup);
        });
    })
})();