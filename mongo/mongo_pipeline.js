// chiffre d'affaires par restaurant
db.menu_article.aggregate([
  { $lookup: {
      from: "article",
      localField: "id_article",
      foreignField: "id_article",
      as: "art"
  }},
  { $unwind: "$art" },
  { $group: {
      _id: "$id_menu",
      total: { $sum: { $multiply: ["$quantite", "$art.prix_unitaire"] } }
  }},
  { $lookup: {
      from: "menu",
      localField: "_id",
      foreignField: "id_menu",
      as: "menu"
  }},
  { $unwind: "$menu" },
  { $group: {
      _id: "$menu.id_restaurant",
      ca: { $sum: "$total" }
  }}
]);
