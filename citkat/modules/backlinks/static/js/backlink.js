(function () {
  fetch('/api/backlinks' + window.location.pathname,
    {cache: 'force-cache'})
    .then(function (response) {
      return response.text();
    }).then(function (responseText) {
      document.body.querySelector('#catalog div#resources')
        .appendChild(document.createRange()
        .createContextualFragment(responseText));
    });
})();
