/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_498523429")

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text3553320103",
    "max": 0,
    "min": 0,
    "name": "product_name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text475199832",
    "max": 0,
    "min": 0,
    "name": "brand",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "exceptDomains": null,
    "hidden": false,
    "id": "url2895943165",
    "name": "image_url",
    "onlyDomains": null,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "url"
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text946958299",
    "max": 0,
    "min": 0,
    "name": "recall_title",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(6, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text4039802007",
    "max": 0,
    "min": 0,
    "name": "recall_reason",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text3079227511",
    "max": 0,
    "min": 0,
    "name": "risk_description",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text3300921533",
    "max": 0,
    "min": 0,
    "name": "geographic_area",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(9, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text3600515416",
    "max": 0,
    "min": 0,
    "name": "distribution_channels",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(10, new Field({
    "hidden": false,
    "id": "text2165428578",
    "max": "",
    "min": "",
    "name": "recall_date",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(11, new Field({
    "hidden": false,
    "id": "date4172946676",
    "max": "",
    "min": "",
    "name": "marketing_start_date",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(12, new Field({
    "hidden": false,
    "id": "date4193306836",
    "max": "",
    "min": "",
    "name": "marketing_end_date",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(13, new Field({
    "exceptDomains": null,
    "hidden": false,
    "id": "url2776776943",
    "name": "source_url",
    "onlyDomains": null,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "url"
  }))

  // add field
  collection.fields.addAt(14, new Field({
    "hidden": false,
    "id": "bool458715613",
    "name": "is_active",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(15, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text2675300272",
    "max": 0,
    "min": 0,
    "name": "external_id",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_498523429")

  // remove field
  collection.fields.removeById("text3553320103")

  // remove field
  collection.fields.removeById("text475199832")

  // remove field
  collection.fields.removeById("url2895943165")

  // remove field
  collection.fields.removeById("text946958299")

  // remove field
  collection.fields.removeById("text4039802007")

  // remove field
  collection.fields.removeById("text3079227511")

  // remove field
  collection.fields.removeById("text3300921533")

  // remove field
  collection.fields.removeById("text3600515416")

  // remove field
  collection.fields.removeById("text2165428578")

  // remove field
  collection.fields.removeById("date4172946676")

  // remove field
  collection.fields.removeById("date4193306836")

  // remove field
  collection.fields.removeById("url2776776943")

  // remove field
  collection.fields.removeById("bool458715613")

  // remove field
  collection.fields.removeById("text2675300272")

  return app.save(collection)
})
