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

    var fragment = document.querySelector('#jenkinsState');
    var url = fragment.getAttribute('buildserverbaseurl');
    var urlParam =
        '/api/json?&tree=' +
        'healthReport[' +
            'score' +
        '],' +
        'lastSuccessfulBuild[' +
            'timestamp' +
        '],' +
        'lastFailedBuild[' +
            'timestamp' +
        ']';
    var type = '';
    if (fragment.getAttribute('type') === 'distribution') {
        type = '-orchestration';
    }
    var name = fragment.getAttribute('name');
    var version = fragment.getAttribute('version');
    if (url[-1] !== '/') {
        url += '/';
    }
    url = url + 'job/' + name + '-' + version + '-toolkit' + type + urlParam;
    console.log(url)
    // TODO: load json from jenkins server, build corresponding domFragment
})();