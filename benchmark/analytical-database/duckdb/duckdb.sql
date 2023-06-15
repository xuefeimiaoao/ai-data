SELECT count(1) FROM read_parquet('{}') where height = 1170 ;
SELECT COUNT(1)
FROM
  (SELECT unnest(objects) as obj
   FROM read_parquet('{}')) subquery
WHERE obj.shape.shape_type = '17c112a7fa';
SELECT count(1)
FROM
    (SELECT unnest(objects) as obj
     FROM read_parquet('{}')) subquery
WHERE obj.classification = 'd6bdcb3634';
select count(1) from read_parquet('{}')  WHERE CAST(objects as VARCHAR) LIKE '%''classification'': 0d0801cca3%';
SELECT count(1) as agg_query FROM read_parquet('{}') group by format,version;
SELECT AVG(bit_depth), AVG(size), AVG(width), AVG(height) as ordered_avg
  FROM read_parquet('{}')
  WHERE format IN ('JPG', 'JPEG', 'PNG', 'cdr', 'pcd', 'dxf', 'ufo', 'eps', 'ai', 'raw', 'WMF')
  GROUP BY format, version
  ORDER BY version ASC;
SELECT count(1) as cnt
  FROM read_parquet('{}')
  GROUP BY format, version
  HAVING count(*) >= 50
  ORDER BY cnt, version;
