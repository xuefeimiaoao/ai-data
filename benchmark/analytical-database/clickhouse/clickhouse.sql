SELECT count(1) FROM file('{}', Parquet) where height = 1170;
SELECT count(1) FROM file('{}', Parquet) where arrayExists(x -> x = '17c112a7fa', objects.2.1);
SELECT count(1) FROM file('{}', Parquet) where arrayExists(x -> x = 'd6bdcb3634', objects.1);
SELECT count(1) as agg_query FROM file('{}', Parquet) group by format,version;
SELECT AVG(bit_depth), AVG(size), AVG(width), AVG(height) as ordered_avg
  FROM file('{}', Parquet)
  WHERE format IN ('JPG', 'JPEG', 'PNG', 'cdr', 'pcd', 'dxf', 'ufo', 'eps', 'ai', 'raw', 'WMF')
  GROUP BY format, version
  ORDER BY version ASC;
SELECT count(1) as cnt
  FROM file('{}', Parquet)
  GROUP BY format, version
  HAVING count(*) >= 50
  ORDER BY cnt, version;
