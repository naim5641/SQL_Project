create database practice_problem;

-- How many employees are there?
select count(`Emp ID`) as Total_Emp
from employee_information;

-- select * from employee_information


-- How many employees are there for each department?
select dept, count(`Emp ID`) as Emp_Each_Department
from employee_information
group by dept;

-- Calculate average satisfactory level for each department

select round(avg(satisfaction_level),2)as avg_satisfaction,dept from employee_information
group by dept;


/*Find out those employee IDs who have ranked top for each department based on spending their time in the company. */


select *
from
(select
       `Emp ID`,
       dept,
       time_spend_company,
       dense_rank() over (partition by dept order by time_spend_company desc ) as rnk
from employee_information) as t
where t.rnk = 1;

-- 2. Which three departments had the highest satisfactory score?
select employee_information.dept,
       sum(employee_information.satisfaction_level) as Total_satisfaction
       from employee_information
group by dept order by Total_satisfaction desc
    limit 3;

-- 3. Which three departments had the lowest satisfactory score?

select employee_information.dept,
       sum(employee_information.satisfaction_level) as Total_satisfaction
       from employee_information
group by dept order by Total_satisfaction asc
    limit 3;

-- 4. Consider IT and technical departments as a tech_group and marketing
-- and product_mng as a mng_group and give us a comparison by considering the avg last evaluation.

select
    case
    when dept in ( 'IT','technical') then 'tech_group'
    when dept in ( 'management','product_mng') then 'mng_group'
    end as group_s,
    avg(last_evaluation)
from employee_information
group by 1;

select
    group_s,
    avg(last_evaluation)
    from

(
        select
            'tech_group' as group_s,
                last_evaluation
         from employee_information
         where dept in ('IT', 'technical')

 union all

            select
             'mng_group' as group_s,
                last_evaluation
         from employee_information
         where dept in ('marketing', 'product_mng')
         )as tt
        group by 1;





