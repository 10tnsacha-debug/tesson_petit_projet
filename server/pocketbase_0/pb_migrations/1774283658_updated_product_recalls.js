/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_498523429")

  // add field
  collection.fields.addAt(16, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text433672781",
    "max": 0,
    "min": 0,
    "name": "additional_information",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(17, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text2640747845",
    "max": 0,
    "min": 0,
    "name": "consumer_guidance",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(18, new Field({
    "exceptDomains": null,
    "hidden": false,
    "id": "url1816806332",
    "name": "pdf_url",
    "onlyDomains": null,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "url"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_498523429")

  // remove field
  collection.fields.removeById("text433672781")

  // remove field
  collection.fields.removeById("text2640747845")

  // remove field
  collection.fields.removeById("url1816806332")

  return app.save(collection)
})
