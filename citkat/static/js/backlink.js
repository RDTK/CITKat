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

    var catalog = document.querySelector('#catalog');
    var backlinksDiv = document.querySelector('#backlinks');

    var type = backlinksDiv.getAttribute('type');
    var parameter = backlinksDiv.getAttribute('name') + '/' + backlinksDiv.getAttribute('version');

    // console.log(parameter);

    loadJSON('/api/backlinks/' + type + '/' + parameter, function (response) {
        var types = {};
        var jsonAnswer = JSON.parse(response);
        // console.log(jsonAnswer);
        jsonAnswer.forEach(function (elem) {
            if (!(elem['type'] in types)) {
                types[elem['type']] = [elem['path']];
            }
            else {
                types[elem['type']].append(elem['path']);
            }
        });
        // console.log(types);
        Object.keys(types).forEach(function (key) {
            var divGroup = document.createElement('div');
            divGroup.setAttribute('class', key);
            var h = document.createElement('h5');
            h.appendChild(document.createTextNode('Recipe used by:'));
            divGroup.appendChild(h);
            types[key].forEach(function (value) {
                var anker = document.createElement('a');
                anker.setAttribute('href', '../' + value);
                // console.log(/(^\/).*(^.xml)$/.exec(t2)[1])
                anker.appendChild(document.createTextNode(value.split('/').pop().split('.xml')[0]));

                divGroup.appendChild(anker);
            });
            backlinksDiv.appendChild(divGroup);

            // console.log(divGroup);
        });
    })
})();