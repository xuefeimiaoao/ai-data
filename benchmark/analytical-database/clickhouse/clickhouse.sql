SELECT count(1) FROM file('{}', Parquet) where height = 1170;
SELECT count(1) FROM file('{}', Parquet) where arrayExists(x -> x = '17c112a7fa', objects.2.1);
SELECT count(1) FROM file('{}', Parquet) where arrayExists(x -> x = 'd6bdcb3634', objects.1);
