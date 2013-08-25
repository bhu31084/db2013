
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*
    created by: Avadhut Joshi
    description:to to map the players with team
    date: 07/10/2008
select * from team_player_map where team_id = 71 and player_id = 504
exec dbo.esp_amd_teamplayermap '504','71','1'
exec dbo.esp_amd_teamplayermap '504','71','2'
exec dbo.esp_amd_teamplayermap '504','71','3'
exec dbo.esp_amd_teamplayermap '7426','343','1'
select team_player_id,team_id, player_id,status from team_player_map where team_id = 71 and player_id = 504
select * from team_player_map
*/
alter proc dbo.esp_amd_teamplayermap
@playerid int,
@teamid   int,
@statusid int

as
begin

declare @player as int
declare @team as int
declare @team_player_id as int
declare @status as char(1)
declare @curstatus as char(10)

-- status
if @statusid = 1
begin
 set @status = 'A'
end
if @statusid = 2
begin
 set @status = 'I'
end
if @statusid = 3
begin 
 set @status = 'D'
end

--end status

--existence of team player
select @team_player_id = team_player_id,@team = team_id,@player = player_id,@curstatus = isnull(status,'D') from team_player_map where team_id = @teamid and player_id = @playerid  
if(@team = @teamid and @player = @playerid and @curstatus = @status) 
    begin
    select 'Player Is Already Mapped for This Team!' as 'RetVal'
    end
else 
begin

    if (@curstatus = 'D' or @curstatus='' or @curstatus is null) 

        begin

             insert into team_player_map(team_id,player_id,status)
                               values(@teamid,@playerid,@status) 
    
            select 'Player Mapped Successfully!' as 'RetVal'
 
        end
    else if(@curstatus = 'A' or @curstatus = 'I')
        begin

            update team_player_map set status = @status where team_player_id = @team_player_id
        select 'Player Updated Successfully!' as 'RetVal'    
        end
    else
            begin
                        select 'Player Cannot Be Updated!' as 'RetVal'    
            end
end
end









