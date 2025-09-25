// total des quantités vendues par article
var map = function () { emit(this.id_article, this.quantite); };
var reduce = function (key, values) { return Array.sum(values); };
db.menu_article.mapReduce(map, reduce, { out: "totaux_articles" });
