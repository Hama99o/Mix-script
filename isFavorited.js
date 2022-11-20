
async function isFavorited(slugs) {
  var xhr = new XMLHttpRequest();
  var data = JSON.stringify({ 'trend_report_slugs': slugs });

  xhr.open('POST', '/is_favorited/', false);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.send(data);

  const is_favorited = JSON.parse(xhr.responseText)

  is_favorited.map((slug) => {
    const favoriteButton = $("#" + slug)
    toggleFavoritedClasses(favoriteButton, true)
  })
}
