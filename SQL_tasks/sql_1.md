# Задание 1
___
- Создать таблицу (T_CONTRACTOR_SHERULER) под расписание и заполнить его с файла schedulers.csv. (Использовать любую библиотеку для заливки в СУБД (как вариант MS SQL)) Таблицу следует нормализовать.

ID_NAME - идентификтор поставщика
NAME - название поставщика
SHEDULE - расписание
DATE_BEGIN - дата начала действия расписания
DATE_END - дата окончания действия расписания
Пример записи без нормализации:

Поставщик 1 ДВС 01.01.2019 04.01.2019
Поставщик 2 НВС 05.01.2019 31.12.2019
Вводные:

Связку полей FIO, DATE_BEGIN считать уникальной.
DATE_BEGIN не может привышать DATE_END.
Можете продемонстрировать работу с ключами/ограничениями.

if object_id('dbo.T_CONTRACTOR_SHERULER', 'U') is not null
        drop table DEBT.dbo.T_CONTRACTOR_SHERULER;

    CREATE TABLE DBO.T_CONTRACTOR_SHERULER (
        ID_NAME INT NOT NULL  IDENTITY(1, 1),
        NAME VARCHAR(255),
        SHEDULE VARCHAR(255),
        DATE_BEGIN DATETIME,
        DATE_END DATETIME,
        PRIMARY KEY (ID_NAME),
        CONSTRAINT un_NAME UNIQUE (NAME, DATE_BEGIN),
        CONSTRAINT check_date CHECK (
            DATE_BEGIN < DATE_END
            )
        )

Задание 2
Создать таблицу (T_CONTRACTOR_WORK_DAY) выходов на работу сотрудников.

Таблица должна иметь следующий вид

ID - идентификатор записи
NAME - название поставщика
DATE_BEGIN - Начало рабочего дня (datetime)
DATE_END - Конец рабочего дня (datetime)

if object_id('dbo.T_CONTRACTOR_WORK_DAY', 'U') is not null
        drop table DEBT.dbo.T_CONTRACTOR_WORK_DAY;

    CREATE TABLE DBO.T_CONTRACTOR_WORK_DAY (
        ID INT NOT NULL  IDENTITY(1, 1),
        NAME VARCHAR(255),
        DATE_BEGIN DATETIME,
        DATE_END DATETIME,
        PRIMARY KEY (ID)
        )

Задание 3
Создать процедуру расчета рабочих дней.

Входящие параметры:

Дата начала периода расчета
Дата окончания периода расчета.
Ожидаемый результать выполнения хранимой процедуры - заполнение таблицы T_CONTRACTOR_WORK_DAY рабочими днями согласно расписания работы поставщиков из таблицы T_CONTRACTOR_SHERULER Выходные дни (В) не должны попадать в таблицу T_CONTRACTOR_WORK_DAY

Пример выполнения для Поставщика 1 (Из примера записи таблицы T_CONTRACTOR_SHERULER) с параметрами '01.01.2019' - '08.01.2019' таблица T_CONTRACTOR_WORK_DAY заполнится следующими данными:

1 Поставщик 1 01.01.2019 08:00 01.01.2019 20:00
2 Поставщик 1 03.01.2019 08:00 04.01.2019 08:00
3 Поставщик 1 04.01.2019 08:00 04.01.2019 08:00
4 Поставщик 1 05.01.2019 20:00 06.01.2019 08:00
5 Поставщик 1 07.01.2019 08:00 08.01.2019 08:00
6 Поставщик 1 08.01.2019 20:00 09.01.2019 08:00
Пояснение: для записей с 01.01.2019 по 04.01.2019 берется расписание ДВС

1 - Д - дневная смена далее следует выходной В - запись о выходном дне не попадает в таблицу
2 - С - суточная смена
3 - расписание закончилось, поэтому оно циклично начинается с начала (Д - дневная смена)
4 - С 05.01.2019 начинает действовать новое расписание - НВС берется Н - ночная смена далее следует выходной В - запись о выходном дне не попадает в таблицу
5 - С - суточная смена
6 - Снова Н - ночная смена

IF (OBJECT_ID('SelectAllCustomers') IS NOT NULL)
  DROP PROCEDURE SelectAllCustomers
GO

CREATE PROCEDURE SelectAllCustomers
    @date_begin DATE,
    @date_end DATE,
    @shedule nvarchar(50),
    @name nvarchar(100)
AS
    declare @len_date int = DATEDIFF(day, @date_begin, @date_end)
    declare @new_string nvarchar(50)

    set @new_string = @shedule + SUBSTRING(@shedule, 1, @len_date - len(@shedule))    
    declare @i int = 1
    declare @len_new_str int = len(@new_string)

    if @len_date > len(@shedule)
        while (@i <= @len_new_str)
            begin
                if substring(@new_string, @i, 1) = 'д'
                    begin 
                        insert into [Debt].[dbo].[T_CONTRACTOR_WORK_DAY]
                        values (@name, convert(nvarchar, dateadd(hour, 8, DATEADD(day, @i-1, cast(@date_begin as nvarchar))), 120),
                                convert(nvarchar, dateadd(hour, 20, DATEADD(day, @i-1, cast(@date_begin as nvarchar))), 120))
                    end
                if substring(@new_string, @i, 1) = 'н'
                    begin
                        insert into [Debt].[dbo].[T_CONTRACTOR_WORK_DAY]
                        values (@name, convert(nvarchar, dateadd(hour, 20, DATEADD(day, @i-1, cast(@date_begin as nvarchar))), 120),
                            convert(nvarchar, dateadd(hour, 8, DATEADD(day, @i, cast(@date_begin as nvarchar))), 120))
                    end
                if substring(@new_string, @i, 1) = 'с'
                    begin
                        insert into [Debt].[dbo].[T_CONTRACTOR_WORK_DAY]
                        values(@name, convert(nvarchar, dateadd(hour, 8, DATEADD(day, @i-1, cast(@date_begin as nvarchar))), 120),
                            convert(nvarchar, dateadd(hour, 8, DATEADD(day, @i, cast(@date_begin as nvarchar))), 120))
                    end
                set @i = @i +1
            end
GO

Задание 4
С помощью SQL запросов:

Сделать выборку содержащую сколько рабочих дней было у каждого поставщика
Сделать выборку поставщиков, у которыйх было больше 10 рабочих дней за январь 2019 года
Сделать выборку поставщиков, кто работал 14, 15 и 16 января 2019 года

select name, count(date_begin)
from [T_CONTRACTOR_WORK_DAY]
group by name


select name, count(date_begin)
from [T_CONTRACTOR_WORK_DAY]
where date_beign < '2019-02-01'
group by name
having count(date_begin) > 10

select distinct name
from [T_CONTRACTOR_WORK_DAY]
where date_begin between '2019-01-14' and '2019-01-17'


