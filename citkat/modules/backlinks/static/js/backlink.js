function loadXHR(url, callback) {
    var request = new XMLHttpRequest();
    request.open('GET', url, true);
    request.onreadystatechange = function () {
        if (request.readyState === 4 && request.status === 200) {
            callback(request.responseText)
        }
    };
    request.send(null)
}

(function () {
    var resourcesDiv = document.body.querySelector('#catalog div#resources');
    var url = '/api/backlinks' + window.location.pathname;
    console.log(url.substring(0, -4));
    loadXHR(url, function (responseText) {
        resourcesDiv.appendChild(document.createRange().createContextualFragment(responseText));
        hideLongContent();
    });
})();
