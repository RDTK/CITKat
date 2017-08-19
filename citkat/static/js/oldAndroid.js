// for usability with Androids stock browser on system versions < 4.0
(function () {
    var nua = navigator.userAgent;
    var isAndroid = (nua.indexOf('Mozilla/5.0') > -1 && nua.indexOf('Android ') > -1 && nua.indexOf('AppleWebKit') > -1 && nua.indexOf('Chrome') === -1);
    if (isAndroid) {
        document.querySelectAll('select.form-control').forEach(function (elem) {
            elem.className = elem.ClassName.replace(new RegExp('(?:^|\\s)' + 'form-control' + '(?:\\s|$)'), '');
            elem.setAttribute('style', 'width: 100%; ' + (elem.getAttribute('style') || ''))
        });
    }
})();