/**
 * Convert date with respect to the browsers locale.
 */
function dateConvertLocale() {
  [].forEach.call(document.querySelectorAll('span.date'), function (dateSpan) {
    dateSpan.textContent = (new Date(dateSpan.textContent)).toLocaleString();
  });
}
