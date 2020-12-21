import 'dart:convert';
//https://www.mipa.mu/estore/TEST_API/
//http://ecom.digitalmarketinghubli.com/API/
final String Article_API_URL = 'https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=Sachin+T&gpslimit=10';

final String PLACEHOLDER = "assets/images/placeholder.png";

final String WIKI_URL = "https://en.wikipedia.org/wiki/";

List<String> stList = [];

