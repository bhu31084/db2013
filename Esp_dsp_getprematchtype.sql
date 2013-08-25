/*             
Created By :- Vaibhav Padyal             
Created On :- 10-09-2008             
Description :- This SP is used to retrieve the pre match type for match             
Modified :- Conditions for day of match added  
exec esp_dsp_getprematchtype 2555   
esp_dsp_getprematchtype '2789'  
exec esp_dsp_getprematchtype '1279'  
select num_days from matchtypes_mst a inner join matches_mst b on a.id = b.type and a.num_days > 1 where b.id = 2554   
  
*/   
ALTER PROC dbo.Esp_dsp_getprematchtype
 @match_id INT   
AS   
  BEGIN   
      SET nocount ON   
  
      DECLARE @matchtype AS VARCHAR(50)   
      DECLARE @category AS VARCHAR(50)   
      DECLARE @seriesname AS VARCHAR(50)   
      DECLARE @venue AS VARCHAR(50)   
      DECLARE @city AS VARCHAR(50)   
      DECLARE @team1_id AS INT   
      DECLARE @team1_name AS VARCHAR(50)   
      DECLARE @team2_id AS INT   
      DECLARE @team2_name AS VARCHAR(50)   
      DECLARE @toss_winner AS VARCHAR(50)   
      DECLARE @hometeam AS VARCHAR(50)   
      DECLARE @umpire1 AS VARCHAR(50)   
      DECLARE @umpire2 AS VARCHAR(50)   
      DECLARE @umpire3 AS VARCHAR(50)   
      DECLARE @referee  AS VARCHAR(50)   
      DECLARE @score1 AS VARCHAR(50)   
      DECLARE @score2 AS VARCHAR(50)   
      DECLARE @date AS VARCHAR(50)   
      DECLARE @date_end AS VARCHAR(50)   
      DECLARE @toss_winner_id AS INT   
      DECLARE @batting_team AS INT   
      DECLARE @elected AS VARCHAR(20)   
      DECLARE @day AS VARCHAR(25)   
      DECLARE @num_days INT   
      DECLARE @result INT   
      DECLARE @season varchar(50)    
      DECLARE @match_winner_team varchar(50)   
      DECLARE @match_name varchar(50)   
  
  
     select @match_name = name from matches_mst  
     where  status = 'A'   
        AND id = @match_id   
  
  
      select @match_winner_team = teams_mst.team_name  
  from matches_mst  
 inner join teams_mst  
 on matches_mst.match_winner = teams_mst.id  
         where  matches_mst.status = 'A'   
            AND matches_mst.id = @match_id   
  
      SELECT @matchtype = matchtypes_mst.name   
      FROM   matches_mst   
             INNER JOIN matchtypes_mst   
               ON matchtypes_mst.id = matches_mst.TYPE   
      WHERE  matchtypes_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND matches_mst.id = @match_id   
  
      SELECT @season = seasons_mst.name   
      from matches_mst   
    inner join series_mst  
    on matches_mst.series = series_mst.id  
    inner join seasons_mst  
    on series_mst.season = seasons_mst.id  
      where  matches_mst.status = 'A'   
            AND matches_mst.id = @match_id   
  
      SELECT @date = CONVERT(VARCHAR(11), expected_start, 103)   
      FROM   matches_mst   
      WHERE  matches_mst.status = 'A'   
             AND id = @match_id   
  
      SELECT @date_end = CONVERT(VARCHAR(11), expected_end, 103)   
      FROM   matches_mst   
      WHERE  matches_mst.status = 'A'   
             AND id = @match_id   
  
      SELECT @day = Datediff(dd, expected_start, Getdate())   
      FROM   matches_mst   
      WHERE  id = @match_id   
  
      SELECT @num_days = num_days   
      FROM   matchtypes_mst a   
             INNER JOIN matches_mst b   
               ON a.id = b.TYPE   
      WHERE  b.id = @match_id   
  
      SELECT @result = result   
      FROM   matches_mst   
      WHERE  id = @match_id   
  
      IF( @result ) > 0   
        BEGIN   
            SET @day = 'Completed'   
        END   
      ELSE   
        IF ( @num_days > 1 )   
          BEGIN   
              IF ( CONVERT(VARCHAR(11), Getdate(), 103) = @date_end )   
                BEGIN   
                    SET @day = @num_days   
                END   
              ELSE   
                BEGIN   
                    SET @day = @day + 1   
                END   
          END   
        ELSE   
          IF ( @num_days = 1 )   
            BEGIN   
                SET @day = 'Limited Over Match'   
            END   
  
SELECT @seriesname = seriestypes_mst.name   
      FROM   seriestypes_mst   
             INNER JOIN series_mst   
               ON series_mst.TYPE = seriestypes_mst.id   
             INNER JOIN matches_mst   
               ON series_mst.id = matches_mst.series   
      WHERE  seriestypes_mst.status = 'A'   
             AND series_mst.status = 'A'   
        AND matches_mst.status = 'A'   
             AND matches_mst.id = @match_id   
  
      SELECT @venue = venues_mst.name   
      FROM   matches_mst   
             INNER JOIN venues_mst   
               ON venues_mst.id = matches_mst.venue   
      WHERE  venues_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND matches_mst.id = @match_id   
  
      SELECT @hometeam = teams_mst.team_name   
      FROM   matches_mst   
            INNER JOIN teams_mst   
               ON teams_mst.id = matches_mst.hometeam   
      WHERE  matches_mst.status = 'A'   
             AND teams_mst.status = 'A'   
             AND matches_mst.id = @match_id   
  
      SELECT @toss_winner = teams_mst.team_name   
      FROM   matches_mst   
             INNER JOIN teams_mst   
               ON teams_mst.id = matches_mst.toss_winner   
      WHERE  matches_mst.status = 'A'   
             AND teams_mst.status = 'A'   
             AND matches_mst.id = @match_id   
  
      SELECT @toss_winner_id = toss_winner   
      FROM   matches_mst   
      WHERE  matches_mst.status = 'A'   
             AND id = @match_id   
  
      SELECT @batting_team = MAX(batting_team)   
      FROM   innings_mst   
      WHERE  innings_mst.status = 'A'   
             AND id IN(SELECT MIN(id)   
                       FROM   innings_mst   
                       WHERE  innings_mst.status = 'A'   
                              AND match_id = @match_id)   
  
      IF @toss_winner_id = @batting_team   
        BEGIN   
            SET @elected='Bat'   
        END   
      ELSE   
        BEGIN   
            SET @elected='Field'   
        END   
  
      SELECT @city = locations_mst.name   
      FROM   venues_mst   
             INNER JOIN matches_mst   
               ON matches_mst.venue = venues_mst.id   
             INNER JOIN addresses_mst   
               ON addresses_mst.id = venues_mst.address_id   
             INNER JOIN locations_mst   
               ON locations_mst.id = addresses_mst.location   
      WHERE  venues_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND addresses_mst.status = 'A'   
             AND locations_mst.status = 'A'   
             AND matches_mst.id = @match_id   
  
      SELECT @umpire1 = Isnull(users_mst.fname, '') + ' ' +   
                        Isnull(users_mst.sname, '')   
      FROM   users_mst   
             INNER JOIN user_role_map   
               ON users_mst.id = user_role_map.user_id   
             INNER JOIN match_official_map   
               ON match_official_map.official = user_role_map.user_role_id   
             INNER JOIN matches_mst   
               ON matches_mst.id = match_official_map.match_id   
      WHERE  users_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND user_role_map.ROLE = 2   
             AND matches_mst.id = @match_id   
             AND match_official_map.order_no = 1   
  
      SELECT @umpire2 = Isnull(users_mst.fname, '') + ' ' +   
                        Isnull(users_mst.sname, '')   
      FROM   users_mst   
             INNER JOIN user_role_map   
               ON users_mst.id = user_role_map.user_id   
             INNER JOIN match_official_map   
               ON match_official_map.official = user_role_map.user_role_id   
             INNER JOIN matches_mst   
               ON matches_mst.id = match_official_map.match_id   
      WHERE  users_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND user_role_map.ROLE = 2   
             AND matches_mst.id = @match_id   
             AND match_official_map.order_no = 2   
  
      SELECT @umpire3 = Isnull(users_mst.fname, '') + ' ' +   
                 Isnull(users_mst.sname, '')   
      FROM   users_mst   
             INNER JOIN user_role_map   
               ON users_mst.id = user_role_map.user_id   
             INNER JOIN match_official_map   
               ON match_official_map.official = user_role_map.user_role_id   
             INNER JOIN matches_mst   
               ON matches_mst.id = match_official_map.match_id   
      WHERE  users_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND user_role_map.ROLE = 2   
             AND matches_mst.id = @match_id   
             AND match_official_map.order_no = 3   
   
      SELECT @referee = Isnull(users_mst.fname, '') + ' ' +   
                        Isnull(users_mst.sname, '')   
      FROM   users_mst   
             INNER JOIN user_role_map   
               ON users_mst.id = user_role_map.user_id   
             INNER JOIN match_official_map   
               ON match_official_map.official = user_role_map.user_role_id   
             INNER JOIN matches_mst   
               ON matches_mst.id = match_official_map.match_id   
      WHERE  users_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND user_role_map.ROLE = 4   
             AND matches_mst.id = @match_id   
             AND match_official_map.order_no = 1        
  
      SELECT @score1 = Isnull(users_mst.fname, '') + ' ' +   
                       Isnull(users_mst.sname, '')   
      FROM   users_mst   
             INNER JOIN user_role_map   
               ON users_mst.id = user_role_map.user_id   
             INNER JOIN match_official_map   
               ON match_official_map.official = user_role_map.user_role_id   
             INNER JOIN matches_mst   
               ON matches_mst.id = match_official_map.match_id   
      WHERE  users_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND user_role_map.ROLE = 3   
             AND matches_mst.id = @match_id   
             AND match_official_map.order_no = 1   
  
      SELECT @score2 = Isnull(users_mst.fname, '') + ' ' +   
                       Isnull(users_mst.sname, '')   
      FROM   users_mst   
             INNER JOIN user_role_map   
               ON users_mst.id = user_role_map.user_id   
             INNER JOIN match_official_map   
               ON match_official_map.official = user_role_map.user_role_id   
             INNER JOIN matches_mst   
               ON matches_mst.id = match_official_map.match_id   
      WHERE  users_mst.status = 'A'   
             AND matches_mst.status = 'A'   
             AND user_role_map.ROLE = 3   
             AND matches_mst.id = @match_id   
             AND match_official_map.order_no = 2   
  
      SELECT @team1_id = teams_mst.id,   
             @team1_name = teams_mst.team_name   
      FROM   matches_mst   
             INNER JOIN teams_mst   
               ON teams_mst.id = matches_mst.team1   
      WHERE  matches_mst.status = 'A'   
             AND teams_mst.status = 'A'   
             AND matches_mst.id = @match_id   
  
      SELECT @team2_id = teams_mst.id,   
             @team2_name = teams_mst.team_name   
      FROM   matches_mst   
             INNER JOIN teams_mst   
               ON teams_mst.id = matches_mst.team2   
      WHERE  matches_mst.status = 'A'   
             AND teams_mst.status = 'A'   
             AND matches_mst.id = @match_id   
  
      SELECT Isnull(@seriesname, '')  AS series,   
             Isnull(@matchtype, '')   AS matchtype,   
             Isnull(@team1_id, '')    AS team1id,   
             Isnull(@team1_name, '')  AS team1name,   
             Isnull(@team2_id, '')    AS team2id,   
             Isnull(@team2_name, '')  AS team2name,   
             Isnull(@venue, '')       AS venue,   
             Isnull(@city, '')        AS city,   
             Isnull(@hometeam, '')    AS hometeam,   
             Isnull(@toss_winner, '') AS toss_winner,   
             Isnull(@umpire1, '')     AS umpire1,   
             Isnull(@umpire2, '')     AS umpire2,   
             Isnull(@umpire3, '')     AS umpire3,   
             Isnull(@score1, '')      AS score1,   
             Isnull(@score2, '')      AS score2,   
             Isnull(@date, '')        AS matchdate,   
             Isnull(@elected, '')     AS elected,   
             Isnull(@day,'')          AS matchday,   
      Isnull(@referee,'')      AS referee,  
      Isnull(@season,'')      AS season,  
      Isnull(@match_winner_team  ,'') AS match_winner_team,  
      Isnull(@match_name,'')      AS match_name,
	  Isnull(@num_days,'')      AS match_days,
	  Isnull(@date_end,'')      AS date_end  
    
  
      
    
  END   
  
SET nocount OFF    
  
  
  
  
  
  