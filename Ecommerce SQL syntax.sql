use mavenfuzzyfactory;

select 
 utm_source
 ,utm_campaign
  ,http_referer
 ,count(distinct website_session_id) as sessions
from website_sessions
where created_at < '2012-04-12'
group by utm_source, utm_campaign,http_referer
order by count(distinct website_session_id) desc;
-- Found out which ad is generating the most traffic to website

select
 count(distinct website_sessions.website_session_id)
 ,count(distinct orders.order_id)
,count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as percent
from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2012-04-14'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand';
-- Conversion rate is less than 3%, so marketing will pull some funding from this ad

select 
min(date(created_at))
 ,count(distinct website_session_id)
from website_sessions
where created_at < '2012-05-10'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 
 week(created_at)
 ,year(created_at);
-- Results are that website traffic generated from the paid ad has decreased after less funding

select 
 website_sessions.device_type
 ,count(distinct website_sessions.website_session_id) as sessions
  ,count(distinct orders.order_id) as orders
  ,count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_conv_rate
from website_sessions
	left join orders 
		on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2012-05-11'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 1;
-- found out that paid ads are more efficient on desktop opposed to mobile

select 
 min(date (created_at)) as week_start_date
 ,count(distinct case when device_type = 'desktop' then website_session_id else null end) as dtop_sessions
  ,count(distinct case when device_type = 'mobile' then website_session_id else null end) as mob_sessions
from website_sessions
where created_at between '2012-04-15' and '2012-06-3'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 
year(created_at)
,week(created_at)
order by 1 asc;
-- Additional funding in paid ad led to an increase in website traffic on desktop

select 
 pageview_url
 ,count(distinct website_pageview_id) as sessions
from website_pageviews
where created_at < '2012-06-09'
group by 1
order by 2 desc;
-- Results of website top pages views

-- Creating Temp table
create temporary table first_pv_per_session
select 
 website_session_id
  ,count(distinct website_pageview_id) as first_pv
from website_pageviews
where created_at < '2012-06-12'
group by 1;

select 
 website_pageviews.pageview_url as landing_page_url
 ,count(distinct first_pv_per_session.website_session_id) as sessions_hitting_page
from first_pv_per_session
	left join website_pageviews
		on first_pv_per_session.first_pv = website_pageviews.website_pageview_id
group by website_pageviews.pageview_url;
-- Identified top entry page

-- Another Temp table
create temporary table first_pageviews
select 
 website_session_id
 ,min(website_pageview_id) as min_pageview_id
from website_pageviews
where created_at < '2012-06-14'
group by website_session_id;

create temporary table sessions_w_home_landing_page
select 
 first_pageviews.website_session_id
 ,website_pageviews.pageview_url as landing_page
from first_pageviews 
	left join website_pageviews
		on website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
where website_pageviews.pageview_url = '/home';

create temporary table bounced_sessions 
select 
 sessions_w_home_landing_page.website_session_id
 ,sessions_w_home_landing_page.landing_page
  ,count(website_pageviews.website_pageview_id) as count_of_pages_viewed
from sessions_w_home_landing_page
	left join website_pageviews
		on website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
group by 1,2
having count(website_pageviews.website_pageview_id) = 1;

select 
sessions_w_home_landing_page.website_session_id
,bounced_sessions.website_session_id as bounced_website_session_id
from sessions_w_home_landing_page
	left join bounced_sessions
		on sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
order by sessions_w_home_landing_page.website_session_id;

-- final step to finding bounce rate
select 
 count(distinct sessions_w_home_landing_page.website_session_id) as sessions
 ,count(distinct bounced_sessions.website_session_id) as bounced_sessions
  ,count(distinct bounced_sessions.website_session_id)/count(distinct sessions_w_home_landing_page.website_session_id) as bounce_rate
from sessions_w_home_landing_page
	left join bounced_sessions
		on sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;
-- Reuslt is the bounce rate from home page is 59%

-- A/B test for new landing page
select
 min(created_at) as first_created_at
 ,min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url = '/lander-1'
and created_at is not null;
-- first time the new landing page was launched 

create temporary table first_test_pageviews
select 
 website_pageviews.website_session_id
 ,min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
	inner join website_sessions
		on website_sessions.website_session_id = website_pageviews.website_session_id
        and website_sessions.created_at < '2012-07-28'
        and website_pageviews.website_pageview_id > 23504 -- first pageview we found above
        and utm_source = 'gsearch'
        and utm_campaign = 'nonbrand'
group by 1;

create temporary table nonbrand_test_sessions_w_landing_page
select 
 first_test_pageviews.website_session_id
 ,website_pageviews.pageview_url as landing_page
from first_test_pageviews
	left join website_pageviews
		on website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
where website_pageviews.pageview_url in ('/home','/lander-1');

-- table for counting pageviews per session 
create temporary table nonbrand_test_bounced_sessions
select
 nonbrand_test_sessions_w_landing_page.website_session_id
 ,nonbrand_test_sessions_w_landing_page.landing_page
  ,count(website_pageviews.website_pageview_id) as count_of_page_viewed
from nonbrand_test_sessions_w_landing_page
	left join website_pageviews
		on website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
group by 1,2
having count(website_pageviews.website_pageview_id) = 1;

select
 nonbrand_test_sessions_w_landing_page.landing_page
 ,count(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as sessions
  ,count(distinct nonbrand_test_bounced_sessions.website_session_id) as bounced_sessions
   ,count(distinct nonbrand_test_bounced_sessions.website_session_id)/count(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as bounced_perc
from nonbrand_test_sessions_w_landing_page
	left join nonbrand_test_bounced_sessions
		on nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
group by 1;
-- Results are new website landing page decreases bounce rate
