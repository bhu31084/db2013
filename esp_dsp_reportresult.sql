
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--esp_dsp_reportresult 704
--esp_dsp_reportresult 525
--exec esp_dsp_reportresult '801'
alter proc dbo.esp_dsp_reportresult
 @match  as  int

as
begin
set nocount on  
declare @result varchar(250)
declare @tmpresult varchar(450)
declare @resultid int 
declare @updateresultfalg int 
declare @team1name varchar(100)
declare @team2name varchar(100)
declare @winnerteam varchar(100)
declare @wonbywicket int
declare @wonbyrun int
declare @wonbyinning int
declare @is_supper_over varchar(10)


select @updateresultfalg = isnull(vjd_system,0) from matches_mst where id = @match
select @resultid = result from matches_mst where id = @match

if (@updateresultfalg = -1 or @updateresultfalg = 1)
begin
	select @team1name =  team_name from teams_mst where id in( select max(team1) from matches_mst  where id = @match)
	select @team2name =  team_name from teams_mst where id in( select max(team2) from matches_mst  where id = @match)	
	if @resultid = 1
	begin
		select @is_supper_over = isnull(is_supper,'N') from innings_mst where id in(select max(id) from innings_mst where match_id = @match)
		select @winnerteam =  team_name from teams_mst where id in( select max(match_winner) from matches_mst  where id = @match)	
		set @tmpresult = @winnerteam + ' won by '
		select @wonbywicket = won_by_wickets from matches_mst where id = @match
		if @wonbywicket >0
		begin
			set @tmpresult = @tmpresult + CONVERT(varchar(5), @wonbywicket) + ' wickets'
		end	

		select @wonbyrun = won_by_runs from matches_mst where id = @match
		if @wonbyrun >0
		begin
			set @tmpresult = @tmpresult + CONVERT(varchar(5), @wonbyrun) + ' runs'
		end		

		select @wonbyinning = won_by_innings from matches_mst where id = @match	
		
		if @wonbyinning > 0
		begin
		 set @tmpresult = @tmpresult + ' an inning'
		end
		if @updateresultfalg = 1
		begin
		 set @tmpresult = @tmpresult + ' by VJD Sytem'
		end
		if @is_supper_over = 'Y'
        begin
		set @tmpresult = @tmpresult + ' by Supper Over'	
        end			
	set @result = @tmpresult			
	select isnull(@result,'') as result
	end
	if @resultid = 2 
	begin
		select @team1name =  team_name from teams_mst where id in( select max(team1) from matches_mst  where id = @match)
		select @team2name =  team_name from teams_mst where id in( select max(team2) from matches_mst  where id = @match)
		set @result =' Match Is Drawn Between ' + @team1name   + ' and ' + @team2name 
		select isnull(@result,'') as result
	end
	else if @resultid = 5
	begin
		select @team1name =  team_name from teams_mst where id in( select max(team1) from matches_mst  where id = @match)
		select @team2name =  team_name from teams_mst where id in( select max(team2) from matches_mst  where id = @match)
		set @result =' Match Is Cancel Between ' + @team1name   + ' and ' + @team2name 
		select isnull(@result,'') as result
	end 
end
else
begin
	if @resultid = 2 
	begin
		select @team1name =  team_name from teams_mst where id in( select max(team1) from matches_mst  where id = @match)
		select @team2name =  team_name from teams_mst where id in( select max(team2) from matches_mst  where id = @match)
		set @result =' Match Is Drawn Between ' + @team1name   + ' and ' + @team2name 
		select isnull(@result,'') as result
	end
	else if @resultid = 5
	begin
		select @team1name =  team_name from teams_mst where id in( select max(team1) from matches_mst  where id = @match)
		select @team2name =  team_name from teams_mst where id in( select max(team2) from matches_mst  where id = @match)
		set @result =' Match Is Cancel Between ' + @team1name   + ' and ' + @team2name 
		select isnull(@result,'') as result
	end 
	else
	begin
		exec dbo.esp_dsp_testresult_01092009 @match,3
	end

end
	set nocount off  
end













































































