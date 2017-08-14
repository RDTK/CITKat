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

    var fragment = document.querySelector('#backlinks')
    // TODO: create ReST request, add backlinks to domFragment
})();