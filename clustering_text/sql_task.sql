with union_tables (email, second_expressed_interest_at)  as (
	SELECT t2.email, t2.created_at as second_expressed_interest_at
	FROM [Debt].[dbo].[conversation_tag] as t1
	inner join [conversation_history] as t2 on t1.conversation_id = t2.id
	where t1.tag = 'product-interest' 

	union

	select email, dateadd(s, convert(bigint, product_interest), convert(datetime, '1-1-1970 00:00:00')) as second_expressed_interest_at
	from debt.dbo.questionnare_table
	where product_interest is not null
),

numbering_tables as (
	select *, ROW_NUMBER() over(partition by email order by second_expressed_interest_at) as rn
	from union_tables
)

select email, second_expressed_interest_at
from numbering_tables
where rn = 2