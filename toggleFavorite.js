
function toggleFavorite(slug) {
  var xhr = new XMLHttpRequest();

  xhr.open('POST', '/toggle_favorite/' + slug, false);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.send(null);

  const is_favorited = JSON.parse(xhr.responseText).is_favorited
  const favoriteButton = $("#" + slug)
  toggleFavoritedClasses(favoriteButton, is_favorited)
}