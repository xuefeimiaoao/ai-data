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
