CREATE TABLE collection_index (
  collection_index_id SERIAL NOT NULL PRIMARY KEY,
  collection VARCHAR,
  name VARCHAR,
  key JSON
);