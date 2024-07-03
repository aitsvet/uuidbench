#!/bin/bash

# wait for uuidpg
sleep 3

psql -qc "drop table if exists data; create table data (n bigserial primary key, id uuid);
create index data_btree_16 on data using btree(id);
create index data_btree_8 on data using btree(substring(uuid_send(id), 9));
create index data_btree_4 on data using btree(substring(uuid_send(id), 13));
create index data_hash on data using hash(id);
create index data_spgist_16 on data using spgist(substring(encode(uuid_send(id), 'base64'), 1, 22));
create index data_spgist_8 on data using spgist(substring(encode(substring(uuid_send(id), 9), 'base64'), 1, 11));
create index data_spgist_4 on data using spgist(substring(encode(substring(uuid_send(id), 13), 'base64'), 1, 6));"

echo "
| days | rows | bigserial | btree_16 | btree_8 | btree_4 | hash | spgist_16 | spgist_8 | spgist_4 |
| ---- | ---- | --------- | -------- | ------- | ------- | ---- | --------- | -------- | -------- |" | tee uuidpg.md

for f in `seq 1 $DAYS`; do

psql -qc "
insert into data (id) select gen_random_uuid() as id from generate_series(1, $DAILY);
select $f, (pg_table_size('data')::decimal / 1073741824),
	(pg_table_size('data_pkey')::decimal / 1073741824),
	(pg_table_size('data_btree_16')::decimal / 1073741824),
	(pg_table_size('data_btree_8')::decimal / 1073741824),
	(pg_table_size('data_btree_4')::decimal / 1073741824),
	(pg_table_size('data_hash')::decimal / 1073741824),
	(pg_table_size('data_spgist_16')::decimal / 1073741824),
	(pg_table_size('data_spgist_8')::decimal / 1073741824),
	(pg_table_size('data_spgist_4')::decimal / 1073741824);"

done | grep --line-buffered '^[0-9 ]*|' | sed -u 's/^/| /; s/$/ |/; s/ \+/ /g' | tee -a uuidpg.md
