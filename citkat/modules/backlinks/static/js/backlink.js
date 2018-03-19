/**
 * Load XmlHttpRequest.
 * @param  {string} url The Url.
 * @param  {function} callback The callback function.
 */
function loadXHR(url, callback) {
  let request = new XMLHttpRequest();
  request.open('GET', url, true);
  request.onreadystatechange = function () {
    if (request.readyState === 4 && request.status === 200) {
      callback(request.responseText);
    }
  };
  request.send(null);
}

(function () {
  let resourcesDiv = document.body.querySelector('#catalog div#resources');
  let url = '/api/backlinks' + window.location.pathname;
  loadXHR(url, function (responseText) {
    resourcesDiv.appendChild(document.createRange()
      .createContextualFragment(responseText));
  });
})();
