---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--select * from matches_mst where id = 521
--esp_dsp_testresult 582,2
--select * from matches_mst where type=228
--exec esp_dsp_testresult '801','2'

alter proc [dbo].[esp_dsp_testresult]
 @match  as  int,
  @flag  as varchar(10)

as
begin
set nocount on  
--declare @match  int
-- variable declare part
declare @inn1  int
declare @inn2  int
declare @inn3  int
declare @inn4  int
declare @matchtypeday int
declare @subtotal_1 as int
declare @subtotal_2 as int
declare @subtotal_inn1 as int
declare @subtotal_inn2 as int
declare @subtotal_inn3 as int
declare @subtotal_inn4 as int
declare @inn1_bat int
declare @inn2_bat int
declare @inn3_bat int
declare @inn4_bat int
declare @total_team1 int--total of match for team1
declare @total_team2 int--total of match for team2
declare @team1_name as varchar(80)
declare @team2_name as varchar(80)
declare @team3_name as varchar(80)
declare @team4_name as varchar(80)
declare @wkts_inn1 as int
declare @wkts_inn2 as int
declare @wkts_inn3 as int
declare @wkts_inn4 as int
declare @wkts_team1 as int
declare @wkts_team2 as int
declare @result as varchar(250)
declare @inn1end_ts as varchar(30)
declare @inn2end_ts as varchar(30)
declare @inn3end_ts as varchar(30)
declare @inn4end_ts as varchar(30)
declare @totalruns as int
declare @matchtime datetime
declare @is_supper_over as varchar(10)

--end variable declare part
--------------------------------------------------------------------------------------------------------------
-- check match type eg test,oneday
set @matchtypeday = (select num_innings from matchtypes_mst a 
		     inner join matches_mst b on a.id=b.type
		     where b.id=@match)


create table #matchtotalscore(
inning int,
batting_team int,
runs int,
inning_no int
)
insert into #matchtotalscore(inning,batting_team,runs,inning_no)
exec dbo.esp_dsp_totalscore  @match			
set @inn1 = (select min(id) from innings_mst where match_id=@match )
set @inn2 = (select min(id) from innings_mst where match_id=@match  and id>@inn1)
set @inn3 = (select min(id) from innings_mst where match_id=@match  and id>@inn2)
set @inn4 = (select min(id) from innings_mst where match_id=@match  and id>@inn3)
select @inn1end_ts = isnull(min(convert(varchar(20),end_ts)),'0') from innings_mst where id = @inn1
select @inn2end_ts = isnull(min(convert(varchar(20),end_ts)),'0') from innings_mst where id = @inn2				
select @inn3end_ts = isnull(min(convert(varchar(20),end_ts)),'0') from innings_mst where id = @inn3
select @inn4end_ts = isnull(min(convert(varchar(20),end_ts)),'0') from innings_mst where id = @inn4
set @is_supper_over = (select is_supper from innings_mst where id = @inn3)

-----------------------------------------------------------------------------------------------------------
-- start test logic
if @flag = '1'
begin
	update innings_mst set end_ts = getdate()
	where match_id = @match and end_ts is null
		
	if @inn3end_ts != '0' or  @inn4end_ts  != '0'
	begin
		set @flag = '2'
	end
	else
	begin	
		set @result ='Match Draw'
		select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   @team4_name as inn4,convert(varchar(10),isnull(@subtotal_inn4,''))+'/'+(convert(varchar(10),@wkts_inn4)) as inn4_score	
		update matches_mst set result = 2,match_winner =0
		where id = @match	
	end

end
if @flag = '2' or @flag = '3'
begin
if @matchtypeday > 2  or @is_supper_over = 'Y'
begin
--set @match = 92

			select @subtotal_inn1 =max(runs) from #matchtotalscore where inning = @inn1 

			--innings 2
			select @subtotal_inn2 =max(runs) from #matchtotalscore where inning = @inn2  
			--innings 3
 	  
			select @subtotal_inn3 = max(runs) from #matchtotalscore where inning = @inn3
		--innings 4
			
			select @subtotal_inn4 = max(runs) from #matchtotalscore where inning = @inn4

			--id of batting team in each inning
	
			--setting id of batting team in each inning
			set @inn1_bat = (select batting_team from innings_mst where id = @inn1)
			set @inn2_bat = (select batting_team from innings_mst where id = @inn2)
			set @inn3_bat = (select batting_team from innings_mst where id = @inn3)
			set @inn4_bat = (select batting_team from innings_mst where id = @inn4)
			--name of teams

			set @team1_name = (select team_name from teams_mst where id = @inn1_bat)
			set @team2_name = (select team_name from teams_mst where id = @inn2_bat)
			set @team3_name = (select team_name from teams_mst where id = @inn3_bat)
			set @team4_name = (select team_name from teams_mst where id = @inn4_bat)
			
			------wickets ---  

			select @wkts_inn1=count(0) from balls_mst   
			inner join dismissals_mst  
			on balls_mst.id = dismissals_mst.ball  
			where balls_mst.inning_id = @inn1 and dismissals_mst.can_return ='N'


			select @wkts_inn2=count(0) from balls_mst   
			inner join dismissals_mst  
			on balls_mst.id = dismissals_mst.ball  
			where balls_mst.inning_id = @inn2 and dismissals_mst.can_return ='N'


			select @wkts_inn3=count(0) from balls_mst   
			inner join dismissals_mst  
			on balls_mst.id = dismissals_mst.ball  
			where balls_mst.inning_id = @inn3 and dismissals_mst.can_return ='N'
			

			select @wkts_inn4=count(0) from balls_mst   
			inner join dismissals_mst  
			on balls_mst.id = dismissals_mst.ball  
			where balls_mst.inning_id = @inn4 and dismissals_mst.can_return ='N'
			
			if @inn2end_ts = '0' and @inn3end_ts = '0' and @inn4end_ts = '0'
			begin
				set @result ='Total Inning Score : ' +  convert(varchar(30),@team1_name) + ' <br>'+ convert(varchar(10),@subtotal_inn1) + ' / '+convert(varchar(10),@wkts_inn1)
				select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+' / '+convert(varchar(10),@wkts_inn1) as inn1_score,							
								   null as inn2,null as inn2_score,
								   null as inn3, null as inn3_score,
								   null as inn4,null as inn4_score 								
			end
			else if @inn3end_ts = '0' and @inn4end_ts = '0' and @inn1end_ts !='0' and @inn2end_ts!='0'
			begin 
				if(@subtotal_inn2>@subtotal_inn1)--changed by Avadhut adding of trails and leads condition
            			begin
					set @result =  convert(varchar(30),@team2_name)+' Leads by '  + convert(varchar(30),(@subtotal_inn2 -@subtotal_inn1))+' Runs'
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   null as inn3, null as inn3_score,
								   null as inn4,null as inn4_score								
        		        end
                		else
		                begin
                			set @result =  convert(varchar(30),@team2_name)+' Trails by '  + convert(varchar(30),(@subtotal_inn1 -@subtotal_inn2))+' Runs'
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   null as inn3, null as inn3_score,
								   null as inn4,null as inn4_score								
        		        end						
			end
			else if @inn1end_ts !='0' and @inn2end_ts !='0' and @inn3end_ts!='0' and @inn4end_ts='0' and @inn2_bat!=@inn3_bat
			begin
 			if (@subtotal_inn2 > (@subtotal_inn1 + @subtotal_inn3)) and @wkts_inn3= 10			
			    	begin
					declare @remainingrun1 as int	
       					set @remainingrun1 = @subtotal_inn2 - (@subtotal_inn1 + @subtotal_inn3)
	    				
					if @remainingrun1 < 0
		    			begin
			    		    	set 	@remainingrun1 = 0
				    	end
    					
					set @result = convert(varchar(30),@team2_name) + ' Won By innings and '+ convert(varchar(30),@remainingrun1) +' Runs'
	    				select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   null as inn4,null as inn4_score	
		    			
					if @flag = '2'
                        		begin
		                            update matches_mst set result = 1,match_winner = @inn2_bat
	    			    		where id = @match
                        		end
				end	
				else if @subtotal_inn2 < (@subtotal_inn1 + @subtotal_inn3)
    				begin

	    				set @result =  convert(varchar(30),@team1_name)+' Leads by '  + convert(varchar(30),((@subtotal_inn1 + @subtotal_inn3)-@subtotal_inn2))+' Runs'
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   null as inn4,null as inn4_score							
				--end                
			    	end
                    		else 
		                begin
		                      	set @result =' Match Is Drawn Between ' + @team1_name   + ' and  ' + @team2_name
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   @team4_name as inn4,convert(varchar(10),isnull(@subtotal_inn4,''))+'/'+(convert(varchar(10),@wkts_inn4)) as inn4_score
					if @flag = '2'
                      			begin
		                          update matches_mst set result = 2,match_winner = 0
    					  where id = @match
                			end   
                    		end
			end
                
			else if @inn1end_ts !='0' and @inn2end_ts !='0' and @inn3end_ts!='0' and @inn4end_ts='0' and @inn2_bat=@inn3_bat
			begin
				if (@subtotal_inn1 > (@subtotal_inn2 + @subtotal_inn3)) and @wkts_inn3= 10
				begin
				    declare @remainingrun as int	
				    set @remainingrun = @subtotal_inn1 - (@subtotal_inn2 + @subtotal_inn3)
				    if @remainingrun < 0
				    begin
					set @remainingrun = 0
				    end
				
				    set @result = convert(varchar(30),@team1_name) + ' Won By innings and '+ convert(varchar(30),@remainingrun) +' Runs.'
				    select isnull(@result,'') as result	,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   null as inn4,null as inn4_score 	
				    if @flag = '2'
                     		   	 begin
				         	update matches_mst set result = 1,match_winner = @inn1_bat
    						where id = @match
					 end
							
				end
				else if @subtotal_inn1 < (@subtotal_inn2 + @subtotal_inn3)
				begin
	    			    set @result =  convert(varchar(30),@team2_name)+' Leads by '  + convert(varchar(30),(@subtotal_inn2 -(@subtotal_inn1 + @subtotal_inn3)))+' Runs'
				    select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   null as inn4,null as inn4_score							
					--end                
			    	end
				else 
                        	begin
                            	    set @result =' Match Is Drawn Between ' + @team1_name   + ' and  ' + @team2_name
				    select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score							
								   ,@team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score
								   ,@team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score
								   ,@team4_name as inn4,convert(varchar(10),isnull(@subtotal_inn4,''))+'/'+(convert(varchar(10),@wkts_inn4)) as inn4_score
				    if @flag = '2'
                            	    begin
                                	update matches_mst set result = 2,match_winner = 0
	    				where id = @match
                            	   end
                        	end
			end
			else if @inn1end_ts !='0' and @inn2end_ts !='0' and @inn3end_ts!='0' and @inn4end_ts !='0' 
			begin
				declare @team1score as  int
				declare @team2score  as int
				declare @remaining  as int
				if @inn2_bat=@inn3_bat
				begin
					set @team1score = @subtotal_inn1 + @subtotal_inn4
					set @team2score =  @subtotal_inn2 + @subtotal_inn3
				end
				else if @inn2_bat!=@inn3_bat
				begin
					set @team1score = @subtotal_inn1 + @subtotal_inn3
					set @team2score =  @subtotal_inn2 + @subtotal_inn4
				end 
				if @team1score > @team2score	and (@wkts_inn4=10)
				begin
					set @remaining = @team1score - @team2score
					if @remaining < 0
					begin
						set 	@remaining = 0
					end
					set @result = convert(varchar(30),@team1_name) + ' Won By '+ convert(varchar(30),@remaining) +' Runs '
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   @team4_name as inn4,convert(varchar(10),isnull(@subtotal_inn4,''))+'/'+(convert(varchar(10),@wkts_inn4)) as inn4_score
				
					if @flag = '2'
                		        begin
		                            update matches_mst set result = 1,match_winner = @inn1_bat
    					    where id = @match
                        		end
				end
				else if @team1score < @team2score	--and (@wkts_inn3=10)
				begin
					set @wkts_inn4 = 10 - @wkts_inn4
					set @result = convert(varchar(30),@team2_name)+' Won By  ' + convert(varchar(10),@wkts_inn4) +'  Wicket'
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   @team4_name as inn4,convert(varchar(10),isnull(@subtotal_inn4,''))+'/'+(convert(varchar(10),@wkts_inn4)) as inn4_score
	                    		if @flag = '2'
		                        begin					
                		            update matches_mst set result = 1,match_winner = @inn2_bat
    					     where id = @match
                        		end    
				end
--
				else if @team1score > @team2score	and (@wkts_inn4=10)--added for win
				begin
					set @wkts_inn4 = 10 - @wkts_inn4
					set @result = convert(varchar(30),@team1_name)+' Won By  ' + convert(varchar(10),@wkts_inn4) +'  Wicket'
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   @team4_name as inn4,convert(varchar(10),isnull(@subtotal_inn4,''))+'/'+(convert(varchar(10),@wkts_inn4)) as inn4_score
		                    	if @flag = '2'
		                        begin					
                 		           update matches_mst set result = 1,match_winner = @inn1_bat
    						where id = @match
		                        end    
				end
--
				else
				begin
					set @result =' Match Is Drawn Between ' + @team1_name   + ' and  ' + @team2_name
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   @team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score,
								   @team4_name as inn4,convert(varchar(10),isnull(@subtotal_inn4,''))+'/'+(convert(varchar(10),@wkts_inn4)) as inn4_score
					if @flag = '2'
		                        begin
		                            update matches_mst set result = 2,match_winner = 0
    						where id = @match
                            		end
				end	
		
			end
			else
			begin
				set @result =' Match Is Drawn Between' + @team1_name   + ' and  ' + @team2_name
				select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+'/'+(convert(varchar(10),@wkts_inn1)) as inn1_score							
								   ,@team2_name as inn2,convert(varchar(10),@subtotal_inn2)+'/'+(convert(varchar(10),@wkts_inn2)) as inn2_score
								   ,@team3_name as inn3,convert(varchar(10),@subtotal_inn3)+'/'+(convert(varchar(10),@wkts_inn3)) as inn3_score
								   ,@team4_name as inn4,(convert(varchar(10),isnull(@subtotal_inn4,''))+'/'+(convert(varchar(10),@wkts_inn4))) as inn4_score
				if @flag = '2'
               			begin
		                    update matches_mst set result = 2,match_winner = 0
    					where id = @match
		                end
			end	
			
end 

-- end test logic
------------------------------------------------------------------------------------------------------------------
-- start one day logic
else --  for one day
begin
	set @inn1 = (select min(id) from innings_mst where match_id=@match )
	set @inn2 = (select min(id) from innings_mst where match_id=@match  and id>@inn1)

	select @inn1end_ts = isnull(min(convert(varchar(20),end_ts)),'0') from innings_mst where id = @inn1
	select @inn2end_ts = isnull(min(convert(varchar(20),end_ts)),'0') from innings_mst where id = @inn2		
-- for 1st inning in one day
	select @subtotal_inn1 =max(runs) from #matchtotalscore where inning = @inn1 
					/*calculate total wkt for 1st inning*/
	select @wkts_inn1=count(0) from balls_mst inner join dismissals_mst  
														on balls_mst.id = dismissals_mst.ball  
														where balls_mst.inning_id = @inn1
					/*retire batting team*/
	set @inn1_bat = (select batting_team from innings_mst where id = @inn1)
  
					--name of teams
	set @team1_name = (select team_name from teams_mst where id = @inn1_bat)

	if @inn2end_ts = '0' and  @inn1end_ts !='0'
	begin
	/*calculate total run*/
					set @result ='Total Inning Score  ' +  @team1_name + ' <br>' + convert(varchar(10),@subtotal_inn1) + '  /   '+ convert(varchar(10),@wkts_inn1)
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+' / '+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+' / '+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   null as inn3, null as inn3_score,
								   null as inn4,null as inn4_score		 
	
	end
	else -- inning 2 is completd
	begin
					--innings 2
			set @totalruns = (select  isnull(max(runs),'0') from inning_revisedtarget_map
									where ts=(select max(ts) from inning_revisedtarget_map 
									where inning =@inn2 and convert(varchar(11),ts,112) = convert(varchar(11),getdate(),112)))
				
			if @totalruns!=0
			begin
				set @subtotal_inn1 = @totalruns
			end
			select @subtotal_inn2 =max(runs) from #matchtotalscore where inning = @inn2    
			select @wkts_inn2=count(0) from balls_mst inner join dismissals_mst  
												on balls_mst.id = dismissals_mst.ball  
												where balls_mst.inning_id = @inn2
			set @inn2_bat = (select batting_team from innings_mst where id = @inn2)	
			set @team2_name = (select team_name from teams_mst where id = @inn2_bat)

			if @subtotal_inn1 > @subtotal_inn2
			begin
				set @remaining = @subtotal_inn1 - @subtotal_inn2
				if @remaining < 0
					begin
						set	@remaining = 0
					end
				set @result =@team1_name+' Won By  ' + convert(varchar(20),@remaining) +'  Runs'					
				select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+' / '+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+' / '+(convert(varchar(10),@wkts_inn2)) as inn2_score,
	    							   null as inn3, null as inn3_score,
								   null as inn4,null as inn4_score
				update matches_mst set result = 1,match_winner =@inn1_bat
				where id = @match	
			end 
			else if  @subtotal_inn1 <  @subtotal_inn2
			begin
					declare @remwkt int
					set @remwkt = 10 - @wkts_inn2
					set @result =@team2_name+' Won By  ' + convert(varchar(10),@remwkt) +'  Wicket' 
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+' / '+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+' / '+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   null as inn3, null as inn3_score,
								   null as inn4,null as inn4_score		 
					update matches_mst set result = 1,match_winner =@inn2_bat
					where id = @match
			end
			else if @subtotal_inn1 = @subtotal_inn2
			begin
					update matches_mst set result = 3,match_winner =0
					where id = @match	
					set @result =' Match Is Tie Between ' + @team1_name   + ' and  ' + @team2_name
					select @result as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+' / '+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+' / '+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   null as inn3, null as inn3_score,
								   null as inn4,null as inn4_score	
			end
			else
			begin
				set @result =' Match Is Drawn Between ' + @team1_name   + ' and  ' + @team2_name
					select isnull(@result,'') as result,@team1_name as inn1,convert(varchar(10),@subtotal_inn1)+' / '+(convert(varchar(10),@wkts_inn1)) as inn1_score,							
								   @team2_name as inn2,convert(varchar(10),@subtotal_inn2)+' / '+(convert(varchar(10),@wkts_inn2)) as inn2_score,
								   null as inn3, null as inn3_score,
								   null as inn4,null as inn4_score
	
					update matches_mst set result = 2,match_winner =0
					where id = @match	
			end
	end
end
end
	drop table #matchtotalscore
set nocount off  
end

