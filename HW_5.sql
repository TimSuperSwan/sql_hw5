-- 1. Создайте представление, в которое попадут автомобили стоимостью до 25 000 долларов;
-- Создаем SQL-Представление с использованием условия
CREATE VIEW cars_view AS
  SELECT * 
    FROM Cars
  WHERE cost < 25000;


-- .2. Изменить в существующем представлении порог для стоимости: пусть цена будет до 30 000 долларов (используя оператор ALTER VIEW);
-- Изменяем SQL-Представление
ALTER VIEW cars_view AS
  SELECT * 
    FROM Cars
  WHERE cost < 30000;


--.3. Создайте представление, в котором будут только автомобили марки “Шкода” и “Ауди” (аналогично)
-- Создаем SQL-Представление с использованием условия
CREATE VIEW cars_view_as AS
  SELECT * 
    FROM Cars
  WHERE name = "Audi" 
    OR name = "Skoda";

CREATE VIEW cars_view_as AS
  SELECT * 
    FROM Cars
  WHERE name IN ("Audi", "Skoda"); -- Упростим запись через IN


-- .4. Вывести название и цену для всех анализов, которые продавались 5 февраля 2020 и всю следующую неделю.
-- Не указано какую из цен вывест, вывел обе, добавил нормальные имена столбцам
SELECT
  an_name AS 'Наименование анализа',
  an_cost AS 'Cебестоимость анализа',
  an_price AS 'Розничная цена',
  ord_datetime AS 'Дата заказа'
FROM Analysis
  JOIN Orders
    ON Analysis.an_id = Orders.ord_id  -- Выносим в WHERE
      AND Orders.ord_datetime >= '2020-02-05' -- В ON условии лучше не писать подообое
      AND Orders.ord_datetime <= '2020-02-12'; -- Тут руками нашли +7д исправим это и добавим BETWEEN


SELECT
  an_name AS 'Наименование анализа',
  an_cost AS 'Cебестоимость анализа',
  an_price AS 'Розничная цена',
  ord_datetime AS 'Дата заказа'
FROM Analysis a
  JOIN Orders o
    ON a.an_id = o.ord_id
  WHERE o.ord_datetime BETWEEN '2020-02-05' 
    AND ('2020-02-05' + INTERVAL 1 WEEK);


-- .5. Добавьте новый столбец под названием «время до следующей станции». Чтобы получить это значение, мы вычитаем время станций для пар смежных станций. Мы можем вычислить это значение без использования оконной функции SQL, но это может быть очень сложно. Проще это сделать с помощью оконной функции LEAD . Эта функция сравнивает значения из одной строки со следующей строкой, чтобы получить результат. В этом случае функция сравнивает значения в столбце «время» для станции со станцией сразу после нее.
-- Объединяем в группы по значеням столбца train_id
-- Функция LEAD возвращает значение следующего элемента столбца station_time группы train_id
-- Функция SUBTIME возвращает разницу между значениями
SELECT
  train_id,
  station,
  station_time
  SUBTIME(
    LEAD(station_time) OVER(PARTITION BY train_id ORDER BY station_time), station_time
  ) AS 'Время до следующей станции'
FROM Trains;

-- Полагаю, что в таком варианте вместо пустой строки должен выводиться 0
-- Т.к. для последненго элемента вместо NULL по умолчанию, будет возвращаться значение = station_time
SELECT
  train_id,
  station,
  station_time
  SUBTIME(
    LEAD(station_time, 1, station_time) OVER(PARTITION BY train_id ORDER BY station_time), station_time
  ) AS 'Время до следующей станции'
FROM Trains;