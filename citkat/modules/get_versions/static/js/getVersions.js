(function () {
    var getVersionsEventListener = function(){
        var filename = document.body.querySelector('#catalog').getAttribute('data-filename');
        var type = document.body.querySelector('#catalog').getAttribute('type');
        var xhr = new XMLHttpRequest();
        xhr.open('GET', '/api/versions/' + type + '/' + filename);
        xhr.onload = function() {
            if (this.status === 200) {
                var jsonResponse = JSON.parse(this.responseText);
                [].forEach.call(jsonResponse, function (dictElem) {
                    Object.keys(dictElem).forEach(function(key) {
                        a = document.createElement('a');
                        a.setAttribute('class', 'dropdown-item');
                        a.setAttribute('href', dictElem[key]);
                        a.innerHTML = key;
                        document.querySelector('[aria-labelledby="versionsDropdown"]').appendChild(a);
                    });
                });

                $('[aria-labelledby="versionsDropdown"] a').sort(asc_sort).appendTo('[aria-labelledby="versionsDropdown"]');
                // sort ascending
                function asc_sort(a, b){
                    return ($(b).text()) < ($(a).text()) ? 1 : -1;
                }
            }
            // remove eventListener after first call
            document.getElementById("versionsDropdown").removeEventListener('click', getVersionsEventListener);
        };
        xhr.send();
    };
    // bind eventListener to the versions dropdown menu
    document.getElementById("versionsDropdown").addEventListener("click", getVersionsEventListener);
})()